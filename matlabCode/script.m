clear; 
myfile='2012_11_23_FirstTree';%'2012_11_25_SecondTree';
load([myfile '_SparsePts']);

%% Get the ground plane
% find a plane perpendicular to this using the lowest points 
%
% get all the points lower than the cameras
pts=xyz(xyz(:,3)<0,:);
% keep only 9/10 of them
len=9*length(pts)/10;
pts=pts(1:len,:);
plotFast(pts,'b')
view(0,80)
%
% get the ground?
[~,n,~,x,y,z,~]=ransac_tim(pts,3,10,2,100);
%smallest number of points required, number of iterations, threshold used
%to id a point that fits well, number of nearby points required

plot3(x,y,z,'g')
%%
% for all cameras, draw lines along the viewing direction
clc
plotFast(xyz,'r');
% for ii=1:length(projcams)
%     pos=projcams(ii,:);
%     vec=viewdir(ii,:);
%     p(1,:)=pos-vec;
%     p(2,:)=pos;
%     hold on;
% %     plot3(p(:,1),p(:,2),p(:,3),'r')
% end
inters=lsint(projcams',viewdir');
plot3(inters(1),inters(2),inters(3),'xk')
%%
    if exist(['data/' myfile '_SparseFull.mat'],'file')==0
        importBundleOut(myfile);
    end
    load(['data/' myfile '_SparseFull.mat']);
    numcams=length(cameras);
    % Find the camera positions and the viewing directions
    projcams=zeros(numcams,4);
    viewdir=zeros(numcams,4);
    for ii=1:numcams   
        projcams(ii,:)=[-cameras(ii).rotation'*cameras(ii).translation';cameras(ii).cam_index]';
        viewdir(ii,:)=[cameras(ii).rotation*[0 0 -1]';cameras(ii).cam_index]';
    end
    projcams=unique(projcams,'rows'); 
    viewdir=unique(viewdir,'rows');
    projcams(:,4)=[]; 
    viewdir(:,4)=[]; 
    ix=~any(projcams,2);
    projcams(ix,:)=[]; %remove the zeros
    viewdir(ix,:)=[]; %remove the zeros
    clear cameras numcams ii ix
    % Modify the imported structures
    rgb=[sparsePts.color]; numpts=length(rgb)/3; rgb=reshape(rgb,3,numpts); rgb=rgb'; rgb=rgb/255;
    xyz=[sparsePts.position];xyz=reshape(xyz,3,numpts); xyz=xyz';
    clear numpts sparsePts
    %%
    plotPTS(xyz,rgb,projcams);
    %%
%     inters=lsint(projcams',viewdir');
    P=projcams';d=viewdir';
    

%% Find the bounding box for the point clouds
[rotmat,cornerpoints,volume,surface,edgelength] = minboundbox(pts1(:,1)', pts1(:,2)', pts1(:,3)');
%%
plotFast(pts1,'r');

plotFast(pts2,'b');
%%
hold on;
plotminbox(cornerpoints)
%%
[R, T] =icp(pts1,pts2);