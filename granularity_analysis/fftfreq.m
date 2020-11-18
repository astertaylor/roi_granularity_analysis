function wavenumbers = fftfreq(n)
    iseven = mod(n,2);
    if iseven == 0
        x1 = linspace(0,n/2-1,n/2);
        x2 = linspace(-n/2,-1,n/2);
        wavenumbers = [x1,x2];
    else 
        x1 = linspace(0,(n-1)/2,((n-1)/2)-1);
        x2 = linspace(-(n-1)/2,-1,(n-1)/2);
        wavenumbers= [x1,x2];
    end
end