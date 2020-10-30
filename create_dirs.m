function create_dirs(out_path,save)
    "Outpath"
    disp(out_path)
    mkdir(out_path,'Images');
    mkdir(out_path,'Output');
    if save == 1 
        mkdir(out_path,'Filters');
    end
end