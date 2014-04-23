clear
myfiles={'2012_11_23_FirstTree','2012_11_25_SecondTree','2013_07_23_Abby','2013_07_23_Adina','2013_07_29_Agata','2013_07_29_Adina','2013_07_29_Everyone','2013_07_23_Rephoto'};%,'2013_07_29_AdinaAgata'
option='a';
%%
close all hidden
for index=length(myfiles)
    myfile=myfiles{index};
    if option=='o' || option=='a'
        processOut(myfile);
    end
    close all hidden
    pause(0.5);
    if option=='p' || option=='a'
        processPly(myfile);
    end
    close all hidden
    
    disp('Done')
end
%%
close all hidden
for index=length(myfiles)
    myfile=myfiles{index};
    load([myfile '_SparsePts']);
    plotPTS(xyz,rgb,projcams);
    SpinningGIF(['gif/' myfile '_SPARSE.gif']);
    disp([ 'Done with ' myfile '_SPARSE']);
    close all hidden
%     pause
    load([myfile '_DensePts']);
    plotPTS(xyzply,rgbply,projcams)
    SpinningGIF(['gif/' myfile '_DENSE.gif']);
    disp([ 'Done with ' myfile '_DENSE']);
    close all hidden
%     pause
end
%%
% camera index, SIFT keypoint index
% detected (x,y) positions of the keypoint

% pts=struct('xyz',[],'rgb',[],'cam',[],'keypts',[]);
% %%
% viewlist = fopen('ptsfileViewList.txt'); % the viewlist file
% tline=fgetl(viewlist);
% while ischar(tline)
%     tline = strsplit(tline);
%     numviews=str2double(tline{1});
%     jj=2;
%     for ii=1:numviews
%             pts(ii).cam = str2double(tline{jj});
%             pts(ii).keypts = [str2double(tline{jj+1}) str2double(tline{jj+1}) str2double(tline{jj+3})];
%             jj=jj+4;
%     end
%     tline=fgetl(viewlist);
% end
% fclose(viewlist);