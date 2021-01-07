function plotPowerSpectrum(energy_store,error_bars,labels,wave_numbers,dim)
    fig1 = figure(1);
    fig1.WindowState = 'maximized';
    hold on;
    colors = colorcet('R4','N',dim); %set colors
    "Error Bars"
    error_bars
    x_vals = wave_numbers;

    %plots each ROI
    for i = 1:dim
        energy = energy_store(:,i);
        if i==1 
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        else
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        end
        
    end
    
    %show files
    ylabel("Binned Power Spectrum");
    xlabel("Wavenumber");
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    hold off
    legend(labels);
end