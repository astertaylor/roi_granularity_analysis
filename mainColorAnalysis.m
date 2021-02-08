clear;close;clc;
input_files = ["XB1S8049.dng"]; %list of files to be analyzed, required
roi_files = ["XB1S8049_GRAN.zip"]; %ROI file location
out_files = []; %pathname to output, leave none for default

manual_files = 0; %0 is automatic from searches, 1 is manual entry.

camera_curves = ["CameraCurves.csv"]; %location of camera curves
wavelengths = 400:700;

w = 0.05;
n = [1 2 1];

if manual_files == 0;
    file_list = dir(fullfile(pwd,"**","X*_GRAN*.zip"));
    roi_files = [];
    for i = 1:length(file_list)
        roi_files = cat(1,roi_files,string(fullfile(file_list(i).folder,file_list(i).name)));
    end
    file_list = roi_files;
    input_files = roi_files;
    input_pattern = "_GRAN"+wildcardPattern+".zip";
    input_files = strcat(erase(input_files,input_pattern),".dng");
    out_files = file_list;
    out_files = erase(out_files,"GRAN");
    out_files = erase(out_files,"_.zip");
    out_files = erase(out_files,".zip");
end

camera = table2array(readtable(camera_curves));
for file_number = 1:length(input_files)
    close all;
    
    in_file = input_files(file_number);
    if isempty(out_files)
        out_path = split(in_file,'.');
        out_path = out_path(1); %set outpath correctly based on input
    else 
        out_path = out_files(file_number);
    end
    createDirs(out_path); %make directories
    roi_file = roi_files(file_number); %grab ROI location
    
    I = readDNGfile(in_file); %get image
    I = I./2^16;
    [rois,labels] = getMask(I,roi_file,in_file);
    
%     saveMasks(I,rois,labels)
%     exportgraphics(gcf,fullfile(out_path,"full_image.png"),'Resolution',300); %save image
    
    Q = getPatchQuanta(I,rois,camera,wavelengths);
    
    fid = fopen(fullfile(out_path,'JNDs.txt'),'w+');
    fprintf(fid,strcat("ROI 1",'\t',"ROI 2",'\t',"Delta S",'\t',"Delta L",'\n'));

    if size(Q{1},2) > 1 % Color vision
    
        allDeltaS = zeros(size(labels,2),size(labels,2));
        allDeltaL = zeros(size(labels,2),size(labels,2));

        for i = 1:size(labels,2)
            thisRoi = labels(i);
            Q1 = Q{i};
            for j = i:size(labels,2)
                nextRoi = labels(j);
                Q2 = Q{j};
                allDeltaS(i,j) = getDeltaS(Q1,Q2,n,w);
                allDeltaL(i,j) = abs(log(Q1(1))-log(Q2(1))); % use the LWS for luminance
                fprintf(fid,strcat(thisRoi,'\t',nextRoi,'\t',num2str(allDeltaS(i,j)),'\t',num2str(allDeltaL(i,j)),'\n'));
            end
        end
    else % monochromatic vision
        allDeltaL = zeros(size(labels,1),size(labels,1));
        allDeltaS = zeros(size(labels,1),size(labels,1));
        for i = 1:size(labels,1)
            thisRoi = labels(i);
            Q1 = Q{i};
            for j = i:size(labels,1)
                nextRoi = labels(j);
                Q2 = Q{j};
                allDeltaL(i,j) = abs(log(Q1)-log(Q2));
                fprintf(fid,strcat(thisRoi,'\t',nextRoi,'\t',num2str(allDeltaS(i,j)),'\t',num2str(allDeltaL(i,j)),'\n'));
            end
        end
    end

fclose(fid);
    
%create heatmaps
makeHeatmap(allDeltaS,labels,"delta_S_heatmap.png",out_path,"\DeltaS");
makeHeatmap(allDeltaL,labels,"delta_L_heatmap.png",out_path,"\DeltaL");   
end