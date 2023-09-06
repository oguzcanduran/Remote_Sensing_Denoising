close all;clear all;clc;
% mex YF_yann.c   % unutma 

%% Noise Addition

read_im=double(imread("/Data/Land_newtuz.tif"));
read_im=read_im(:,:,1);
                                    
n1 = size(read_im, 1);
n2 = size(read_im, 2);

if mod(n1,2)==1 
    n1=n1-1;
end
if mod(n2,2)==1 
    n2=n2-1;
end

I= uint16(read_im(1:n1,1:n2)); 

sigma = 1000;
imgd = double(I);
                                                         
In = imgd + sigma*randn(n1,n2);
In=double(In);

figure;
imshow(I,[]); 
title('Original Image');

figure;
imshow(In,[]);                                                                
title('Noisy Image');

%% Wavelet Part

type = 'h';

% 3 level Wavelet
[wA1, wH1, wV1, wD1] = dwt2(In, 'haar'); % level - 1
[wA2, wH2, wV2, wD2] = dwt2(wA1, 'haar'); % level - 2
[wA3, wH3, wV3, wD3] = dwt2(wA2, 'haar'); % level - 3

% LEVEL - 3
% find threshold on detail components
th_wH3 = find_thresh(wH3, 3, wH3);
th_wV3 = find_thresh(wH3, 3, wV3);
th_wD3 = find_thresh(wH3, 3, wD3);
% apply threshold, these matrices are denoised before image reconstruction
R_wH3 = wthresh2(wH3, type, th_wH3);
R_wV3 = wthresh2(wV3, type, th_wV3);
R_wD3 = wthresh2(wD3, type, th_wD3);

% LEVEL - 2
% find threshold on detail components
th_wH2 = find_thresh(wH2, 2, wH2);
th_wV2 = find_thresh(wH2, 2, wV2);
th_wD2 = find_thresh(wH2, 2, wD2);
% apply threshold, these matrices are denoised before image reconstruction
R_wH2 = wthresh2(wH2, type, th_wH2);
R_wV2 = wthresh2(wH2, type, th_wV2);
R_wD2 = wthresh2(wH2, type, th_wD2);

% LEVEL - 1
% find threshold on detail components
th_wH1 = find_thresh(wH1, 1, wH1);
th_wV1 = find_thresh(wH1, 1, wV1);
th_wD1 = find_thresh(wH1, 1, wD1);
% apply threshold, these matrices are denoised before image reconstruction
R_wH1 = wthresh2(wH1, type, th_wH1);
R_wV1 = wthresh2(wV1, type, th_wV1);
R_wD1 = wthresh2(wD1, type, th_wD1);


% apply inverse discrete wavelet transform on all levels
R_wA2 = idwt2(wA3, R_wH3, R_wV3, R_wD3, 'haar');
R_wA1 = idwt2(wA2, R_wH2, R_wV2, R_wD2, 'haar');
R_wA = idwt2(wA1, R_wH1, R_wV1, R_wD1, 'haar');

W_res=R_wA;

%% Curvelet Part
type2='c';

sigma2 = sqrt(max(In,[],"all"));

F = ones(n1,n2);
X = fftshift(ifft2(F)) * sqrt(numel(F));
Cn = fdct_wrapping(X, 0, 2);
E = cell(size(Cn));

for s = 1:length(Cn)
    E{s} = cell(size(Cn{s}));
    for w = 1:length(Cn{s})
        A = Cn{s}{w};
        E{s}{w} = sqrt(sum(sum(A.*conj(A))) / numel(A));
    end
end

C = fdct_wrapping(In, 1, 2);

Ct = C;
        for s = 2:(length(C)) 
            thresh = 3*sigma2 + sigma2*(s == length(C));
            for w = 1:length(C{s})
                Ct{s}{w}=wthresh2(C{s}{w},type2,thresh*E{s}{w}); 
            end     
        end
C_res = real(ifdct_wrapping(Ct, 1));


%% Wiener
temp_w=(double(C_res)+double(W_res))/2;
Wien_res = wiener2(temp_w,[3 3]);

z1 = wiener2(W_res,[3 3]);
z2=wiener2(C_res,[3 3]);

%% Yaroslavsky 
si=std2(In);
hw=sqrt(0.1*si^2);

q1=YF_yann( double(In)     ,W_res     ,5   , hw);     
q2=YF_yann( double(In)     ,C_res   ,5   , hw); 
%% Ensemble 

z3=(z1+z2)/2;

q5=(double(q1)+double(q2))/2;
q6 = wiener2(q5,[3 3]);

best_res=real((q6+z3)/2);
b_res=(best_res);

%% Results

disp(psnr(uint16(b_res),(I)));
disp(ssim(uint16(b_res),(I)));

figure(1);
imshow(I,[]);title("Original Image")
figure(2);
imshow(uint16(In),[]);title(sprintf(["Noisy Image, PSNR= %f , SSIM= %f"],psnr(uint16(In),I),ssim(uint16(In),I)))

figure(3);
imshow(b_res,[]);title(sprintf([" Denoised, PSNR= %f , SSIM= %f"],psnr(uint16(b_res),I),ssim(uint16(b_res),I)))

figure(4);
imshow(In-b_res,[]);title(" Noise")

denoised=uint16(line_eq(b_res,"16bit"));imwrite(denoised,"denoisedtuz.png")
noisy=uint16(line_eq(In,"16bit"));imwrite(noisy,"noisytuz.png")
noise=uint16(line_eq(In-b_res,"16bit"));imwrite(noise,"noisetuz.png")
org=uint16(line_eq(double(I),"16bit"));imwrite(org,"Original_Imagetuz.png")




