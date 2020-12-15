file_list = dir('*.mat');
dim = size(file_list);
dim = dim(1)
[label_list{1:dim}] = deal(["animal-mantle","rock1","rock2","rock3","rock4"]);

format short

for index = 1:dim
    labels = label_list{index};
    path = file_list(index).folder+"\"+file_list(index).name;
    data = load(path);
    nrois = size(data.energy_store);
    nrois = nrois(2);
    power = repmat(data.energy_store,[1 1 nrois]);
    power_error = repmat(data.error_bars,[1 1 nrois]);
    delta = repmat(data.delta_store,[1 1 nrois]);
    delta_error = repmat(data.delta_errors,[1 1 nrois]);
    power_cross = permute(power,[1 3 2]);
    power_error_cross = permute(power_error,[1 3 2]);
    delta_cross = permute(delta,[1 3 2]);
    delta_error_cross = permute(delta_error,[1 3 2]);
    
    power_diff = abs(power-power_cross);
    power_denom = sqrt(power_error.^2 + power_error_cross.^2);
    power_stats = power_diff./power_denom
    
    delta_diff = abs(delta-delta_cross);
    delta_denom = sqrt(delta_error.^2 + delta_error_cross.^2);
    delta_stats = delta_diff./delta_denom
        
    ind = 1;
    power_table = [];
    delta_table = [];
    while ind <= nrois
        for col_ind = 1:ind
            power_table = cat(2,power_table,labels(ind));
            power_table = cat(2,power_table,labels(col_ind));
            
            delta_table = cat(2,delta_table,labels(ind));
            delta_table = cat(2,delta_table,labels(col_ind));
            
            power_flat = string(power_stats(:,ind,col_ind).');
            delta_flat = string(delta_stats(:,ind,col_ind).');
            power_string = [];
            delta_string = [];
            for str_ind = 1:length(power_flat)
                power_string = strcat(power_string," ");
                power_string = strcat(power_string,power_flat(str_ind));
                
                delta_string = strcat(delta_string," ");
                delta_string = strcat(delta_string,delta_flat(str_ind));
            end
            
            power_table = cat(2, power_table,power_string);
            delta_table = cat(2,delta_table,delta_string);
        end
        ind = ind+1;
    end
    stat_format = '%s %s %s \n';
    name = string(file_list(index).name);
    name = name.split(".");
    path1 = fopen(file_list(1).folder+"\"+name(1)+"_power.txt",'w');
    path2 = fopen(file_list(1).folder+"\"+name(1)+"_delta.txt",'w');

    
    fprintf(path1,stat_format,power_table);
    fprintf(path2,stat_format,delta_table);
    fclose('all');
    
end

    
   % 1,1 is labels(1),labels(1), 1,2 is labels(1),labels(2). These are
   % associative.