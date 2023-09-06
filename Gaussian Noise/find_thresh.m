function [T] = find_thresh(M, level, testh_m)
% level added
C = 0.6745;

variance = (median(abs(double(M(:))))/C)^2;
beta = sqrt(2*log(length(testh_m)/(2^(level+1))));
T = 2*beta*sqrt(variance)*exp(-level)*log(level+2);
