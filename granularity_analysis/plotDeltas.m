function [delta_store,delta_errors]=plotDeltas(energy_store,error_bars,labels,wave_numbers,dim)
    figure(2);
    hold on
    colors = colorcet('R4','N',dim);
    x_vals = wave_numbers;
    delta_store = [];
    delta_errors = [];
    for i = 1:dim
        energy = energy_store(:,i);
        delta_y = sqrt(energy/(2*pi)).*x_vals;
        delta_store = cat(2,delta_store,delta_y);
        error = error_bars(:,i);
        delta_error = 1/(2*sqrt(2*pi)) * error.*x_vals.*(energy.^(-1/2));
        delta_errors = cat(2,delta_errors,delta_error);
        errorbar(x_vals,delta_y,delta_error,'o-','Color',colors(i,:),'markersize',5,'markeredgecolor','k','markerfacecolor',colors(i,:));
    end
    ylabel("Binned Delta");
    xlabel("Wavenumber");
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    hold off
    legend(labels);
end