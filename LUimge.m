function varargout = LUimge(varargin)
% LUIMGE MATLAB code for LUimge.fig
%      LUIMGE, by itself, creates a new LUIMGE or raises the existing
%      singleton*.
%
%      H = LUIMGE returns the handle to a new LUIMGE or the handle to
%      the existing singleton*.
%
%      LUIMGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUIMGE.M with the given input arguments.
%
%      LUIMGE('Property','Value',...) creates a new LUIMGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LUimge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LUimge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LUimge

% Last Modified by GUIDE v2.5 09-Feb-2020 22:10:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LUimge_OpeningFcn, ...
                   'gui_OutputFcn',  @LUimge_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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

% --- Executes during object creation, after setting all properties.
function axes_tj1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_tj1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_tj1

% --- Executes just before LUimge is made visible.
function LUimge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LUimge (see VARARGIN)

% Choose default command line output
% str_bp='biophotonics_logo.jpg';
% current_add=pwd;
% bp_add=fullfile(current_add,str_bp);
% imT_bp=imread(bp_add);
% axes(handles.axes_tj1) ;
% imshow(imT_bp,[]);
handles.output = hObject;

% Set the default values to all components
set(handles.slider3,'Value',0);
set(handles.slider4,'Value',1);
set(handles.slider5,'Value',(0+1)/2);
set(handles.slider6,'Value',1/10);
set(handles.edit24,'String',num2str(0));
set(handles.edit25,'String',num2str(1));
set(handles.edit26,'String',num2str(0));
set(handles.edit27,'String',num2str(1));

% Update handles structure
guidata(hObject, handles);
set(gcf,'name','Image Analyst Version 2019');

% --- Outputs from this function are returned to the command line.
function varargout = LUimge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Check the mac address to make sure it runs on the right PC
% is_ok=chk_mac;
is_ok=1; %w/o check
if is_ok
	set(handles.select_file,'Enable','on');
else
	set(handles.select_file,'Enable','off');
	msgbox('This software is not runing on the right PC! Please call the provider');
end

% --- Executes on button press in select_file.
function select_file_Callback(hObject, eventdata, handles)
% hObject    handle to select_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirname=get(handles.current_path,'String');
[filename, dirname]=uigetfile({'*.bin;*.mat'},'Select the data file',dirname);
if isequal(filename,0)
    return;
end
set(handles.current_path,'String',dirname);
set(handles.current_file,'String',filename);
setappdata(0,'path_name',dirname);
set(handles.load_file,'Enable','on');

% --- Executes on button press in load_file.
function load_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirname=get(handles.current_path,'String');
curname=get(handles.current_file,'String');
filename=[dirname curname];
[~, name, ext] = fileparts(filename);

if (strcmp('.mat',ext))
    if exist(filename, 'file') == 2
        load(filename);
    else
        warndlg('Not existent file');
        return;
    end
else
    return;
end

% enable all channel button
set(handles.isDAPI,'Value',0);
set(handles.isFITC,'Value',0);
set(handles.isTXRED,'Value',0);
set(handles.isCY5,'Value',0);
set(handles.all_channels,'Value',0);

% disable adjustment panel
set(findall(handles.adjust, '-property', 'Enable'), 'Enable', 'off');
set(findall(handles.uibuttongroup1, '-property', 'Enable'), 'Enable', 'off');
set(handles.enable_adjust,'Enable','on');
set(handles.enable_adjust,'Value',0);

% clear all axes
cla(handles.axes1);
cla(handles.Hist);
cla(handles.TC);

% normalize each channel 
for k = 1:size(ROI_im,3)
    ROI_im(:,:,k) = mat2gray(ROI_im(:,:,k));
end

% display 4-channel image
rgb_img = cat(3,(ROI_im(:,:,3)+ROI_im(:,:,4)./2),ROI_im(:,:,2),(ROI_im(:,:,1)+ROI_im(:,:,4)./2));%rgb
axes(handles.axes1) ;
imshow(rgb_img,[]);

% pass data to workspace
handles.data.img_origin=ROI_im; % backup the original image
handles.data.img=ROI_im; % this copy can be modified freely
handles.data.name=name; % for the xls saving at the end

guidata(hObject,handles); % Update the guidata

%% in case the mouse misclick

function current_path_Callback(hObject, eventdata, handles)
% hObject    handle to current_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_path as text
%        str2double(get(hObject,'String')) returns contents of current_path as a double

% --- Executes during object creation, after setting all properties.
function current_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function current_file_Callback(hObject, eventdata, handles)
% hObject    handle to current_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_file as text
%        str2double(get(hObject,'String')) returns contents of current_file as a double

% --- Executes during object creation, after setting all properties.
function current_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Panel channel
function display_color_image(hObject, eventdata, handles)

    isDAPI  = get(handles.isDAPI,'Value');
    isFITC  = get(handles.isFITC,'Value');
    isTXRED = get(handles.isTXRED,'Value');
    isCY5   = get(handles.isCY5,'Value');
    
    % display synthesized color image
    ROI_im = handles.data.img;
    temp = zeros([size(ROI_im(:,:,1)),3]);
    if isDAPI == 1
        temp(:,:,3) = temp(:,:,3)+ROI_im(:,:,1);
    end
    if isFITC == 1
        temp(:,:,2) = temp(:,:,2)+ROI_im(:,:,2);
    end
    if isTXRED == 1
        temp(:,:,1) = temp(:,:,1)+ROI_im(:,:,3);
    end
    if isCY5 == 1
        temp(:,:,1) = temp(:,:,1)+ROI_im(:,:,4)./2;
        temp(:,:,3) = temp(:,:,3)+ROI_im(:,:,4)./2;
    end
    for k = 1:3
        temp(:,:,k) = rescale(temp(:,:,k));   
    end
    axes(handles.axes1);
    imshow(temp,[]);
    
    % display all channels' histogram
    cla(handles.Hist,'reset');
    axes(handles.Hist);
    if isDAPI == 1
        [N,edges] = histcounts(ROI_im(:,:,1));
        bar(edges(2:end),N./max(N),'b');hold on;
    end
    if isFITC == 1
        [N,edges] = histcounts(ROI_im(:,:,2));
        bar(edges(2:end),N./max(N),'g');hold on;
    end
    if isTXRED == 1
        [N,edges] = histcounts(ROI_im(:,:,3));
        bar(edges(2:end),N./max(N),'r');hold on;
    end
    if isCY5 == 1
        [N,edges] = histcounts(ROI_im(:,:,4));
        bar(edges(2:end),N./max(N),'m');hold on;
    end
    axis tight;
    set(gca,'FontName','Times New Roman','FontSize',8);
    
    % set all_channel
    if all([isDAPI,isFITC,isTXRED,isCY5]) ~= 1
        set(handles.all_channels,'Value',0);
    else
        set(handles.all_channels,'Value',1);
    end

% --- Executes on button press in isDAPI.
function isDAPI_Callback(hObject, eventdata, handles)
% hObject    handle to isDAPI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% enable all channel button

% Hint: get(hObject,'Value') returns toggle state of isDAPI
display_color_image(hObject, eventdata, handles);

% --- Executes on button press in isFITC.
function isFITC_Callback(hObject, eventdata, handles)
% hObject    handle to isFITC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isFITC
display_color_image(hObject, eventdata, handles);

% --- Executes on button press in isTXRED.
function isTXRED_Callback(hObject, eventdata, handles)
% hObject    handle to isTXRED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isTXRED
display_color_image(hObject, eventdata, handles);

% --- Executes on button press in isCY5.
function isCY5_Callback(hObject, eventdata, handles)
% hObject    handle to isCY5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isCY5
display_color_image(hObject, eventdata, handles);

% --- Executes on button press in all_channels.
function all_channels_Callback(hObject, eventdata, handles)
% hObject    handle to all_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_channels
all_channels=get(handles.all_channels,'Value');
if all_channels==1
    set(handles.isFITC,'Value',1);
    set(handles.isTXRED,'Value',1);
    set(handles.isCY5,'Value',1);
    set(handles.isDAPI,'Value',1);
end
display_color_image(hObject, eventdata, handles);

%% Panel adjustment
% --- Executes on button press in enable_adjust.
function enable_adjust_Callback(hObject, eventdata, handles)
% hObject    handle to enable_adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_adjust
enable_adjust=get(handles.enable_adjust,'Value');

if enable_adjust==1
    set(findall(handles.adjust, '-property', 'Enable'), 'Enable', 'on');
    set(findall(handles.uibuttongroup1, '-property', 'Enable'), 'Enable', 'on');
    
    % plot the transform curve
    MinValue = get(handles.slider3,'Value');
    MaxValue = get(handles.slider4,'Value');
    BrtValue = get(handles.slider5,'Value')*2-1;
    CtsValue = get(handles.slider6,'Value')*10;
    axes(handles.TC);
    x = 0:0.1:1;
    plot(x,BrtValue+CtsValue*x,'k--');
    xlim([0,1]);ylim([0,1]);
    axis tight;title('Transformation curve');
    set(gca,'FontName','Times New Roman','FontSize',8);

end 
% disable the adjustment panel
if enable_adjust==0
    % not reset the adjustment panel
%     set(handles.slider3,'Value',0);
%     set(handles.slider4,'Value',1);
%     set(handles.slider5,'Value',(0+1)/2);
%     set(handles.slider6,'Value',1/10);
%     set(handles.edit24,'String',num2str(0));
%     set(handles.edit25,'String',num2str(1));
%     set(handles.edit26,'String',num2str(0));
%     set(handles.edit27,'String',num2str(1));
    set(findall(handles.adjust, '-property', 'Enable'), 'Enable', 'off');
    set(findall(handles.uibuttongroup1, '-property', 'Enable'), 'Enable', 'off');
    set(handles.enable_adjust,'Enable','on');
    set(handles.enable_adjust,'Value',0);
%     cla(axes(handles.TC));
end

function handles = move_slider(hObject, eventdata, handles)

    % plot the transform curve
    MinValue = get(handles.slider3,'Value');
    MaxValue = get(handles.slider4,'Value');
    BrtValue = get(handles.slider5,'Value')*2-1;
    CtsValue = get(handles.slider6,'Value')*10;
    axes(handles.TC);
    x = 0:0.1:1;
    plot(x,BrtValue+CtsValue*x,'k--');
    xlim([0,1]);ylim([0,1]);
    axis tight;title('Transformation curve');
    set(gca,'FontName','Times New Roman','FontSize',8);
    
    % display the transformed image
    transform_curve = @(x) BrtValue+CtsValue.*x;
 
    ROI_im = handles.data.img_origin;
    ROI_im_show = handles.data.img;
 
    h=get(handles.uibuttongroup1,'SelectedObject');
    current_channel = get(h,'Tag');
    switch current_channel
    case  'DAPI'
        b = ROI_im(:,:,1);
        b = transform_curve(b);
        b(b<MinValue) = 0;
        b(b>MaxValue) = 1;
        ROI_im_show(:,:,1) = b;
        handles.data.img = ROI_im_show;
    case  'FITC'
        g = ROI_im(:,:,2);
        g = transform_curve(g);
        g(g<MinValue) = 0;
        g(g>MaxValue) = 1;
        ROI_im_show(:,:,2) = g;
        handles.data.img = ROI_im_show;
    case  'TXRED'
        r = ROI_im(:,:,3);
        r = transform_curve(r);
        r(r<MinValue) = 0;
        r(r>MaxValue) = 1;
        ROI_im_show(:,:,3) = r;
        handles.data.img = ROI_im_show;
    case  'CY5'
        m = ROI_im(:,:,4); % m = r+b
        m = transform_curve(m);
        m(m<MinValue) = 0;
        m(m>MaxValue) = 1;
        ROI_im_show(:,:,4) = m;
        handles.data.img = ROI_im_show;
    end
    display_color_image(hObject, eventdata, handles);

%% slider
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider3,'Value');
set(handles.edit24,'String',num2str(sliderValue));
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider4,'Value');
set(handles.edit25,'String',num2str(sliderValue));
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider5,'Value');
set(handles.edit26,'String',num2str(sliderValue*2-1));
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider6,'Value');
set(handles.edit27,'String',num2str(10*sliderValue));
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

%% edit
% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double
editValue = str2double(get(handles.edit24,'String'));
set(handles.slider3,'Value',editValue);
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
editValue = str2double(get(handles.edit25,'String'));
set(handles.slider4,'Value',editValue);
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double
editValue = str2double(get(handles.edit26,'String'));
set(handles.slider5,'Value',(editValue+1)/2);
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double
editValue = str2double(get(handles.edit27,'String'));
set(handles.slider6,'Value',editValue/10);
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Set the default values to all components
set(handles.slider3,'Value',0);
set(handles.slider4,'Value',1);
set(handles.slider5,'Value',(0+1)/2);
set(handles.slider6,'Value',1/10);
set(handles.edit24,'String',num2str(0));
set(handles.edit25,'String',num2str(1));
set(handles.edit26,'String',num2str(0));
set(handles.edit27,'String',num2str(1));
handles = move_slider(hObject, eventdata, handles);
guidata(hObject,handles); % Update the guidata

%% Panel save

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.uitable1,'data');
name = handles.data.name;
mkdir annotation % if exist, there will be warning but won't affect running
[file, path] = uiputfile([name '.mat'],'Save Data As');
save([path file],'data')

% --- Executes on button press in add_row.
function add_row_Callback(hObject, eventdata, handles)
% hObject    handle to add_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitable1,'data'); % data format: cell
data{end+1,1} = [];
set(handles.uitable1,'data',data);

%% Three functions asked from Sid

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curname = get(handles.current_file, 'String');
out_all = str2double(regexp(curname,'[\d.]+','match'));
x = out_all(1)-1;
y = out_all(2);
curname2 = ['img_r' num2str(x) '_c' num2str(y) '.mat'];
set(handles.current_file,'String',curname2);

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curname = get(handles.current_file, 'String');
out_all = str2double(regexp(curname,'[\d.]+','match'));
x = out_all(1)+1;
y = out_all(2);
curname2 = ['img_r' num2str(x) '_c' num2str(y) '.mat'];
set(handles.current_file,'String',curname2);

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curname = get(handles.current_file, 'String');
out_all = str2double(regexp(curname,'[\d.]+','match'));
x = out_all(1);
y = out_all(2)-1;
curname2 = ['img_r' num2str(x) '_c' num2str(y) '.mat'];
set(handles.current_file,'String',curname2);

% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curname = get(handles.current_file, 'String');
out_all = str2double(regexp(curname,'[\d.]+','match'));
x = out_all(1);
y = out_all(2)+1;
curname2 = ['img_r' num2str(x) '_c' num2str(y) '.mat'];
set(handles.current_file,'String',curname2);
