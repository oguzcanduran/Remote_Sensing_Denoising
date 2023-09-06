% https://owuchangyuo.github.io/
clear all; close all;

l=double(imread("/Data/Land_newtuz.tif"));
tut=l(:,:,1)/max(l,[],"all");

Ik =  double(imread("/Data/Hype_newtuz.tif"));
Ik =  Ik/max(Ik,[],"all") ;

hy=Ik(:,:,1);
tut2=Ik(:,:,6);
I_new=rotateandcrop(hy,tut);

tut=I_new(:,:,2);
Is=I_new(:,:,1);

I_new_2=rotateandcrop(hy,tut2);
tut2=I_new_2(:,:,2);


[opts] = ParSet;           


tic
[U, S] = SILR_destripe(Is,opts);
toc 



[IA1, IH1, IV1, ID1] = dwt2(Is-S, 'haar'); % level - 1
[SA1, SH1, SV1, SD1] = dwt2(U, 'haar'); % level - 1

[IA2, IH2, IV2, ID2] = dwt2(IA1, 'haar'); % level - 2
[SA2, SH2, SV2, SD2] = dwt2(SA1, 'haar'); % level - 2

[IA3, IH3, IV3, ID3] = dwt2(IA2, 'haar'); % level - 3
[SA3, SH3, SV3, SD3] = dwt2(SA2, 'haar'); % level - 3

Ires3 = idwt2(IA3, IH3, SV3, SD3, 'haar');

Ires2 = idwt2((Ires3(1:size(IH2,1),1:size(IH2,2))+IA2)/2 , IH2, SV2, SD2, 'haar');

Ires = idwt2((Ires2(1:size(IH1,1),1:size(IH1,2))+IA1)/2, IH1, SV1, SD1, 'haar');

Ires=Ires(1:size(Is,1),1:size(Is,2));


figure,imshow(Is,[]);title("Noisy (Hyperion)");
figure,imshow(tut,[]);title("Landsat 8");
figure,imshow(Ires,[]);title("Denoised");
figure,imshow(Is-Ires,[]);title("Noise");

denoised=uint16(line_eq(Ires,"16bit"));imwrite(denoised,"denoised_tuz_band_2_tuz.png")
noisy=uint16(line_eq(Is,"16bit"));imwrite(noisy,"noisy_tuz_band_2(hyperion)_tuz.png")
noise=uint16(line_eq(Is-Ires,"16bit"));imwrite(noise,"noise_tuz_band_2_tuz.png")
lnd=uint16(line_eq(tut,"16bit"));imwrite(lnd,"landsat8_tuz_band_1_tuz.png")
lnd2=uint16(line_eq(tut2,"16bit"));imwrite(lnd2,"hype_tuz_band_6_tuz.png")



figure();
subplot(1,4,1);
imshow(Is,[]);title("Noisy Image (Hyperion)")
subplot(1,4,2);
imshow(Is-Ires,[]);title("Noise (Difference)")
subplot(1,4,3);
imshow(Ires,[]);title("Denoised Image")
subplot(1,4,4);
imshow(tut,[]);title("Landsat 8")

savefig('Comparison_band2_tuz.fig')
