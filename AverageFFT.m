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
    Series=filter([1 -alpha],1,Series);%Ԥ�����˲���
    Series=enframe(Series,882,441);%�����źŷ�֡,��xÿ882���Ϊһ֡��ƽ��441�������ȡ��һ֡
    %����ÿ֡��MFCC����
    
    F=zeros(882);
    for i=1:size(Series,1)
        y=Series(i,:); %ȡ��һ֡�ź�
        s=y'.*hamming(882); %�Ӵ�
        t=abs(fft(s)); %��fft��ȡģ
        F=F+t;
        %c=dctcoef*log(bank*t(1:442)); %ͨ��Mel�˲��������������DCT
        %m(i,:)=c'; %�洢���
    end
    F=F./size(Series,1);
    F=F(1:441);
end

