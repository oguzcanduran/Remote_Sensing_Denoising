function y=line_eq(mat,bit)
    switch(bit)
        case "16bit"
            c=2^16-1;
        case "12bit"
            c=2^12-1;
        case "8bit"
            c=2^8-1;
        otherwise
            error("Invalid bit.")
    end
ma=max(max(mat));
mi=min(min(mat));
a=c/(ma-mi);
b=-a*mi;
y=a*mat+b;