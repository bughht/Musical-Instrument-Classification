clc;
clear all;

[x,Fs]=audioread('dataset\1Piano.wav');
m=MFCC(x(:,2),Fs);
m=m(all(~isnan(m),2),:);

result=MusicClassifier(m(20,:));

subplot(3,1,1);
plot(result(:,5));
subplot(3,1,2);
plot(x(:,1));
subplot(3,1,3);
heatmap(m.')

% 启动定时器
clear all;
clc;
% 删除现有的定时器，重新创建一个定时器
timer_id = timer;
timer_id.StartDelay = 1.0;
timer_id.Period = 1.0;
% 周期性执行,fixedSpacing模式
timer_id.ExecutionMode = 'fixedSpacing';
timer_id.TimerFcn = @timer_handler;
%启动定时器
start(timer_id);

function timer_handler(~,~)
    persistent counter;
    if isempty(counter)
     counter = 0;
    end
    fprintf(1,'定时器回调=%d\n',counter);
    counter = counter+1;
end