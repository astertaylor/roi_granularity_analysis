function plotPowerSpectrum(energy_store,error_bars,labels,wave_numbers,dim)
    figure(1);
    hold on;
    colors = colorcet('R4','N',dim);
    "Error Bars"
    error_bars
    x_vals = wave_numbers;

    for i = 1:dim
        energy = energy_store(:,i);
        if i==1 
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        else
            errorbar(x_vals,energy,(error_bars(:,i)),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
        end
        
    end
    ylabel("Binned Power Spectrum");
    xlabel("Wavenumber");
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    hold off
    legend(labels);
end