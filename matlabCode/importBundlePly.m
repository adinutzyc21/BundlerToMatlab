function importBundlePly(myfile)
    %% Load the PLY file
    % Remove the first few header lines in model.ply
    command=['cd helperCode/; ./processPly ' myfile '.ply'];
    system(command);
    clear command ans
    plyfile = load('ply.txt'); %the whole ply file
    %% Break plyfile into useful structs
    plypts=struct('xyx',[],'rgb',[]);
    numplypts=length(plyfile);
    for ii=1:numplypts                       % upper limit is # of rows in dense
        plypts(ii).xyz=plyfile(ii,1:3);
        plypts(ii).rgb=plyfile(ii,7:9);
    end
    clear plyfile
    %% Save all these structures
    save(['data/' myfile '_DenseFull'],'plypts');
    %% Delete the processing files
    command='cd process/; rm ply.txt';
    system(command);
    clear command ans
end