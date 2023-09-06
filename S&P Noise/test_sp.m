
close all
clear all
Image=imread("/Data/Land_newvan.tif");
Image=Image(:,:,1);
Image=uint16(line_eq(double(Image)));
n_1 = size(Image, 1);
n_2=size(Image, 2);
sigma = 20;
In = imnoise(Image,"salt & pepper",0.4);

q_1=fft2(double(In));
figure();imshow(Image);title("Original");imwrite(Image,"Original_van.png")
figure();imshow(uint16(In));title("0.4 S&P added");imwrite(uint16(In),"Noisy_04_van.png")
%figure();imshow(q_1);
p=std2(q_1);
t1=2*(n_1*n_2)/(std2(q_1));
qq=hp_filter(In, t1 );
q=qq.*q_1;
%figure();imshow(q);

z=ifft2(q);
z=real(z);
z=(line_eq(z));
%figure();imshow(uint16(z));
th=1-1/sqrt(std2(qq)*std2(In));

pad=1;
ll=z>mean(mean(z))/th | z<mean(mean(z))*th | In==uint16(0) | In>=uint16((2^16-1)) ;

%figure();imshow(ll);
u_In=double(In);

for i =1:n_1
    for j=1:n_2
     if ll(i,j)==1 
        if i>pad && j>pad && i<=n_1-pad && j<=n_2-pad
            temp=u_In(i-pad:i+pad,j-pad:j+pad);
            u_In(i,j)=median(unique(temp)) ;
        elseif j<=n_2-pad && i<=n_1-pad
            temp=u_In(i:i+pad,j:j+pad);
            u_In(i,j)=median(unique(temp)) ;
        elseif  i>pad && j>pad
            temp=u_In(i-pad:i,j-pad:j);
            u_In(i,j)=median(unique(temp));
        end
     end
    end
end


    disp(psnr(uint16(u_In),Image))
    disp(ssim(uint16(u_In),Image))


figure();imshow(uint16(u_In));title("Denoised");imwrite(uint16(u_In),"Denoised_04_van.png")
