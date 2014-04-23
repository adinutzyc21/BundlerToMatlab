function h=plotPTS(xyz,rgb,projcams,parent)
%%     close(gcf);
    if(nargin==1)
        rgb='r';
        parent=gca;
        projcams=[];
    else if(nargin==2)
            projcams=[];
            parent=gca;
        end
    end
    
    disp('Loading...');
    
    if ~isempty(projcams)
        h=plot3(projcams(:,1),projcams(:,2),projcams(:,3),'.m'); %cameras
        set(h,'Parent',parent);
        hold on;
    end
%     scatter3(xyz(:,1),xyz(:,2),xyz(:,3),5,rgb,'filled')%points
    h=fscatter3(xyz(:,1),xyz(:,2),xyz(:,3),1:length(xyz),rgb);%points
    
    set(h,'Parent',parent);
    view(0,0); 
    
    targ = get(gca, 'CameraTarget');
    pos = get(gca, 'CameraPosition');
    radius = norm(targ(1:2) - pos(1:2));
    ang=0;
    set(gca, 'CameraPosition', [targ(1) + radius * cos(ang), targ(2) + radius * sin(ang), pos(3)]);

    disp('Done.');
end