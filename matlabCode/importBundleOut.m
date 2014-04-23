% From the BUNDLER MANUAL README:
% The bundle files contain the estimated scene and camera geometry have the following format:
%     # Bundle file v0.3
%     <num_cameras> <num_points>   [two integers]
%     <camera1>
%     <camera2>
%        ...
%     <cameraN>
%     <point1>
%     <point2>
%        ...
%     <pointM>

% Each camera entry <cameraI> contains the estimated camera intrinsics and extrinsics, and has the form:
%     <f> <k1> <k2>   [the focal length, followed by two radial distortion coeffs]
%     <R>             [a 3x3 matrix representing the camera rotation]
%     <t>             [a 3-vector describing the camera translation]
% The cameras are specified in the order they appear in the list of images.

% Each point entry has the form:
%     <position>      [a 3-vector describing the 3D position of the point]
%     <color>         [a 3-vector describing the RGB color of the point]
%     <view list>     [a list of views the point is visible in]
% The view list begins with the length of the list (i.e., the number of cameras the point is visible in). 
% The list is then given as a list of quadruplets <camera> <key> <x> <y>, where:
%     <camera> is a camera index, 
%     <key> the index of the SIFT keypoint where the point was detected in that camera, and 
%     <x> and <y> are the detected positions of that keypoint. 
%  Both indices are 0-based (e.g., if camera 0 appears in the list, this corresponds to the first camera in the scene file and the first image in "list.txt"). 
%  The pixel positions are floating point numbers in a coordinate system where the origin is the center of the image, the x-axis increases to the right, and the y-axis increases towards the top of the image. 
%  Thus, (-w/2, -h/2) is the lower-left corner of the image, and (w/2, h/2) is the top-right corner (where w and h are the width and height of the image).

function importBundleOut(myfile)
    %% First split the bundle.out file in two parts automatically (check out
    % helperCode/splitfile for how it actually works)
    command=['cd helperCode/; ./splitFile ' myfile '.out'];
    system(command);
    
    % Load the two files
    camfile = load('camfile.txt'); %camfile is the first half of the bundle.out data
    ptsfile = load('ptsfile.txt'); %second half of the data, with shortened viewlist data 
    %% Break BundleCamInfo (camfile) into slices of array
    % focal length, radial distortion coeff 1, radial distortion coeff 2
    % 3x3 camera rotation matrix, translation 3-vector
    camcount = 1:5;
    numcams=round(length(camfile)/5); %number of rows in camfile divided by 5
    caminfo = zeros(5,3,numcams);  
    %
    for ii=1:numcams            
        camsubmat=camfile(camcount,:);      
        caminfo(:,:,ii) = camsubmat;
        camcount=camcount+5;
    end

    % Put caminfo into useful structs
    cameras=struct('focal_length',[],'radial_distortion_coeff',[],'rotation',[],'translation',[],'cam_index',[]);
    for ii=1:numcams
        cameras(ii).focal_length=caminfo(1,1,ii);
        cameras(ii).radial_distortion_coeff=caminfo(1,2:end,ii);
        cameras(ii).rotation=caminfo(2:4,:,ii);
        cameras(ii).translation=caminfo(5,:,ii);
        cameras(ii).cam_index=ii-1;                %index cameras from 0 to numcams-1
    end

    %% Break BundlePointInfo (ptsfile) into slices of array
    % 3-vector describind 3D position
    % 3-vector describing RGB color
    % 3-vector containing a camera index and a sift point location
    ptcount = 1:3;
    numpts = round(length(ptsfile)/3); % number of rows in ptsfile divided by 5
    ptinfo=zeros(3,3,numpts);
    %
    for ii=1:numpts
        ptsubmat=ptsfile(ptcount,:);    %ptsfile is the second half of the bundle.out data
        ptinfo(:,:,ii) = ptsubmat;
        ptcount=ptcount+3;
    end
    %
    % Put point info into useful structs
    sparsePts=struct('position',[],'color',[],'cam_index',[],'keypts',[]);
    for ii=1:numpts   
        sparsePts(ii).position=ptinfo(1,1:3,ii);
        sparsePts(ii).color=ptinfo(2,1:3,ii);
        sparsePts(ii).cam_index=ptinfo(3,1,ii);
        sparsePts(ii).keypts=ptinfo(3,2:end,ii);
    end
    
    %% Save all these structures
    save(['data/' myfile '_SparseFull'],'cameras','sparsePts');
    %% Delete the processing files
    command='cd process/; rm camfile.txt ptsfile.txt';
    system(command);
    clear command ans
end