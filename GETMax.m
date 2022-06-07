function result = GETMax(in)
    labellist={'Bass','Electric_Guitar','Glockenspiel ','Organ','Piano','Pipa','Snare_Drum','String','Vintage_lead','Violins'};
    if isnan(in(1))
        result='none';
        return;
    else
        [m,p]=max(in);
        in(p)=0;
        [n,p2]=max(in);
        if(m>0.5)
            result=labellist{p};
        elseif(m>0.3 && n>=0.1)
            result=labellist{p}+" ("+labellist{p2}+")";
        elseif(m>0.3)
            result=labellist{p};
        else
            result='Unknown';
        end
        return;
    end
end

