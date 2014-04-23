function processOut(myfile)
    %% Load the OUT structures
    % need to load/import anyway because we need projcams for alignment
    if exist(['data/' myfile '_SparseFull.mat'],'file')==0
        importBundleOut(myfile);
    end
    load(['data/original/' myfile '_SparseFull.mat']);
    numcams=length(cameras);
    %% Find the camera positions and the viewing directions
    projcams=zeros(numcams,4);
%     viewdir=zeros(numcams,4);
    for ii=1:numcams   
        projcams(ii,:)=[-cameras(ii).rotation'*cameras(ii).translation';cameras(ii).cam_index]';
%         viewdir(ii,:)=[cameras(ii).rotation*[0 0 -1]';cameras(ii).cam_index]';
    end
    projcams=unique(projcams,'rows'); 
%     viewdir=unique(viewdir,'rows');
    projcams(:,4)=[]; 
%     viewdir(:,4)=[]; 
    ix=~any(projcams,2);
    projcams(ix,:)=[]; %remove the zeros
%     viewdir(ix,:)=[]; %remove the zeros
%     ix=~any(viewdir,2);
%     projcams(ix,:)=[]; %remove the zeros
%     viewdir(ix,:)=[]; %remove the zeros
    clear cameras numcams ii ix
    %% Modify the imported structures
    rgb=[sparsePts.color]; numpts=length(rgb)/3; rgb=reshape(rgb,3,numpts); rgb=rgb'; rgb=rgb/255;
    xyz=[sparsePts.position];xyz=reshape(xyz,3,numpts); xyz=xyz';
    
    [xyz,ix,~]=unique(xyz,'rows');%remove duplicates
    rgb=rgb(ix,:);
    clear numpts sparsePts ix
    %% Rotate everything correctly
    [ang,ax]=fitPlane(projcams);
    [projcams, ~, ~]=AxelRot(projcams',ang,ax,[0,0,0]);
    projcams=projcams';
    
%     [viewdir, ~, ~]=AxelRot(viewdir',ang,ax,[0,0,0]);
%     viewdir=viewdir';
    
    [xyz, ~, ~]=AxelRot(xyz',ang,ax,[0,0,0]);
    xyz=xyz';
    clear ang ax
    %% Crop the interest points
    % fit a circle to the cameras' X and Y
    x=projcams(:,1); y=projcams(:,2); z=mean(projcams(:,3));
    x=x(:); y=y(:);
    a=[x y ones(size(x))]\-(x.^2+y.^2);
    xc = -.5*a(1); yc = -.5*a(2); R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));
    % x and y in circle if (x - xc)^2 + (y - yc)^2 < R^2
    inds=find((xyz(:,1)-xc).^2+(xyz(:,2)-yc).^2 < R^2);
    xyz=xyz(inds,:); rgb=rgb(inds,:);
    %translate everything so that the center of the cameras is [0,0,0]
    xyz(:,1)=xyz(:,1)-xc; xyz(:,2)=xyz(:,2)-yc; xyz(:,3)=xyz(:,3)-z;
    projcams(:,1)=projcams(:,1)-xc; projcams(:,2)=projcams(:,2)-yc; projcams(:,3)=projcams(:,3)-z;
%     viewdir(:,1)=viewdir(:,1)-xc; viewdir(:,2)=viewdir(:,2)-yc; viewdir(:,3)=viewdir(:,3)-z;
    clear x y z a xc yc inds R
    %% Draw bundle.out everything rotated correctly
    plotPTS(xyz,rgb,projcams);
    %% Rotate if necessary and save
    choice = questdlg('Is this rightside-up?','Orientation','Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            opt = 1;
        case 'No'
            opt = -1;
    end

    if opt==-1
        xyz(:,3)=-xyz(:,3);
        projcams(:,3)=-projcams(:,3);
%         viewdir(:,3)=-viewdir(:,3);
%         plotPTS(xyz,rgb,projcams);
    end
    %% Sort the points and colors by their z coordinate
    [~,ix]=sort(xyz(:,3));
    xyz=xyz(ix,:);
    rgb=rgb(ix,:);
    clear ix
    %% Save
    save(['data/' myfile '_SparsePts'],'projcams','xyz','rgb');%,'viewdir');
    
    clf;
    disp(['Done saving ' myfile '_SparsePts']);
end