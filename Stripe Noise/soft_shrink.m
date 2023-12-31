function [dx] = soft_shrink(dx,Thresh)
% Vectorial shrinkage (soft-threholding)
s = abs( dx );
dx = max(s - Thresh,0).*sign(dx);
