function [ang,ax]=fitPlane(projcams)
    %% Find the angle and axis necessary to rotate the points so that the plane defined by the cameras is parallel to xOy
    %use the plane fitting thingie
    A=[projcams(:,1)-mean(projcams(:,1)), projcams(:,2)-mean(projcams(:,2)), projcams(:,3)-mean(projcams(:,3))];
    [~,~,V]=svd(A,0);
    n=V(:,end); %is this pointing up
    
    %compute the angle of rotation
    zn=[0;0;1]; c=cross(n,zn); l=norm(c); d=dot(n,zn);
    if l>0.01 
        ax = c / l; ang=atan2(l,d);
    else if d>0   % nearly positively aligned, skip rotation
        else      % nearly negatively aligned, axis is [0,1,0] vector, angle is pi
            ax = [0;1;0]; ang = pi;
        end
    end
    ang=ang*180/pi;
end