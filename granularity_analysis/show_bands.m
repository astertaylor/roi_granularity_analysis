function show_bands(energy_store,errorbars,labels,out_path)
    figure();
    hold on
    dim = size(energy_store)
    colors = hsv(dim(3));
    colors(2,:)
    if ~errorbars
        "Error Bars"
        error_bars
    end
    for i = 1:dim(3)
        energy = energy_store(:,i);
%         if i==1
%             errorbar(energy,(error_bars.*energy),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         else
%             errorbar(energy,(error_bars.*energy),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
%         end
        if errorbars
            if i==1 
                errorbar(energy,(error_bars),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
            else
                errorbar(energy,(error_bars),'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
            end
        else
            if i==1 
                plot(energy,'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
            else
                plot(energy,'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
            end
        end
    end
    size(energy_store)
    ylabel("Relative power");
    xlabel("Granularity Band Index");
    hold off
    if labels
        legend(labels);
    end
    if outpath
        saveas(1,strcat(out_path,"/granularity_bands.png"));    
    end
end