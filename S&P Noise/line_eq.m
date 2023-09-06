function y=line_eq(mat)
ma=max(max(mat));
mi=min(min(mat));
a=(2^8-1)/(ma-mi);
b=-a*mi;
y=a*mat+b;
