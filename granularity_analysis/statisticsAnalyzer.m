file_list = dir(fullfile(pwd,'**','*.mat')); %find data files
dim = size(file_list);
dim = dim(1)

format short

for index = 1:dim
    close all;
    path = fullfile(file_list(index).folder,file_list(index).name);
    data = load(path); %load data files
    labels = data.labels
    nrois = size(data.energy_store);
    nrois = nrois(2);
    
    %work out matrices for pairwise
    power = repmat(data.energy_store,[1 1 nrois]);
    power_error = repmat(data.error_bars,[1 1 nrois]);
    delta = repmat(data.delta_store,[1 1 nrois]);
    delta_error = repmat(data.delta_errors,[1 1 nrois]);
    power_cross = permute(power,[1 3 2]);
    power_error_cross = permute(power_error,[1 3 2]);
    delta_cross = permute(delta,[1 3 2]);
    delta_error_cross = permute(delta_error,[1 3 2]);
    
    %compute averages of bands
    n = size(power);
    n = n(3);
    power_average = mean(power,1);
    power_average_cross = mean(power_cross,1);
    power_error_average = sqrt(sum((power_error.^2),1))/n;
    power_error_average_cross = sqrt(sum((power_error_cross.^2),1))/n;
    
    delta_average = mean(delta,1);
    delta_average_cross = mean(delta_cross,1);
    delta_error_average = sqrt(sum((delta_error.^2),1))/n;
    delta_error_average_cross = sqrt(sum((delta_error_cross.^2),1))/n;
    
    %compute average comparison
    power_diff_average = abs(power_average-power_average_cross);
    power_denom_average = sqrt(power_error_average.^2 + power_error_average_cross.^2);
    power_stats_average = reshape(power_diff_average./power_denom_average,[n n]);
    
    delta_diff_average = abs(delta_average-delta_average_cross);
    delta_denom_average = sqrt(delta_error_average.^2 + delta_error_average_cross.^2);
    delta_stats_average = reshape(delta_diff_average./delta_denom_average,[n n]);
    
    %create color maps
    figure('Position',[200 200 500 400]);
    map = zeros(256,3);
    maximum = max(power_stats_average(:));
    limit = round(256/maximum);
    R = linspace(1,1,limit);
    G = linspace(0.7,1,limit);
    B = linspace(0.2,0.1,limit);
    map(1:limit,:) = [R',G',B'];
    R = linspace(0.2,0.3,(256-limit));
    G = linspace(0.2,0.8,(256-limit));
    B = linspace(0.7,0.5,(256-limit));
    map((limit+1):end,:) = [R',G',B'];
    colormap(map);
    imagesc(power_stats_average);
    colorbar;
    tickgrid = 1:1:(limit);
    xticks(tickgrid);
    yticks(tickgrid);
    xticklabels(labels);
    yticklabels(labels);
    xtickangle(45);
    ytickangle(45);
    saveas(1,fullfile(file_list(index).folder,"average_power_heatmap.png"));
    
     map = zeros(256,3);
    maximum = max(delta_stats_average(:));
    limit = round(256/maximum);
    R = linspace(1,1,limit);
    G = linspace(0.7,1,limit);
    B = linspace(0.2,0.1,limit);
    map(1:limit,:) = [R',G',B'];
    R = linspace(0.2,0.3,(256-limit));
    G = linspace(0.2,0.8,(256-limit));
    B = linspace(0.7,0.5,(256-limit));
    map((limit+1):end,:) = [R',G',B'];
    colormap(map);
    imagesc(delta_stats_average);
    colorbar;
    tickgrid = 1:1:(limit);
    xticks(tickgrid);
    yticks(tickgrid);
    xticklabels(labels);
    yticklabels(labels);
    xtickangle(45);
    ytickangle(45);
    saveas(1,fullfile(file_list(index).folder,"average_delta_heatmap.png"));
    
   
    
    %compute delta and power K-S stats
    power_diff = abs(power-power_cross);
    power_denom = sqrt(power_error.^2 + power_error_cross.^2);
    power_stats = power_diff./power_denom;
    
    delta_diff = abs(delta-delta_cross);
    delta_denom = sqrt(delta_error.^2 + delta_error_cross.^2);
    delta_stats = delta_diff./delta_denom;
        
    ind = 1;
    power_table = [];
    delta_table = [];
    %write out matrix into rows
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
    
    %formats and saves files
    stat_format = '%s %s %s \n';
    name = string(file_list(index).folder);
    name = name.split("\");
    path1 = fopen(fullfile(file_list(index).folder,strcat(name(end),"_power.txt")),'w');
    path2 = fopen(fullfile(file_list(index).folder,strcat(name(end),"_delta.txt")),'w');

    
    fprintf(path1,stat_format,power_table);
    fprintf(path2,stat_format,delta_table);
    fclose('all');
    
end

    
   % 1,1 is labels(1),labels(1), 1,2 is labels(1),labels(2). These are
   % associative.