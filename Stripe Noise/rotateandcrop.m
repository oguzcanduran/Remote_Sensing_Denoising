function I_new = rotateandcrop(Is,base)
boy=size(Is,1);
en=size(Is,2);

c1=0;c2=0;

for i=1:en
    if Is(1,i,1)==0
        c1=c1+1;
    else
        break
    end
end
qq=boy;
for j=1:boy
    if sum(Is(qq,1:5,1))==0
        break
            else
        qq=qq-1;
    end
end
      
        for i=1:en
    
            if Is(qq,i,1)==0
                c2=c2+1;
            else
                break
            end
        end

deg=atan((c1-c2)/qq)*180/pi;
I=imrotate(Is,deg);
c3=1;c4=1;c5=1;c6=1;

en2=size(I,2);
boy2=size(I,1);
for i=1:en2
    if I(round(boy2/2),i,1)==0
        c3=c3+1;
    else
        break
    end
end
for i=1:en2
    if I(round(boy2/2),en2-i,1)==0
        c5=c5+1;
    else
        break
    end
end



for i=1:boy2
    if (I(i,c3+2,1)==0) ||  (I(i,en2-c5-2+2,1)==0)
        c4=c4+1;
    else
        break
    end
end

for i=1:boy2
    if (I(boy2-i,en2-c5-2,1)==0) || (I(boy2-i,c3+2,1)==0)
        c6=c6+1;
    else
        break
    end
end
I2=I(c4+4:boy2-c6-4,c3+5:en2-c5-5);
b2=imrotate(base,deg);
I3=b2(c4+4:boy2-c6-4,c3+5:en2-c5-5);

I_new(:,:,1)=I2;
I_new(:,:,2)=I3;
