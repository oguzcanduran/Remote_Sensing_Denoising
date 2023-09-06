function hpf=hp_filter(x,r)
len_1=size(x,1);
len_2=size(x,2);
len_reduce_1=len_1/(r*2);
len_reduce_2=len_2/(r*2);
hpf=zeros(len_1,len_2);
hpf(len_reduce_1+1:len_1-len_reduce_1,:)=1;
hpf(:,len_reduce_2+1:len_2-len_reduce_2)=1;
