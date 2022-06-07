function F = AverageFFT(Series,Fs)
    alpha=0.97;
    bank=melbankm(24,882,Fs,0,0.5,'t');
    bank=full(bank);
    bank=bank/max(bank(:));
    dctcoef=zeros(12,24);
    for k=1:12 
        n=0:23;
        dctcoef(k,:)=cos((2*n+1)*k*pi/(2*24));
    end
    Series=filter([1 -alpha],1,Series);%预加重滤波器
    Series=enframe(Series,882,441);%语音信号分帧,对x每882点分为一帧，平移441个点后再取下一帧
    %计算每帧的MFCC参数
    
    F=zeros(882);
    for i=1:size(Series,1)
        y=Series(i,:); %取出一帧信号
        s=y'.*hamming(882); %加窗
        t=abs(fft(s)); %先fft后取模
        F=F+t;
        %c=dctcoef*log(bank*t(1:442)); %通过Mel滤波器、对数运算和DCT
        %m(i,:)=c'; %存储结果
    end
    F=F./size(Series,1);
    F=F(1:441);
end

