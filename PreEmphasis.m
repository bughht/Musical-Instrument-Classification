function [out] = PreEmphasis(raw_signal,alpha)
    out=filter([1 -alpha],1,raw_signal);
end

 