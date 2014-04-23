function processPly(myfile)
    %% Load the OUT structures
    % need to load/import anyway because we need projcams for alignment
    if exist(['data/' myfile '_SparseFull.mat'],'file')==0
        importBundleOut(myfile);
    end
    if exist(['data/' myfile '_DenseFull.mat'],'file')==0
        importBundlePly(myfile);
    end
    load(['data/original/' myfile '_SparseFull.mat']);
    load(['data/original/' myfile '_DenseFull.mat']);
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
    clear cameras numcams ii ix sparsePts
    %% Modify the imported structures   
    xyzply=[plypts.xyz]; numplypts=length(xyzply)/3; xyzply=reshape(xyzply,3,numplypts); xyzply=xyzply';
    rgbply=[plypts.rgb]; rgbply=reshape(rgbply,3,numplypts); rgbply=rgbply'; rgbply=rgbply/255;
    
    [xyzply,ix,~]=unique(xyzply,'rows'); %remove duplicates
    rgbply=rgbply(ix,:);
    
    clear ix numplypts plypts
    %% Rotate everything correctly
    [ang,ax]=fitPlane(projcams);
    [projcams, ~, ~]=AxelRot(projcams',ang,ax,[0,0,0]);
    projcams=projcams';
    
%     [viewdir, ~, ~]=AxelRot(viewdir',ang,ax,[0,0,0]);
%     viewdir=viewdir';
    
    [xyzply, ~, ~]=AxelRot(xyzply',ang,ax,[0,0,0]);
    xyzply=xyzply';
    clear ang ax
    %% Crop the interest points
    % fit a circle to the cameras' X and Y
    x=projcams(:,1); y=projcams(:,2); z=mean(projcams(:,3));
    x=x(:); y=y(:);
    a=[x y ones(size(x))]\-(x.^2+y.^2);
    xc = -.5*a(1); yc = -.5*a(2); R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));
    % x and y in circle if (x - xc)^2 + (y - yc)^2 < R^2
    inds=find((xyzply(:,1)-xc).^2+(xyzply(:,2)-yc).^2 < R^2);
    xyzply=xyzply(inds,:); rgbply=rgbply(inds,:);
    %translate everything so that the center of the cameras is [0,0,0]
    xyzply(:,1)=xyzply(:,1)-xc; xyzply(:,2)=xyzply(:,2)-yc; xyzply(:,3)=xyzply(:,3)-z;
    projcams(:,1)=projcams(:,1)-xc; projcams(:,2)=projcams(:,2)-yc; projcams(:,3)=projcams(:,3)-z;
%     viewdir(:,1)=viewdir(:,1)-xc; viewdir(:,2)=viewdir(:,2)-yc; viewdir(:,3)=viewdir(:,3)-z;
    clear x y z a xc yc inds R
    %% Draw bundle.out everything rotated correctly
    plotPTS(xyzply,rgbply,projcams);
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
        xyzply(:,3)=-xyzply(:,3);
        projcams(:,3)=-projcams(:,3);
%         viewdir(:,3)=-viewdir(:,3);
%         plotPTS(xyzply,rgbply,projcams);
    end
    %% Sort the points and colors by their z coordinate
    [~,ix]=sort(xyzply(:,3));
    xyzply=xyzply(ix,:);
    rgbply=rgbply(ix,:);
    clear ix
    %% Save
    save(['data/' myfile '_DensePts'],'projcams','xyzply','rgbply');%,'viewdir');
    
    clf;
    disp(['Done saving ' myfile '_DensePts']);
end