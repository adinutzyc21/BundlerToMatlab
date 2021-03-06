% make your 3D plot.  plot3(...) or scatter3(...) or whatever
function SpinningGIF(giffile)
    % giffile='../chair.gif';
    axis off
    view(0,10)
    center = get(gca, 'CameraTarget');
    pos = get(gca, 'CameraPosition');
    radius = norm(center(1:2) - pos(1:2));
    
    angles = 0:2*pi/60:2*pi;

    for ii=1:length(angles)
       angle = angles(ii);

       set(gca, 'CameraPosition', [center(1) + radius * cos(angle),...
                                   center(2) + radius * sin(angle),...
                                   pos(3)]);
       drawnow;
       frame = getframe(1);
       im = frame2im(frame);
       [imind,cm] = rgb2ind(im,256);
       if ii == 1
           imwrite(imind,cm,giffile,'gif', 'Loopcount',inf);
       else
           imwrite(imind,cm,giffile,'gif','WriteMode','append','DelayTime', 0.25);
       end
    end
end