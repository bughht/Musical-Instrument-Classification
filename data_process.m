clc;
clear all;

typelist={'Bass','Electric_Guitar','Glockenspiel ','Organ','Piano','Pipa','Snare_Drum','String','Vintage_lead','Violins '};

data=[];
label=[];
for type=1:10
    disp(typelist(type));
    for id=1:30
        filename=sprintf("dataset\\%s%s.wav",num2str(id),string(typelist(type)));
        [x,Fs]=audioread(filename);
        for i=1:2
            m=MFCC(x(:,i),Fs);
            m=m(all(~isnan(m),2),:);
            data=[data;m];
            mlen=numel(m)/12;
            mlabel=zeros(mlen,10);
            mlabel(:,type)=1;
            label=[label;mlabel];
        end
    end
end