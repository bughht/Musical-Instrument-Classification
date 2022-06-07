function varargout = APP(varargin)
%APP MATLAB code file for APP.fig
%      APP, by itself, creates a new APP or raises the existing
%      singleton*.
%
%      H = APP returns the handle to a new APP or the handle to
%      the existing singleton*.
%
%      APP('Property','Value',...) creates a new APP using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to APP_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      APP('CALLBACK') and APP('CALLBACK',hObject,...) call the
%      local function named CALLBACK in APP.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help APP

% Last Modified by GUIDE v2.5 26-Apr-2021 09:21:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @APP_OpeningFcn, ...
                   'gui_OutputFcn',  @APP_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before APP is made visible.
function APP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for APP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes APP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = APP_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global filename file_loc Channel_num flagpause x Fs Frame framelen Channel m featureVec hd time Player prediction labellist;
Channel_num=1;
flagpause=0;
Channel=1;
time=0;
filename='';
file_loc='';
x=[];
Fs=44100;
Frame=1;
framelen=1;
m=[];
prediction=zeros(12,1);
featureVec=zeros(12,1);
Player=[];
hd=handles;
Label={'分类输出';'Bass:';'Electric_Guitar:';'Glockenspiel:';'Organ:';'Piano:';'Pipa:';'Snare_Drum:';'String:';'Vintage_lead:';'Violins:'};
set(handles.TextLabel,'string',Label);




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename file_loc x Fs Frame framelen Channel m Channel_num flagpause prediction Player labellist;
[filename, filepath]=uigetfile({'*.wav';'*.flac';'*.ogg';'*.au';'*.mp3';'*.mp4'},'导入音频文件');
if(filename~=0)
    file_loc=[filepath filename];
    set(handles.text_fileloc,'string',file_loc);
    information={'音频信息';['文件名：',filename];'Loading...'};
    set(handles.text_information,'string',information);
    [x,Fs]=audioread(file_loc);
    Player=audioplayer(x,Fs);
    set(Player,'TimerPeriod',441/Fs*15);
    set(Player,'TimerFcn',@audio_Callback_func);
    s=size(x);
    Channel_num=num2str(s(2));
    information={'音频信息';['文件名：',filename];['采样率：',num2str(Fs)];['时长：',num2str(s(1)/Fs),'s'];...
        ['通道数：',Channel_num]};
    timeax=1/Fs:1/Fs:s(1)/Fs;
    if(Channel_num-1)
        plot(handles.axes_raw1,timeax,x(:,1));
        plot(handles.axes_raw2,timeax,x(:,2),'-r');
        plot(handles.axes_FFT1,abs(AverageFFT(x(:,1),Fs)));
        plot(handles.axes_FFT2,abs(AverageFFT(x(:,2),Fs)),'-r');
    else
        set(handles.BUTTON_Channel2,'enable','off');
        set(handles.text_information,'string',information);
        plot(handles.axes_raw1,timeax,x(:,1));
        plot(handles.axes_FFT1,abs(AverageFFT(x(:,1),Fs)));
    end
    m=MFCC(x(:,Channel),Fs);
    framelen=numel(m)/12;
    Frame=1;
    set(handles.slider1,'Max',framelen,'Min',1,'Value',1,'sliderstep',[1,0.05]);
    heatmap(handles.panel_mfcc,m.','XLabel','帧','YLabel','特征向量','GridVisible','off','Colormap',autumn,'MissingDataColor','White');
    set(handles.text_Frameid,'String',['Frame=',num2str(Frame)]);
    feature=m(Frame,:)
    set(handles.FeatureTable,'data',feature.');
    prediction=MusicClassifier5(feature);
    set(handles.PredictionTab,'data',prediction.');
    result=GETMax(prediction);
    clinf={'单帧分类结果：';result};
    set(handles.ClassResult,'string',clinf);
    set(handles.text_information,'string',information);
    if flagpause==1
        flagpause=0;
    end
end

% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Frame m prediction;
Frame=floor(get(hObject,'Value'));
set(handles.text_Frameid,'String',['Frame=',num2str(Frame)]);
set(handles.FeatureTable,'data',m(Frame,:).');
prediction=MusicClassifier10(m(Frame,:));
set(handles.PredictionTab,'data',prediction.');
result=GETMax(prediction);
clinf={'单帧分类结果：';result};
set(handles.ClassResult,'string',clinf);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in BUTTON_Channel1.
function BUTTON_Channel1_Callback(hObject, eventdata, handles)
% hObject    handle to BUTTON_Channel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Channel x Fs m Frame prediction;
Channel=1;
m=MFCC(x(:,Channel),Fs);
heatmap(handles.panel_mfcc,m.','XLabel','帧','YLabel','特征向量','GridVisible','off','Colormap',autumn,'MissingDataColor','White');
set(handles.FeatureTable,'data',m(Frame,:).');
prediction=MusicClassifier10(m(Frame,:));
set(handles.PredictionTab,'data',prediction.');
result=GETMax(prediction);
clinf={'单帧分类结果：';result};
set(handles.ClassResult,'string',clinf);





% --- Executes on button press in BUTTON_Channel2.
function BUTTON_Channel2_Callback(hObject, eventdata, handles)
% hObject    handle to BUTTON_Channel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Channel x Fs m Frame Channel_num;
if Channel_num-1
    Channel=2;
else
    Channel=1;
end
m=MFCC(x(:,Channel),Fs);
heatmap(handles.panel_mfcc,m.','XLabel','帧','YLabel','特征向量','GridVisible','off','Colormap',autumn,'MissingDataColor','White');
set(handles.FeatureTable,'data',m(Frame,:).');
prediction=MusicClassifier5(m(Frame,:));
set(handles.PredictionTab,'data',prediction.');
result=GETMax(prediction);
clinf={'单帧分类结果：';result};
set(handles.ClassResult,'string',clinf);


% --- Executes during object creation, after setting all properties.
function FeatureVec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FeatureVec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Player time flagpause;
%set(handles.panel_mfcc,'Interruptible',0);
if(flagpause==0)
    time=0;
    play(Player);
else
    resume(Player);
    flagpause=1;
end

function audio_Callback_func(hObject, eventdata, handles)
global time prediction m hd Frame framelen;
if(time>=framelen)
    time=0;
    stop(Player);
end
Frame=time;
time=time+15;

disp(Frame);
predict_whole=zeros(1,10);
for i=(Frame-15):Frame
    feature=m(i,:);
    predict_whole=predict_whole+MusicClassifier5(feature)/15;
end
%feature=m(Frame,:)
set(hd.FeatureTable,'data',feature.');
prediction=predict_whole;
%prediction=MusicClassifier55(feature);
set(hd.PredictionTab,'data',prediction.');
set(hd.slider1,'Value',Frame);
set(hd.text_Frameid,'String',['Frame=',num2str(Frame)]);
result=GETMax(prediction);
clinf={'单帧分类结果：';result};
set(hd.ClassResult,'string',clinf);


% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Player time flagpause;
pause(Player);
flagpause=1;


% --- Executes on button press in PauseButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Player time;
stop(Player);
time=0;
