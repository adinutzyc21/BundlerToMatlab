function plotFast(xyz,col,parent)
    if nargin==1
        parent=gca;
        col='r';
    end
    if nargin==2
        parent=gca;
    end
    disp('Loading...');
    hold on;
    h=plot3(xyz(:,1),xyz(:,2),xyz(:,3),['.' col],'markersize',5);%points of color col
    set(h,'Parent',parent);
    
    view(0,0); 
    
    targ = get(parent, 'CameraTarget');
    pos = get(parent, 'CameraPosition');
    radius = norm(targ(1:2) - pos(1:2));
    ang=0;
    set(parent, 'CameraPosition', [targ(1) + radius * cos(ang), targ(2) + radius * sin(ang), pos(3)]);

    disp('Done.');
end