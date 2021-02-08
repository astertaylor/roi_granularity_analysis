function dS = getDeltaS(Q1,Q2,n,emax)

% From Vorobyev and Osorio 1998

% R: receptor spectral sensitivities

% emax: standard deviations of the noise in the receptor channel with most abundant cones, also
% called Weber fraction. we assume this is for the most abundant receptor.
% From this, we calculate v:

% ei = sig ./sqrt(n_most_abundant). We assume v is fixed (?)

% sig: standard deviation of the noise in a *single* receptor cell of type i,

% Q1 and Q2 are the quantum catches of the two spectra being compared, NOT
% log transformed

% Find the most abundant photoreceptor

pmax = find(n==max(n),1);

% calculate sigma (or v)

sig = emax*sqrt(n(pmax));

% weber fractions
e = sig./sqrt(n);

 
% This one is for the denominator

v = 1:numel(Q1);

k = 2;

C = combnk(v,k);

 
% This one is for the Denominator

Cdenum = combnk(v,numel(v)-1);
 

% The numerator term

T = 0;

Q1 = abs(Q1);
Q2 = abs(Q2);
Q1 = log(Q1);
Q2 = log(Q2);

% Numerator

for i = 1:size(C,1)

   term1 = Q1(C(i,1)) - Q2(C(i,1));

   term2 = Q1(C(i,2)) - Q2(C(i,2));

   term3 = (term1-term2).^2;

   mult = (prod(e(setdiff(v,C(i,:))))).^2; 

   term4 = mult*term3;

   T = T + term4;

end

 

% Denominator

D = 0;

for i = 1:size(Cdenum,1)

    D = D + (prod(e(Cdenum(i,:)))).^2;

end


dS = sqrt(T./D);

 