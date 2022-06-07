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

% ������ʱ��
clear all;
clc;
% ɾ�����еĶ�ʱ�������´���һ����ʱ��
timer_id = timer;
timer_id.StartDelay = 1.0;
timer_id.Period = 1.0;
% ������ִ��,fixedSpacingģʽ
timer_id.ExecutionMode = 'fixedSpacing';
timer_id.TimerFcn = @timer_handler;
%������ʱ��
start(timer_id);

function timer_handler(~,~)
    persistent counter;
    if isempty(counter)
     counter = 0;
    end
    fprintf(1,'��ʱ���ص�=%d\n',counter);
    counter = counter+1;
end