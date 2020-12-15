function f = fftfreq(n)
    if rem(n,2) == 0
        f = [0:((n/2)-1),-(n/2):-1]/(n);
    else
        f = [0:((n-1)/2),-((n-1)/2):-1]/(n);
    end
end