
function y = wthresh2(x,sorh,t)

% I have added 2 additional case to original wthresh2 function
% case(sorh) 'c' perform cubic thresholding
% case(sorh) 'b' perform their combination 

if isStringScalar(sorh)
    sorh = convertStringsToChars(sorh);
end

switch sorh
  case 's'
    tmp = (abs(x)-t);
    tmp = (tmp+abs(tmp))/2;
    y   = sign(x).*tmp;
 
  case 'h'
    y   = x.*(abs(x)>=t);

  case 'c'

    tempo=x.*(1-abs(t./x).^3);
    y=tempo.*(abs(x)>=t);

    case 'b'
    r=x;

    q   = r.*(abs(r)>=t);

    tmp = (abs(q)-t);
    tmp = (tmp+abs(tmp))/2;
    y   = sign(q).*tmp;
 
  otherwise
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
