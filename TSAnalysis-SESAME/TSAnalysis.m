%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Semi-Automated Surface Wave Two-Station Phase Velocity Dipersion Analysis
% by Huajian Yao, Jan 2007 at MIT
% Note:
% Please do not disclose this program to others! For reference, please use:
% Yao H., van der Hilst R.D., and de Hoop, M.V..Surface-wave array tomography 
% in SE Tibet from ambient seismic noise and two-station analysis : I -
% Phase velocity maps. 2006, Geophysical Journal International, Vol. 166, 732-744, 
% doi: 10.1111/j.1365-246X.2006.03028.x.
% 
% Last modified date: Sep. 17, 2007
% Last modified data: Dec. 19, 2012 
%      for improving the calculation of group (energy) travel time using
%      Gaussian filtering
% Last modified data: Dec. 31, 2012 
%      fixing a bug when resampling data, improve the codes for instrument
%      response removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = TSAnalysis(varargin)
% TSANALYSIS M-file for TSAnalysis.fig
%      TSANALYSIS, by itself, creates a new TSANALYSIS or raises the existing
%      singleton*.
%
%      H = TSANALYSIS returns the handle to a new TSANALYSIS or the handle to
%      the existing singleton*.
%
%      TSANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSANALYSIS.M with the given input arguments.
%
%      TSANALYSIS('Property','Value',...) creates a new TSANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TSAnalysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TSAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TSAnalysis

% Last Modified by GUIDE v2.5 21-Jul-2007 12:23:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TSAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @TSAnalysis_OutputFcn, ...
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


% --- Executes just before TSAnalysis is made visible.
function TSAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TSAnalysis (see VARARGIN)

% Choose default command line output for TSAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TSAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TSAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DataStructCreate

global StationInfo SourceInfo WaveformInfo RecordInfo CrossCorrWaveInfo
global sta src wave rcd_Z filter cross group
global DataDirectory RespDirectory DispDirectory
global MonthDays PrevStaLonLat TBeta


DataDirectory = pwd;
RespDirectory = pwd;
DispDirectory = pwd;
MonthDays = [31 29 31 30 31 30 31 31 30 31 30 31; 31 28 31 30 31 30 31 31 30 31 30 31];
PrevStaLonLat = [0 0;0 0];
TBeta = [1 10 20 40 80 100 150 200 300;15 12 10 8 6 5 4 3 2];

StationInfo = struct('Lon',0,...
	'Lat',0,...
	'GCDkm',0,...
	'GCDdeg',0,...
	'Azim',0,...
    'SampleT',0,...
	'SampleF',0,...
    'Name','');

RecordInfo = struct('YY',0,...
	'DD',0,...
	'HH',0,...
	'MM',0,...
	'SS',0,...
	'MS',0,...
	'DiffT',0,...
    'SampleT',0,...
	'SampleF',0,...
    'NumPt',0,...
    'Time',0);
    
WaveformInfo = struct('DatZ',zeros(1,100),...
    'AmpZ',0);

SourceInfo = struct('Lon',0, ...
	'Lat',0, ...
    'YY',0,...
    'Month',0,...
    'Day',0,...
    'DD',0,...
	'HH',0,...
	'MM',0,...
	'SS',0,...
	'MS',0);

RespInfo = struct('Amp',0,...
    'NumZeros',0,...
    'NumPoles',0,...
    'Zeros',0,...
    'Poles',0,...
    'poly_num',0,...
    'poly_den',0);

FilterInfo = struct('Mode',0,...
    'Domain',0,...
    'Window',0,...
    'CtrT',0,...
    'LowT',0,...
    'HighT',0,...
    'CtrF',0,...
    'LowF',0,...
    'HighF',0,...
    'SampleF',0,...
    'SampleT',0,...
    'Length',0,...
    'BandWidth',0,...
    'KaiserPara',1,...
    'GaussAlfa',2.5);

% Period range and interval for narrow band pass filtered cross correlation
CrossCorrWaveInfo = struct('StartT',0,...
    'EndT',0,...
    'StartF',0,...
    'EndF',0,...
    'DeltaT',0,...
    'DeltaF',0,...
    'NumCtrT',0,...
    'StartNum',0,...
    'EndNum',0,...
    'SENum',0,...
    'PointNum',0,...
    'WaveType',0,...
    'WinCode',0,...
    'HalfBand',0,...
    'wave1',zeros(1,100),...
    'wave2',zeros(1,100),...
    'group1',zeros(100,1),...
    'group2',zeros(100,1),...
    'VMin',0,...
    'VMax',0,...
    'DeltaV',0,...
    'PhasVImg',zeros(100,1));

GroupInfo = struct('ImgStartPt','0',...
    'ImgEndPt','0',...
    'ImgType','0',...
    'ArrPt1',zeros(1,100),...
    'ArrPt2',zeros(1,100),...
    'Velo',zeros(1,100));

sta = struct(StationInfo);
rcd_Z = struct(RecordInfo);
src = struct(SourceInfo);
resp = struct(RespInfo);
wave = struct(WaveformInfo);
cross = struct(CrossCorrWaveInfo);
filter = struct(FilterInfo);
group = struct(GroupInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function TSFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TSFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% call data struct creation function
DataStructCreate;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function  TSFigure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TSFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ClickPoint

ClickPoint = get(handles.axes2, 'CurrentPoint');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function Rd_Sac_ASC : read SAC_ASC format seimic data
function [station, record, ReSampleWave, ampcoef, source] = Rd_Sac_ASC(seisfile)
global StationInfo SourceInfo RecordInfo
station = struct(StationInfo);
source = struct(SourceInfo);
wavedata = zeros(1,100);
ReSampleWave = zeros(1,100);
record = struct(RecordInfo);

fname = fopen(seisfile,'r');

% read line 1
station.SampleT = fscanf(fname,'%f',1);
station.SampleF = 1/station.SampleT;
record.SampleT = station.SampleT;
record.SampleF = station.SampleF;
temp = fscanf(fname, '%f', 2);
ampcoef = fscanf(fname, '%e', 1);
temp = fgetl(fname);

% read line 2
temp = fscanf(fname, '%f', 2);
tempdata = fscanf(fname, '%f', 1);
if tempdata ~= -12345
    record.DiffT = tempdata;
end
temp1 = fgetl(fname);

% skip 3 - 6 line
for i = 1:4
	temp1 = fgetl(fname);
end

% read 7 line
temp2 = fscanf(fname,'%f',1);
station.Lat = fscanf(fname, '%f', 1);
station.Lon = fscanf(fname, '%f', 1);
temp1 = fgetl(fname);

% read 8 line
source.Lat = fscanf(fname, '%f', 1);
source.Lon = fscanf(fname, '%f', 1);
temp1 = fgetl(fname);

% skip 9 - 10 line
for i = 1:2
	temp1 = fgetl(fname);
end

% read 11 line
station.GCDkm = fscanf(fname, '%f', 1);
station.Azim = fscanf(fname, '%f', 1);
temp2 = fscanf(fname,'%f',1);
station.GCDdeg = fscanf(fname,'%f',1);	
temp1 = fgetl(fname);

% skip 12 - 14 line
for i = 1:3
	temp1 = fgetl(fname);
end

% read the time of recording the seismic data ( 15 16 line )
record.YY = fscanf(fname,'%f',1);
record.DD = fscanf(fname,'%f',1);
record.HH = fscanf(fname,'%f',1);
record.MM = fscanf(fname,'%f',1);
record.SS = fscanf(fname,'%f',1);
record.MS = fscanf(fname,'%f',1);
temp = fscanf(fname, '%f', 3);
record.NumPt = fscanf(fname,'%f',1);	
temp1 = fgetl(fname);

% skip 17 - 22
for i =1:6
   temp1 = fgetl(fname);
end

% read name of the station (line 23)
station.Name = fscanf(fname,'%s',1);
temp1 = fgetl(fname);

% skip 24 - 30
for i =1:7
   temp1 = fgetl(fname);
end

% read seismic data file, NumSeisPoint is the total point of seismic data
wavedata = fscanf(fname,'%f',inf);  
record.NumPt = size(wavedata,1);
fclose(fname);

record.Time = (record.NumPt - 1)*station.SampleT;

% remove the trend of the waveform
wavedata(1:record.NumPt) = detrend(wavedata(1:record.NumPt));


% resampling waveform from broadband data (e.g., 20 Hz) to long period data (1 Hz)
if station.SampleF > 1
    DecimateR = station.SampleF; 
    nn = floor(record.NumPt/DecimateR);
    if (nn*DecimateR+1) <= record.NumPt
        ReSampleWave = decimate(wavedata(1:nn*DecimateR+1), DecimateR);
    else
        ReSampleWave = decimate([wavedata(1:nn*DecimateR); wavedata(nn*DecimateR)], DecimateR);
    end    
    % ReSampleWave = decimate(wavedata, DecimateR);
    station.SampleF = 1;
    station.SampleT = 1;
    record.SampleT = 1;
    record.SampleF = 1;
    record.NumPt = length(ReSampleWave);
else
    ReSampleWave = wavedata;
end

if max(ReSampleWave)>0
    ReSampleWave = ReSampleWave/max(ReSampleWave);
end

record.Time = (record.NumPt - 1)*record.SampleT;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SeisData,HdrData]=readsac_Simons(filename,plotornot)
% [SeisData,HdrData]=READSAC(filename,plotornot)
% Reads in data saved from within SAC and plots or not (plotornot = 1: plot)
% SeisData is the seismic data
% HdrData contains information about the earthquake and receiver
% modified by FJS April 23th 1998
% last modified by Huajian Yao 2007

ppath=matlabpath;
    fid=fopen(filename,'rb');
    
if fid==-1
  error([ 'File ',filename,' does not exist in current path ',pwd]);
end
HdrFloats=fread(fid,70,'float32');
HdrNhdr=fread(fid,15,'int32');
HdrIhdr=fread(fid,20,'int32');
HdrLhdr=fread(fid,5,'int32');
HeaderStrings=str2mat(fread(fid,[8 24],'char'))';
SeisData=fread(fid,HdrNhdr(10),'float32');
fclose(fid);

HdrData=struct(...
  'NPTS',HdrNhdr(10),...                    % number of points
  'DELTA',HdrFloats(1),...                  % sampling time
  'SCALE',HdrFloats(4),...                  % amplitude scaling factor
  'B',HdrFloats(6),...                      % begin time of record
  'E',HdrFloats(7),...                      % end time of record
  'O',HdrFloats(8),...                      % event origin time (seconds relative to reference recording time)
  'KZYEAR',HdrNhdr(1),...                   % year
  'KZJDAY',HdrNhdr(2),...                   % julian day
  'KZHOUR',HdrNhdr(3),...                   % hour
  'KZMIN',HdrNhdr(4),...                    % minute
  'KZSEC',HdrNhdr(5),...                    % second
  'KZMSEC',HdrNhdr(6),...                   % milisecond
  'KSTNM',deblank(HeaderStrings(1,:)),...   % station name
  'KCMPNM',deblank(HeaderStrings(21,:)),... % recording component
  'KNETWK',deblank(HeaderStrings(22,:)),... % station network      
  'KINST',deblank(HeaderStrings(24,:)),...  % generic name of recording instrument  
  'STLA',HdrFloats(32),...                  % station latitude
  'STLO',HdrFloats(33),...                  % station longitude
  'STEL',HdrFloats(34),...                  % station elevation
  'EVLA',HdrFloats(36),...                  % event latitude
  'EVLO',HdrFloats(37),...                  % event longitude
  'EVDP',HdrFloats(39),...                  % event depth
  'DIST',HdrFloats(51),...                  % epicentral distance in km
  'AZ',HdrFloats(52),...                    % azimuth
  'BAZ',HdrFloats(53),...                   % back azimuth
  'GCARC',HdrFloats(54));                   % epicentral distance in degrees between source and receiver

if plotornot==1
  plot(linspace(HdrData.B,HdrData.E,HdrData.NPTS),SeisData);  
  title([filename]);
  xlabel([ 'Time (s)']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [station, record, ReSampleWave, ampcoef, source] = DataStructTrans_Simons(SeisData, HdrData)
global StationInfo SourceInfo RecordInfo
station = struct(StationInfo);
source = struct(SourceInfo);

record = struct(RecordInfo);
station.Lat = HdrData.STLA;
station.Lon = HdrData.STLO;
station.GCDkm = HdrData.DIST;
station.GCDdeg = HdrData.GCARC;
station.Azim = HdrData.AZ;
station.SampleT = HdrData.DELTA;
station.SampleF = 1/station.SampleT;
station.Name = HdrData.KSTNM;

record.YY = HdrData.KZYEAR;
record.DD = HdrData.KZJDAY;
record.HH = HdrData.KZHOUR;
record.MM = HdrData.KZMIN;
record.SS = HdrData.KZSEC;
record.MS = HdrData.KZMSEC;
record.DiffT = HdrData.O;
record.NumPt = HdrData.NPTS;
record.SampleT = station.SampleT;
record.SampleF = station.SampleF;

source.Lat = HdrData.EVLA;
source.Lon = HdrData.EVLO;

SeisData(1:record.NumPt) = detrend(SeisData(1:record.NumPt));
record.Time = (record.NumPt - 1)*station.SampleT;

if station.SampleF > 1
    DecimateR = round(station.SampleF); 
    nn = floor(record.NumPt/DecimateR);
    if (nn*DecimateR+1) <= record.NumPt
        ReSampleWave = decimate(SeisData(1:nn*DecimateR+1)', DecimateR);
    else
        ReSampleWave = decimate([SeisData(1:nn*DecimateR)'; SeisData(nn*DecimateR)], DecimateR);
    end    

    % ReSampleWave = decimate(SeisData', DecimateR);
    station.SampleF = 1;
    station.SampleT = 1;
    record.SampleT = 1;
    record.SampleF = 1;
    record.NumPt = length(ReSampleWave);
else
    ReSampleWave = SeisData';
end
ReSampleWave = ReSampleWave/max(ReSampleWave);
ampcoef = HdrData.SCALE;

record.Time = (record.NumPt - 1)*station.SampleT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [station, record, ReSampleWave, ampcoef, source] = DataStructTrans(HdrData)
global StationInfo SourceInfo RecordInfo
station = struct(StationInfo);
source = struct(SourceInfo);

record = struct(RecordInfo);
station.Lat = HdrData.STLA;
station.Lon = HdrData.STLO;
station.GCDkm = HdrData.DIST;
station.GCDdeg = HdrData.GCARC;
station.Azim = HdrData.AZ;
station.SampleT = HdrData.DELTA;
station.SampleF = 1/station.SampleT;
station.Name = HdrData.KSTNM;

record.YY = HdrData.NZYEAR;
record.DD = HdrData.NZJDAY;
record.HH = HdrData.NZHOUR;
record.MM = HdrData.NZMIN;
record.SS = HdrData.NZSEC;
record.MS = HdrData.NZMSEC;
record.DiffT = HdrData.O;
record.NumPt = HdrData.NPTS;
record.SampleT = station.SampleT;
record.SampleF = station.SampleF;

source.Lat = HdrData.EVLA;
source.Lon = HdrData.EVLO;

% offset = mean(SeisData(1:record.NumPt));
SeisData(1:record.NumPt) = detrend(HdrData.DATA1(1:record.NumPt));
record.Time = (record.NumPt - 1)*station.SampleT;

if station.SampleF > 1
    DecimateR = round(station.SampleF); 
    nn = floor(record.NumPt/DecimateR);
    if (nn*DecimateR+1) <= record.NumPt
        ReSampleWave = decimate(SeisData(1:nn*DecimateR+1)', DecimateR);
    else
        ReSampleWave = decimate([SeisData(1:nn*DecimateR)'; SeisData(nn*DecimateR)], DecimateR);
    end    

    % ReSampleWave = decimate(SeisData', DecimateR);
    station.SampleF = 1;
    station.SampleT = 1;
    record.NumPt = length(ReSampleWave);
    record.SampleT = 1;
    record.SampleF = 1;
else
    ReSampleWave = SeisData';
end
ReSampleWave = ReSampleWave/max(ReSampleWave);
ampcoef = HdrData.SCALE;
record.Time = (record.NumPt - 1)*station.SampleT;

station;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in StationFileInput.
%     read all stations information
function StationFileInput_Callback(hObject, eventdata, handles)
% hObject    handle to StationFileInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allsta

[pfile1, pname1, index] = uigetfile({'*.txt';'*.dat';'*.*'},'Open file containing all stations information', pwd);
files = strcat(pname1,pfile1);

fstat = fopen(files,'r');
allsta = struct('name', {}, 'net', {}, 'lat', {}, 'lon', {});
% read stations
i=1;
while ~feof(fstat)
	   allsta(i).name = fscanf(fstat,'%s',1); %station name
	   allsta(i).net = fscanf(fstat,'%s',1); %station network
	   allsta(i).lat = fscanf(fstat,'%f',1); %station longitude
	   allsta(i).lon = fscanf(fstat,'%f',1); %station latitude       
       temp = fgetl(fstat);
      i=i+1;
end
fclose(fstat);

%plot topography, coast, and all stations
PlotAllStations(allsta, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot topography, coast, and all stations
function PlotAllStations(allsta, handles)

h1 = handles.axes1;
hold(h1,'off');
set(gcf,'CurrentAxes',h1)
load topomap
x=linspace(0,360,1080);
y=linspace(-90,90,2160);
[cmap clim] = demcmap(topomap);
hold on
imagesc(x,y,topomap,clim);%colorbar('vert');
colormap(cmap);axis image; grid on; axis on;

load coastlines % the coast line is lat, long
kk = find(coastlon < 0);
coastlon(kk) = 360 - abs(coastlon(kk));
ii = find( abs(coastlon) < 0.5);
coastlon(ii) = NaN;
coastlat(ii) = NaN;
hold(h1,'on');
plot(h1, coastlon,coastlat,'k', 'LineWidth',2);
set(gca,'ydir','normal');
set(gca,'FontSize',16,'FontWeight','bold');
axis equal

stanum = length(allsta);
for i = 1:stanum
    Lon(i) = allsta(i).lon;
    Lat(i) = allsta(i).lat;
    hold(h1, 'on');
    plot(h1, allsta(i).lon, allsta(i).lat, 'k^', 'MarkerSize',6, 'MarkerFaceColor','k');
end

ExtraLon = 0.1*(max(Lon)-min(Lon));
ExtraLat = 0.1*(max(Lat)-min(Lat));
ExtraLon = min(ExtraLon, 1);
ExtraLat = min(ExtraLat, 1);
xlim(h1,[min(Lon)-ExtraLon max(Lon)+ExtraLon]);
ylim(h1,[min(Lat)-ExtraLat max(Lat)+ExtraLat]);
set(gca, 'XTickMode','auto','YTickMode','auto');
% title('Station Location', 'FontSize',16,'FontWeight','bold');
stanum=i-1;

set(handles.MsgEdit,'String','Read Stations Information Successfully!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in RespFileInput.
 %    Open file containing all response data file names
function RespFileInput_Callback(hObject, eventdata, handles)
% hObject    handle to RespFileInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global RespDirectory allresp
allresp = struct('fname', '', 'staname', '');

if RespDirectory == 0
    RespDirectory = pwd;
end

[pfile1, pname1, index] = uigetfile({'*.txt';'*.dat';'*.*'},'Open file containing all Response file names', RespDirectory);
files = strcat(pname1,pfile1);
RespDirectory = pname1;

respdir = pname1;

frf = fopen(files);

i = 1;
while ~feof(frf)
    name = fscanf(frf, '%s', 1);
    if ~strcmp(name,'')
        allresp(i).fname = name;
%         allresp(i).staname = allresp(i).fname(9:end-7);    
        tmpchar = allresp(i).fname(1:end);
        index = 1;
        Pt = zeros(1,8);
        for j = 1:length(tmpchar)
            if strcmp(tmpchar(j),'.')==1
                Pt(index) = j;
                index = index+1;
            end           
        end
        allresp(i).staname = tmpchar((Pt(2)+1):(Pt(3)-1));
        i = i+1;
    else
        break
    end
end
respnum = length(allresp);

fclose(frf);

set(handles.MsgEdit,'String','Read Stations Response Information Successfully!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in WaveformFileInput.
 %    Open file containing all waveform file names
function WaveformFileInput_Callback(hObject, eventdata, handles)
% hObject    handle to WaveformFileInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataDirectory src MonthDays evdata allsta g_SAC_ASCIndex

stanum = length(allsta);

evdata = struct('fname', '', 'staname', '');

if DataDirectory == 0
    DataDirectory = pwd;
end

[pfile1, pname1, index] = uigetfile({'*.txt';'*.dat';'*.*'},'Open file containing all data file names', DataDirectory);
files = strcat(pname1,pfile1);
DataDirectory = pname1;

prompt = {'Please enter your waveform type (SAC or SAC_ASC)'};
title = ['Data format'];
datatype = questdlg('Please select input data format (SAC or SAC_ASC):','Data Format', 'SAC', 'SAC_ASC', 'SAC_ASC');
if strcmp(datatype, 'SAC')
    g_SAC_ASCIndex = 1;
elseif strcmp(datatype, 'SAC_ASC')
    g_SAC_ASCIndex = 2;
end

							
datadir = pname1;

fname = fopen(files);

% read weed format event information
temp = fscanf(fname, '%s', 1);
temp = fscanf(fname, '%s', 1);
src.YY = str2num(temp(1:4));
Month = str2num(temp(6:7));
Day = str2num(temp(9:10));
src.Month = Month;
src.Day = Day;
if mod(src.YY, 4) == 0  
    src.DD = sum(MonthDays(1,1:(Month - 1))) + Day;
else
    src.DD = sum(MonthDays(2,1:(Month - 1))) + Day;  
end
temp = fscanf(fname, '%s', 1);
src.HH = str2num(temp(1:2));
src.MM = str2num(temp(4:5));
src.SS = str2num(temp(7:8));
src.MS = 10*str2num(temp(10:11));
temp = fscanf(fname, '%s', 1);
mchar = size(temp,2);
src.Lat = str2num(temp(1:(mchar - 1)));
temp = fscanf(fname, '%s', 1);
mchar = size(temp,2);
src.Lon = str2num(temp(1:(mchar - 1)));
temp = fscanf(fname, '%s', 4);
temp = fscanf(fname, '%s', 1);
mchar = size(temp,2);
if strcmp(temp(mchar),',') == 1        
    srcmag = str2num(temp(1:(mchar - 1)));
else
    srcmag = str2num(temp(1:mchar));
end
temp = fgetl(fname);
   
i = 1;
while ~feof(fname)
    name = fscanf(fname, '%s', 1);
    if ~strcmp(name,'')
        evdata(i).fname = name;
        
        %tmpchar = evdata(i).fname(25:32);
        tmpchar = evdata(i).fname(3:8);
        index = 1;
        Pt = zeros(1,8);
        for j = 1:length(tmpchar)
            if strcmp(tmpchar(j),'.')==1
                Pt(index) = j;
                index = index+1;
            end           
        end
        evdata(i).staname = tmpchar((Pt(1)+1):(Pt(2)-1));        
        i =  i+1;
    else
        break
    end
end
filenum = length(evdata);
fclose(fname);
set(handles.EditSrcLon,'String',num2str(src.Lon));
set(handles.EditSrcLat,'String',num2str(src.Lat));
PlotAllStations(allsta, handles);
PlotEveStations(evdata, allsta, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotEveStations(evdata, allsta, handles);

h1 = handles.axes1;
hold(h1,'on');
set(gcf,'CurrentAxes',h1);

filenum = length(evdata);
stanum = length(allsta);
for i = 1:filenum
    % get station lat and lon from station name
    for kk = 1:stanum        
        if strcmp(evdata(i).staname,allsta(kk).name)
            stalat = allsta(kk).lat;
            stalon = allsta(kk).lon;
            hold(h1, 'on');
            plot(h1, stalon, stalat, 'r^', 'MarkerSize',8, 'MarkerFaceColor','r');
            hold(h1, 'on');
            text(stalon, stalat, evdata(i).staname, 'FontSize',8);
            break
        end
    end
end

set(handles.MsgEdit,'String','Read Waveform Data File List Successfully!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in Makefilter.
function Makefilter_Callback(hObject, eventdata, handles)
% hObject    handle to Makefilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global filter sta TBeta    
filter.Domain = get(handles.Filter_domain,'Value');
filter.Window = get(handles.Win_type,'Value');

% if  filter.SampleF == 0
% %     errordlg('No data sampling frequency information! Please check it!');
    prompt = {'Please enter your data sampling frequency (Hz):'};
    title = ['Data Sampling Frequency'];
    line = 2;
    DataSPF = inputdlg(prompt,title,line);
    filter.SampleF = str2num(DataSPF{1});
    filter.SampleT = 1/filter.SampleF;
% end

switch filter.Domain
    case 1
		prompt = {'Enter Band_Pass_Filter Test Central Period (e.g. 40 s):',
            'Enter Band_Pass_Filter Band Width (e.g. 1 s):'};
		title = ['Set Filter Parameter'];
		line = 2; 
		FilterPara = inputdlg(prompt,title,line);
        filter.CtrT = str2num(FilterPara{1});
        filter.BandWidth = str2num(FilterPara{2});
        filter.CtrF = (2/filter.SampleF)/filter.CtrT;
        filter.LowF = (2/filter.SampleF)/(filter.CtrT + 0.5*filter.BandWidth);
        filter.HighF = (2/filter.SampleF)/(filter.CtrT - 0.5*filter.BandWidth);    
    case 2
		prompt = {'Enter Band_Pass_Filter Test Central Frequency (e.g. 0.02 HZ):',
            'Enter Band_Pass_Filter Band Width (e.g. 0.005 HZ):'};
		title = ['Set Filter Parameter']; 
		line = 2; 
		FilterPara = inputdlg(prompt,title,line);
        filter.CtrF = str2num(FilterPara{1});
        filter.BandWidth = str2num(FilterPara{2});
        filter.LowF = (2/filter.SampleF)*(filter.CtrF - 0.5*filter.BandWidth);
        filter.HighF = (2/filter.SampleF)*(filter.CtrF + 0.5*filter.BandWidth);
end

switch filter.Window
    case 1
        prompt = {'Please input beta value of Kaiser window (e.g.: 5-10) (Increasing beta widens the main lobe and decreases the amplitude of the sidelobes'};
        title = ['Kaiser Window Parameter'];
        line = 2;
        KaiserBeta = inputdlg(prompt,title,line);
        filter.KaiserPara = str2num(KaiserBeta{1});   
    case 2
        prompt = {'Please input alfa value of Gaussian window (e.g.: 2-6) (Increasing alfa widens the main lobe and decreases the amplitude of the sidelobes'};
        title = ['Gaussian Window Parameter'];
        line = 2;
        GaussAlfa = inputdlg(prompt,title,line);
        filter.GaussAlfa = str2num(GaussAlfa{1});                
end        

% % define filter.KaiserPara according to filter.CtrT (central period of filtering)        
% filter.KaiserPara = interp1(TBeta(1,:), TBeta(2,:), filter.CtrT, 'cubic');

filter.Length = max(1024*filter.SampleF, round(6*filter.CtrT*filter.SampleF));

if filter.Window == 1   % Kaiser Window
    filter.Data = fir1(filter.Length, [filter.LowF, filter.HighF], kaiser(filter.Length + 1,filter.KaiserPara));
elseif filter.Window == 2   % Gaussian Window
    filter.Data = fir1(filter.Length, [filter.LowF, filter.HighF], gausswin(filter.Length + 1,filter.GaussAlfa));
end

wvtool(filter.Data);

set(handles.MsgEdit,'String','Make Band-pass Filter Successfully!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in DisperFolder.
function DisperFolder_Callback(hObject, eventdata, handles)
% hObject    handle to DisperFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DispDirectory

DispDirectory = uigetdir(pwd, 'Select folder to save dispersion data:');
set(handles.MsgEdit,'String',['Dispersion data folder is: ',DispDirectory]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in StartDataProcessing.
function StartDataProcessing_Callback(hObject, eventdata, handles)
% hObject    handle to StartDataProcessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sta wave rcd_Z src
global DataDirectory RespDirectory
global allsta evdata allresp g_SAC_ASCIndex
global PrevStaLonLat

stanum = length(allsta);
respnum = length(allresp);
filenum = length(evdata);

if sum(sum(PrevStaLonLat)) ~= 0
    PlotAllStations(allsta, handles);
    PlotEveStations(evdata, allsta, handles);
    PrevStaLonLat = [0 0;0 0];
end

h2 = handles.axes2;

set(handles.StopDataProcessing,'Value',0)

if get(handles.ProcessAllData, 'Value')
    
    StartIndex1 = 1;
    EndIndex1 = filenum - 1;
    EndIndex2 = filenum;
    set(handles.DataStartIndex1, 'String', num2str(StartIndex1));
    set(handles.DataStartIndex2, 'String', 'i+1');
    set(handles.DataEndIndex1, 'String', num2str(EndIndex1));
    set(handles.DataEndIndex2, 'String', num2str(EndIndex2));
else
    StartIndex1 = str2num(get(handles.DataStartIndex1, 'String'));
    StartIndex2 = str2num(get(handles.DataStartIndex2, 'String'));
    EndIndex1 = str2num(get(handles.DataEndIndex1, 'String'));
    EndIndex2 = str2num(get(handles.DataEndIndex2, 'String'));
end


for i = StartIndex1:EndIndex1

    set(handles.MsgEdit,'String',['First Statio Index = ' num2str(i)]);
    if get(handles.StopDataProcessing,'Value')
       set(handles.MsgEdit,'String','Data Processing Stopped!');
       break
    end    
    
    if get(handles.ProcessAllData, 'Value')
        StartIndex2 = i + 1;
    else
        if strcmp('i+1',get(handles.DataStartIndex2, 'String'))
            StartIndex2 = i + 1;
        end
    end
    
    for j = StartIndex2:EndIndex2

        if get(handles.StopDataProcessing,'Value')
            break
        end
        % get station lat and lon from station name
        for kk = 1:stanum
            if strcmp(evdata(i).staname,allsta(kk).name)
                stalat1 = allsta(kk).lat;
                stalon1 = allsta(kk).lon;
            end
            if strcmp(evdata(j).staname,allsta(kk).name)
                stalat2 = allsta(kk).lat;
                stalon2 = allsta(kk).lon;
            end            
        end
        
        % judge whether the event and two stations are satisfying two-station criterion
        if deg2km(distance(stalat1,stalon1,stalat2,stalon2)) > 1  % to avoid the same (or nearly the same) two stations
            isTSpath = IsAlongTSGCPath(src.Lat, src.Lon, stalat1, stalon1, stalat2, stalon2, hObject, handles);
        else
            isTSpath = 0;
            % set(handles.MsgEdit,'String',[evdata(i).staname '-' evdata(j).staname ': not a qualified two-station path']);
            display([evdata(i).staname '-' evdata(j).staname ': not a qualified two-station path']);
        end

        if isTSpath == 1
            
            seisfile1 = strcat(DataDirectory, evdata(i).fname);
            seisfile2 = strcat(DataDirectory, evdata(j).fname);
            display('The two station data files: ');
            display(['  1:  ' evdata(i).fname]);
            display(['  2:  ' evdata(j).fname]);
            
            % read data for two station 
            RdTwoStaData(seisfile1, seisfile2, g_SAC_ASCIndex);
                        
            SumAmp1 = sum(abs(wave(1).DatZ(1:end)));
            SumAmp2 = sum(abs(wave(2).DatZ(1:end)));
            if min(SumAmp1,SumAmp2) > 0
                set(gcf,'CurrentAxes',h2);
                
%                 hold off;
%                 plot(wave(1).DatZ/max(wave(1).DatZ),'r');
%                 hold on;
%                 plot(wave(2).DatZ/max(wave(2).DatZ)+2);
                
                % updata message box information
                UpdataMsgBoxInfo(hObject, eventdata, handles);
%                 set(gcf,'CurrentAxes',h2);
%                 hold(h2,'off');
%                 plot(h2, -rcd_Z(1).DiffT+(0:(rcd_Z(1).NumPt-1))*sta(1).SampleT, wave(1).DatZ+1,'b');
%                 hold(h2,'on')
%                 plot(h2, -rcd_Z(2).DiffT+(0:(rcd_Z(2).NumPt-1))*sta(2).SampleT, wave(2).DatZ, 'b');

                % main function for two-station data processing
                TSDataProcessing(hObject, eventdata, handles);
                set(handles.MsgEdit,'String','Data Processing is continuing!');

                pause(0.5)

            end
            
        end
        
    end
end

set(handles.MsgEdit,'String','Data Processing Finished!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to judge whether the earthquake is almost on the interstation great
% circle path with alfa < selminangle1 (e.g. 3 deg), beta < selminangle2 (e.g. 6 deg), 
% please refer to Yao et al.,2006, GJI paper for the detail illustration of angles alfa and beta
% And minimum event-station distance is MinEveStaDist (e.g.,1000 km) and
% minimum differential distance from event to two stations is MinDiffDist
% (e.g., 50 km)
function isTSpath = IsAlongTSGCPath(eventlat, eventlon, rstalat1, rstalon1, rstalat2, rstalon2, hObject, handles)

srdist1 = deg2km(distance([eventlat, eventlon], [rstalat1, rstalon1]));
srdist2 = deg2km(distance([eventlat, eventlon], [rstalat2, rstalon2]));
MinEveStaDist = 1000;  % minimum event to station distance
MinDiffDist = 50;      % minimum differential distance from event to two stations

if min(srdist1, srdist2) >= MinEveStaDist && abs(srdist1 - srdist2) >= MinDiffDist
    selminangle1 = str2num(get(handles.IsTSPathAlfa,'String'));
    selminangle2 = str2num(get(handles.IsTSPathBeta,'String'));

    az1 = azimuth([eventlat, eventlon], [rstalat1, rstalon1]);
    az2 = azimuth([eventlat, eventlon], [rstalat2, rstalon2]);

    if srdist2 > srdist1
        az3 = azimuth([rstalat1, rstalon1], [rstalat2, rstalon2]);
        az4 = azimuth([rstalat1, rstalon1], [-eventlat, eventlon+180]);
    else
        az3 = azimuth([rstalat2, rstalon2], [rstalat1, rstalon1]);
        az4 = azimuth([rstalat2, rstalon2], [-eventlat, eventlon+180]);
    end

    angle1 = min(abs(az1-az2), abs(abs(az1-az2)-360));
    angle2 = min(abs(az3-az4), abs(abs(az3-az4)-360));

    % on a great cirle(deviation angles alpha & beta less than selminangle degrees)
    if angle1 <= selminangle1 && angle2 <= selminangle2    
        isTSpath = 1;
    else
        isTSpath = 0;
    end
else
    isTSpath = 0;
end
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read data for two stations
function RdTwoStaData(seisfile1, seisfile2, Index_SAC_ASC)
global sta wave rcd_Z src source
global SourceInfo
source = struct(SourceInfo);

if Index_SAC_ASC == 1
    % for SAC format
%     [SeisData,HdrData]=readsac(seisfile1,0);
%     [sta(1), rcd_Z(1), wave(1).DatZ, wave(1).AmpZ, source] = DataStructTrans_Simons(SeisData, HdrData);
%     [SeisData,HdrData]=readsac(seisfile2,0);
%     [sta(2), rcd_Z(2), wave(2).DatZ, wave(2).AmpZ, source] = DataStructTrans_Simons(SeisData, HdrData);
    S = readsac(seisfile1);
    [sta(1), rcd_Z(1), wave(1).DatZ, wave(1).AmpZ, source] = DataStructTrans(S);
    S = readsac(seisfile2);
    [sta(2), rcd_Z(2), wave(2).DatZ, wave(2).AmpZ, source] = DataStructTrans(S);
   
elseif Index_SAC_ASC == 2
    % for SAC_ASC format
    [sta(1), rcd_Z(1), wave(1).DatZ, wave(1).AmpZ, source] = Rd_Sac_ASC(seisfile1);
    [sta(2), rcd_Z(2), wave(2).DatZ, wave(2).AmpZ, source] = Rd_Sac_ASC(seisfile2);
end

for i = 1:2
   % sta(i)
    if (sta(i).GCDkm == -12345) || (sta(i).Azim == -12345) || isnan(sta(i).GCDkm ) || isnan(sta(i).Azim)
        sta(i).GCDkm = deg2km(distance([src.Lat,src.Lon],[sta(i).Lat,sta(i).Lon]));
        sta(i).Azim = azimuth([src.Lat,src.Lon],[sta(i).Lat,sta(i).Lon]);
    end
end

for i = 1:2
    if mod(rcd_Z(i).YY, 4) == 0  
        YearDays = 366;
    else
        YearDays = 365;  
    end            

    DeltaTSrcSta = 0;
    if src.YY == rcd_Z(i).YY
        DeltaTSrcSta = (src.DD - rcd_Z(i).DD)*24*3600;
    elseif src.YY == rcd_Z(i).YY + 1  
        DeltaTSrcSta = (src.DD + YearDays - rcd_Z(i).DD)*24*3600;
    else
        display('Year Error!');
        break
    end
    DeltaTSrcSta = DeltaTSrcSta + (src.HH - rcd_Z(i).HH)*3600 + (src.MM - rcd_Z(i).MM)*60; 
    DeltaTSrcSta = DeltaTSrcSta + (src.SS - rcd_Z(i).SS) + (src.MS - rcd_Z(i).MS)/1000;
    rcd_Z(i).DiffT = DeltaTSrcSta;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % updata message box information
function UpdataMsgBoxInfo(hObject, eventdata, handles)
global src sta
set(handles.EditSrcLon,'String',num2str(src.Lon));
set(handles.EditSrcLat,'String',num2str(src.Lat));

if sta(1).GCDkm < sta(2).GCDkm
    set(handles.EditNameSta1,'String',num2str(sta(1).Name));
    set(handles.EditNameSta2,'String',num2str(sta(2).Name));
    set(handles.EditLonSta1,'String',num2str(sta(1).Lon));
    set(handles.EditLonSta2,'String',num2str(sta(2).Lon));
    set(handles.EditLatSta1,'String',num2str(sta(1).Lat));
    set(handles.EditLatSta2,'String',num2str(sta(2).Lat));
    set(handles.EditSrcStaDist1,'String',num2str(round(sta(1).GCDkm)));
    set(handles.EditSrcStaDist2,'String',num2str(round(sta(2).GCDkm)));
    set(handles.EditSrcStaAzim1,'String',num2str(sta(1).Azim));
    set(handles.EditSrcStaAzim2,'String',num2str(sta(2).Azim));
else
    set(handles.EditNameSta1,'String',num2str(sta(2).Name));
    set(handles.EditNameSta2,'String',num2str(sta(1).Name));
    set(handles.EditLonSta1,'String',num2str(sta(2).Lon));
    set(handles.EditLonSta2,'String',num2str(sta(1).Lon));
    set(handles.EditLatSta1,'String',num2str(sta(2).Lat));
    set(handles.EditLatSta2,'String',num2str(sta(1).Lat));
    set(handles.EditSrcStaDist1,'String',num2str(round(sta(2).GCDkm)));
    set(handles.EditSrcStaDist2,'String',num2str(round(sta(1).GCDkm)));
    set(handles.EditSrcStaAzim1,'String',num2str(sta(2).Azim));
    set(handles.EditSrcStaAzim2,'String',num2str(sta(1).Azim));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main function for two-station data processing
function TSDataProcessing(hObject, eventdata, handles)

% 1. remove instrument response
RmInstruResponse(hObject, handles);
set(handles.MsgEdit,'String','Instrument Response Removed!');

% 2. get group image and group arrival
ProcessIndex = GroupImageArrival(hObject, handles);
set(handles.MsgEdit,'String','Group arrival determined');

% 3. moving window the waves with respect to the group arrival and do
% cross-correlation at each narrow period band

if ProcessIndex == 1  % continue processing
   CrossCorrelation(hObject, handles);
end
set(handles.MsgEdit,'String','Cross-correlation finished');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. remove instrument response
function RmInstruResponse(hObject, handles)
% hObject    handle to Instru_resp1 (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
global sta resp rcd_Z wave RespDirectory
global allresp

h2 = handles.axes2;

respnum = length(allresp);
RespFile = cell(1,2);
IndexRespFile = zeros(1,2);
display('The two station response files: ');
for k = 1:2
    for i = 1:respnum
        if strcmp(allresp(i).staname,sta(k).Name)
            RespFile{k} = strcat(RespDirectory, allresp(i).fname);
            IndexRespFile(k) = 1;
            display(['  ' num2str(k) ':  ' allresp(i).fname]);
            break;
        end
    end
end            

if IndexRespFile(1) == 0  
    display('Error: response file for station 1 is not existing!');
end
if IndexRespFile(2) == 0 
    display('Error: response file for station 2 is not existing!');
end
    
%% remove instrument response and bandpass filtering
for k = 1:2
    
    [resp(k).Amp, resp(k).Numzeroes, resp(k).Numpoles, resp(k).Zeros, resp(k).Poles] = Rd_InstruRespFile(RespFile{k});
    [resp(k).poly_num, resp(k).poly_den] = zp2tf(resp(k).Zeros', resp(k).Poles', resp(k).Amp);
    
    if mod(rcd_Z(k).NumPt,2) == 1
        rcd_Z(k).NumPt = rcd_Z(k).NumPt + 1;
        wave(k).DatZ(rcd_Z(k).NumPt) = 0;
    end
    fftlength = rcd_Z(k).NumPt;
    fftdata = fft(wave(k).DatZ, fftlength);
    
    f(1:(fftlength/2+1)) = sta(k).SampleF*(0:(fftlength/2))/fftlength;

    % The band pass filtering: [TMin TLow THigh TMax] <-> [0.0 1.0 1.0 0.0]

    TLow = 0.8*str2double(get(handles.StartPeriod,'String'));  % 
    TMin = 0.5*str2double(get(handles.StartPeriod,'String'));  % shortest period for bandpass filtering and response removal

    THigh = 1.2*str2double(get(handles.EndPeriod,'String'));
    TMax = 1.5*str2double(get(handles.EndPeriod,'String')); % longest period for lowpass filtering and response removal

    HighF = 1/TLow;  % high pass freq
    HighFMax = min(1/TMin, sta(k).SampleF/2); % highest freq for reponse removal

    LowF = 1/THigh;   % low pass freq
    LowFMin = max(1/TMax, 0); % lowest freq for response removal
    
%     figure
%     subplot(2,1,1), plot(f(1:(fftlength/2+1)), abs(fftdata(1:(fftlength/2+1))));
%     subplot(2,1,2),plot(f(1:(fftlength/2+1)), angle(fftdata(1:(fftlength/2+1))));
   
    delta_f = sta(k).SampleF/fftlength;
    w(1:(fftlength/2+1)) = 2*pi*f(1:(fftlength/2+1));
    h = freqs(resp(k).poly_num, resp(k).poly_den, w); 

    %% remove instrument response
    MinFPoint = max(2, ceil(LowFMin/delta_f));
    MaxFPoint = min(fftlength/2, floor(HighFMax/delta_f)); 
    nn =  MinFPoint:MaxFPoint;
    % Y = XH -> X = Y/H -> X = Y*conj(H)/abs(H)^2
    h = h/max(abs(h)); % normalize the amplitude of the intrument response
    fftdata = reshape(fftdata, 1, fftlength);
    fftdata(nn) = fftdata(nn).*conj(h(nn))./(abs(h(nn)).^2 + 0.01);  % water-level deconvolution
    fftdata(1:MinFPoint) = 0;
    fftdata(MaxFPoint:(fftlength/2+1)) = 0;
    fftdata((fftlength/2+2):fftlength)=conj(fftdata((fftlength/2):-1:2)); % treat another half spectrum
    
    %% band pass filtering
    LowPtN = round(LowF/delta_f);
    HighPtN = round(HighF/delta_f); 
    nptdfs = round((LowF - LowFMin)/delta_f);
    if nptdfs >= 4
        nn = (LowPtN - nptdfs):(LowPtN-1);
        taperwin = hann(2*nptdfs-1)';
        fftdata(1:(LowPtN - nptdfs -1))=0; 
        % figure(99); hold off; subplot(2,1,1); hold off; plot(abs(fftdata(nn)),'r');
        fftdata(nn) = taperwin(1:nptdfs).*fftdata(nn);
        % hold on; plot(abs(fftdata(nn)),'b--');
    end

    nptdfs = round((HighFMax - HighF)/delta_f);
    nn = (HighPtN + 1):(HighPtN + nptdfs);
    if nptdfs >= 4
        taperwin = hann(2*nptdfs-1)';
        % subplot(2,1,2); hold off; plot(abs(fftdata(nn)),'r');
        fftdata(nn)= taperwin(nptdfs:end).*fftdata(nn);   
        fftdata((HighPtN + nptdfs + 1):(fftlength/2+1)) = 0;
        % hold on; plot(abs(fftdata(nn)),'b--');
    end

    fftdata((fftlength/2+2):fftlength)=conj(fftdata((fftlength/2):-1:2));            
    fftdata = reshape(fftdata, fftlength, 1);

    %% old codes
%     MinFPoint = floor(LowFMin/delta_f);
%     if MinFPoint <= 2
%         MinFPoint = 2;
%     end    
%     
%     for n = MinFPoint:(fftlength/2+1)
%         fftdata(n) = fftdata(n)/max(abs(h(n)), 0.2)*conj(h(n)/abs(h(n)));
% %             fftdata(n) = fftdata(n)*conj(h(n)/abs(h(n)));
%         fftdata(fftlength+2-n) = conj(fftdata(n));
%     end
% 
%     for n = 1:(MinFPoint-1)
%         fftdata(n) = exp(-(MinFPoint-n)^2)*fftdata(n);
%         if n ~= 1
%             fftdata(fftlength+2-n) = conj(fftdata(n));
%         end
%     end
    %%
    wave(k).DatZ = real(ifft(fftdata,fftlength));
    
%     hold(h2, 'off');
%     if k == 1
%         plot(h2, -rcd_Z(k).DiffT+(0:(rcd_Z(k).NumPt-1))*sta(k).SampleT, wave(k).DatZ+2, 'r');
%     elseif k==2
%         hold(h2, 'on');
%         plot(h2, -rcd_Z(k).DiffT+(0:(rcd_Z(k).NumPt-1))*sta(k).SampleT, wave(k).DatZ, 'r');
%     end
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Read Instrument Response File ---
function [Normfactor, Numzeroes, Numpoles, Respzero, Resppole] = Rd_InstruRespFile(RespFile)

fname = fopen(RespFile,'r');
% skip 1 - 18 line
for i = 1:18
temp1 = fgetl(fname);
end

%read line 19
temp1 = fscanf(fname,'%s',4);
Normfactor = fscanf(fname,'%f',1);
temp1 = fgetl(fname);

%read line 20
temp1 = fgetl(fname);
%read line 21
temp1 = fscanf(fname,'%s',4);
Numzeroes = fscanf(fname,'%f',1);
temp1 = fgetl(fname);
%read line 22
temp1 = fscanf(fname,'%s',4);
Numpoles = fscanf(fname,'%f',1);
temp1 = fgetl(fname);
%read line 23, 24: zeroes header
temp1 = fgetl(fname);
temp1 = fgetl(fname);
%read zeros
for i = 1:Numzeroes
   temp1 = fscanf(fname,'%s',1);
   temp = fscanf(fname,'%d',1);
   realpart = fscanf(fname,'%e',1);
   imagpart = fscanf(fname,'%e',1);
   Respzero(i) = complex(realpart, imagpart);
   temp1 = fgetl(fname);
end
%read 2 lines: poles header
temp1 = fgetl(fname);
temp1 = fgetl(fname);
%read poles
for i = 1:Numpoles
   temp1 = fscanf(fname,'%s',1);
   temp = fscanf(fname,'%d',1);
   realpart = fscanf(fname,'%e',1);
   imagpart = fscanf(fname,'%e',1);
   Resppole(i) = complex(realpart, imagpart);
   temp1 = fgetl(fname);
end
fclose(fname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. get group image and group arrival
function ProcessIndex = GroupImageArrival(hObject, handles)
global sta wave rcd_Z src filter cross group DeltaTInitial
global TBeta

cross.WaveType = get(handles.SurfaceWaveType,'Value');
cross.StartT = str2num(get(handles.StartPeriod,'String'));
cross.EndT = str2num(get(handles.EndPeriod,'String'));
EndT = cross.EndT;
cross.DeltaT = str2num(get(handles.DeltaPeriod,'String'));

filter.Domain = get(handles.Filter_domain,'Value');
filter.Window = get(handles.Win_type,'Value');

GVWinR = [2.5 5.2]; % group velocity window (km/s) for Rayleigh Wave
GVWinL = [2.8 5.8]; % group velocity window (km/s) for Love Wave
RefTravTMin = [0 0];
RefTravTMax = [0 0];
if cross.WaveType == 1  % for Rayleigh wave
    for i = 1:2
        RefTravTMin(i) = sta(i).GCDkm/GVWinR(2) + rcd_Z(i).DiffT;
        RefTravTMax(i) = sta(i).GCDkm/GVWinR(1) + rcd_Z(i).DiffT;
    end
else % for Love wave
    for i = 1:2
        RefTravTMin(i) = sta(i).GCDkm/GVWinL(2) + rcd_Z(i).DiffT;
        RefTravTMax(i) = sta(i).GCDkm/GVWinL(1) + rcd_Z(i).DiffT;
    end
end
 
if (min(RefTravTMin) >= 0) & (min(rcd_Z(1).Time - RefTravTMax(1), rcd_Z(2).Time - RefTravTMax(2)) > 0)
    ProcessIndex = 1;  % continue processing
    
    StaDistance = abs(sta(1).GCDkm - sta(2).GCDkm);
    cross.EndT = min(EndT, 2*StaDistance/2.5);
    cross.EndT = round(cross.EndT - mod(cross.EndT, cross.DeltaT));
    if cross.EndT <= cross.StartT
        ProcessIndex = 0;  % stop processing
    else
        cross.NumCtrT = round((cross.EndT - cross.StartT)/cross.DeltaT) + 1;
        TPoint = cross.StartT:cross.DeltaT:cross.EndT;
    end
else
    ProcessIndex = 0;  % stop processing
%     set(handles.MsgEdit,'String','Surface wave window not long enough for the processing!');
%     pause(0.25);
end


h1 = handles.axes1;
h2 = handles.axes2;
 
% continue processing
if ProcessIndex == 1
    
   % set filter sample frequency to be the data sampling frequency
   filter.SampleF = rcd_Z(1).SampleF;
   filter.SampleT = 1/filter.SampleF;
   
   TaperTime = 50*min(sta(1).GCDkm, sta(2).GCDkm)/2000; % unit: second   
   TaperNum = round(TaperTime*rcd_Z(1).SampleF);
   [CrossDeltaT, WaveIndex] = max(RefTravTMax - RefTravTMin);
   cross.StartNum = ceil(RefTravTMin./[filter.SampleT filter.SampleT]);
   cross.EndNum = floor(RefTravTMax./[filter.SampleT filter.SampleT]);
   cross.SENum = cross.EndNum - cross.StartNum + 1;
   cross.PointNum = max(cross.SENum);
   MaxFilterLength = round(max(512*filter.SampleF, 5*cross.EndT*filter.SampleF));
   MaxHalfFilterNum =  floor(MaxFilterLength/2);
   cross.wave1 = zeros(1, cross.PointNum + MaxHalfFilterNum);
   cross.wave2 = zeros(1, cross.PointNum + MaxHalfFilterNum);
   
   % set taper window
   window1 = ones(cross.SENum(1),1);
   window2 = ones(cross.SENum(2),1);
   window1(1:TaperNum(1)) = sin(0.5*pi*(1:TaperNum)/TaperNum);
   window1((cross.SENum(1)-TaperNum+1):cross.SENum(1)) = window1(TaperNum:-1:1);
   window2(1:TaperNum) = sin(0.5*pi*(1:TaperNum)/TaperNum);
   window2((cross.SENum(2)-TaperNum+1):cross.SENum(2)) = window2(TaperNum:-1:1);
   
   % obtain waveforms for group arrival analysis and cross-correlation
   if sta(1).GCDkm < sta(2).GCDkm
       DeltaTInitial = rcd_Z(1).DiffT - rcd_Z(2).DiffT + (cross.StartNum(2)-1)*rcd_Z(2).SampleT - (cross.StartNum(1)-1)*rcd_Z(1).SampleT;
       cross.wave1(1:cross.SENum(1)) = wave(1).DatZ(cross.StartNum(1):cross.EndNum(1)).*window1;
       cross.wave2(1:cross.SENum(2)) = wave(2).DatZ(cross.StartNum(2):cross.EndNum(2)).*window2;
       hold(h2,'off')
%        plot(h2,(1:cross.SENum(1))*rcd_Z(1).SampleT, 1+wave(1).DatZ(cross.StartNum(1):cross.EndNum(1)));
%        hold(h2,'on');
       plot(h2,(1:cross.PointNum)*rcd_Z(1).SampleT, 2+cross.wave1(1:cross.PointNum)/max(cross.wave1(1:cross.PointNum)),'k');
%        hold(h2,'on');
%        plot(h2,(1:cross.SENum(2))*rcd_Z(2).SampleT + DeltaTInitial, wave(2).DatZ(cross.StartNum(2):cross.EndNum(2)));
       hold(h2,'on');
       plot(h2,(1:cross.PointNum)*rcd_Z(2).SampleT + DeltaTInitial, cross.wave2(1:cross.PointNum)/max(cross.wave2(1:cross.PointNum)),'k');
       evestadist1 =  sta(1).GCDkm;
       evestadist2 =  sta(2).GCDkm;
   else
       DeltaTInitial = rcd_Z(2).DiffT - rcd_Z(1).DiffT + (cross.StartNum(1)-1)*rcd_Z(1).SampleT - (cross.StartNum(2)-1)*rcd_Z(2).SampleT;
       cross.wave1(1:cross.SENum(2)) = wave(2).DatZ(cross.StartNum(2):cross.EndNum(2)).*window2;
       cross.wave2(1:cross.SENum(1)) = wave(1).DatZ(cross.StartNum(1):cross.EndNum(1)).*window1;
       hold(h2,'off');
%        plot(h2,(1:cross.SENum(2))*rcd_Z(2).SampleT, 1+wave(2).DatZ(cross.StartNum(2):cross.EndNum(2)));
%        hold(h2,'on');
       plot(h2,(1:cross.PointNum)*rcd_Z(2).SampleT, 1+cross.wave1(1:cross.PointNum),'k');
%        hold(h2,'on');
%        plot(h2,(1:cross.SENum(1))*rcd_Z(1).SampleT + DeltaTInitial, wave(1).DatZ(cross.StartNum(1):cross.EndNum(1)));
       hold(h2,'on');
       plot(h2,(1:cross.PointNum)*rcd_Z(1).SampleT + DeltaTInitial, cross.wave2(1:cross.PointNum),'k');
       evestadist2 =  sta(1).GCDkm;
       evestadist1 =  sta(2).GCDkm;
       
   end

   % set period vector
    Tpoint = cross.StartT:cross.DeltaT:cross.EndT;
    Ypoint = 1:cross.PointNum;

    % bandpass filtering the waveforms and obtain wave group image    
    crossgroup1 = EnvelopeImageCalculation(cross.wave1(1:cross.PointNum), filter.SampleF, Tpoint, evestadist1);
    AmpS_T1 = max(crossgroup1,[],2);
    crossgroup2 = EnvelopeImageCalculation(cross.wave2(1:cross.PointNum), filter.SampleF, Tpoint, evestadist2);
    AmpS_T2 = max(crossgroup2,[],2);
    for numt = 1:cross.NumCtrT
        cross.group1(1:cross.PointNum, numt) = crossgroup1(numt,:)'/AmpS_T1(numt);
        cross.group2(1:cross.PointNum, numt) = crossgroup2(numt,:)'/AmpS_T2(numt);
    end 
    clear crossgroup1 AmpS_T1 crossgroup2 AmpS_T2
    
%     for numt = 1:cross.NumCtrT
%         filter.CtrT = cross.StartT + (numt - 1)*cross.DeltaT;
%         filter.CtrF = (2/filter.SampleF)/filter.CtrT;
%         filter.Length = max(512*filter.SampleF, round(5*filter.CtrT*filter.SampleF));
%         HalfFilterNum =  floor(filter.Length/2);
%         
%         switch filter.Domain 
%             case 1
%                 filter.LowF = (2/filter.SampleF)/(filter.CtrT + 0.5*filter.BandWidth);
%                 filter.HighF = (2/filter.SampleF)/(filter.CtrT - 0.5*filter.BandWidth);
%                 
%             case 2
%                 filter.LowF = (2/filter.SampleF)*(filter.CtrF - 0.5*filter.BandWidth);
%                 filter.HighF = (2/filter.SampleF)*(filter.CtrF + 0.5*filter.BandWidth);
%         end
%         
%         if filter.Window == 1   % Kaiser Window
%             filterData = fir1(filter.Length, [filter.LowF, filter.HighF], kaiser(filter.Length + 1,filter.KaiserPara));
%         elseif filter.Window == 2   % Gaussian Window
%             filterData = fir1(filter.Length, [filter.LowF, filter.HighF], gausswin(filter.Length + 1,filter.GaussAlfa));
%         end
%                 
%         %time-reversal filtering of two-pass filtering
%         FilteredWave1 = fftfilt(filterData,cross.wave1(1:(cross.PointNum + HalfFilterNum)));
%         FilteredWave1 = FilteredWave1((cross.PointNum + HalfFilterNum):-1:1);
%         FilteredWave1 = fftfilt(filterData, FilteredWave1(1:(cross.PointNum + HalfFilterNum)));
%         FilteredWave1 = FilteredWave1((cross.PointNum + HalfFilterNum):-1:1);
%         FilteredWave1(1:cross.PointNum) = FilteredWave1(1:cross.PointNum)/max(FilteredWave1(1:cross.PointNum));
%         
%         FilteredWave1(1:cross.SENum(1)) = FilteredWave1(1:cross.SENum(1)).*window1';
%         FilteredWave1((cross.SENum(1)+1):cross.PointNum) = 0;
% 
%         wavehilbert(1:cross.PointNum) = hilbert(FilteredWave1(1:cross.PointNum));
%         cross.group1(1:cross.PointNum, numt) = abs(wavehilbert(1:cross.PointNum));
%         cross.group1(1:cross.PointNum, numt) = cross.group1(1:cross.PointNum, numt)/max(cross.group1(1:cross.PointNum, numt));
%         
%         %time-reversal filtering of two-pass filtering
%         FilteredWave2 = fftfilt(filterData,cross.wave2(1:(cross.PointNum + HalfFilterNum)));
%         FilteredWave2 = FilteredWave2((cross.PointNum + HalfFilterNum):-1:1);
%         FilteredWave2 = fftfilt(filterData, FilteredWave2(1:(cross.PointNum + HalfFilterNum)));
%         FilteredWave2 = FilteredWave2((cross.PointNum + HalfFilterNum):-1:1);
%         FilteredWave2(1:cross.PointNum) = FilteredWave2(1:cross.PointNum)/max(FilteredWave2(1:cross.PointNum));
%         FilteredWave2(1:cross.SENum(2)) = FilteredWave2(1:cross.SENum(2)).*window2';
%         FilteredWave2((cross.SENum(2)+1):cross.PointNum) = 0;
%         
%         wavehilbert(1:cross.PointNum) = hilbert(FilteredWave2(1:cross.PointNum));
%         cross.group2(1:cross.PointNum, numt) = abs(wavehilbert(1:cross.PointNum));
%         cross.group2(1:cross.PointNum, numt) = cross.group2(1:cross.PointNum, numt)/max(cross.group2(1:cross.PointNum, numt));
%         clear FilteredWave1 FilteredWave2 wavehilbert filterData
%     end
    
    clear  window1 window2 
%     cross.PointNum
%     figure    
%     plot(cross.group2(1:cross.PointNum,cross.NumCtrT));
%     hold on
%     plot(FilteredWave2(1:cross.PointNum),'r');
%     hold on
%     plot(cross.wave2(1:cross.PointNum),'g');
%     hold on
%     plot(window2);
    
    group.ArrPt1 = zeros(1, cross.NumCtrT);
    group.ArrPt2 = zeros(1, cross.NumCtrT);
    
    % obtain the group arrival by search the max amplitude in the velocity
    % window [2.5 5] km/s for Rayleigh waves, [2.5 5.5] for love waves
    [MaxAmp,group.ArrPt1(1:cross.NumCtrT)] = max(cross.group1(1:cross.PointNum,1:cross.NumCtrT));
    [MaxAmp,group.ArrPt2(1:cross.NumCtrT)] = max(cross.group2(1:cross.PointNum,1:cross.NumCtrT));    
    
%     hold(h1,'off');
%     set(gcf,'CurrentAxes',h1);
%     colormap(jet);
%     imagesc(Tpoint,Ypoint,cross.group1(1:cross.PointNum,1:cross.NumCtrT),[0,1]); 
%     hold on
%     plot(TPoint, group.ArrPt1(1:cross.NumCtrT), 'g');
%        
%     hold(h2,'off');
%     colormap(jet);
%     set(gcf,'CurrentAxes',h2);
%     imagesc(Tpoint,Ypoint,cross.group2(1:cross.PointNum,1:cross.NumCtrT),[0,1]);    
%     hold on
%     plot(TPoint, group.ArrPt2(1:cross.NumCtrT), 'g');
    
    figure(1)
    subplot(2,1,1);
%     colormap(jet);
    imagesc(Tpoint(1:cross.NumCtrT),Ypoint,cross.group1(1:cross.PointNum,1:cross.NumCtrT),[0,1]); 
    hold on
    plot(TPoint(1:cross.NumCtrT), group.ArrPt1(1:cross.NumCtrT), 'g');
    ylabel('Travel Time (s)');

    subplot(2,1,2);    
%     colormap(jet);
    imagesc(Tpoint(1:cross.NumCtrT),Ypoint,cross.group2(1:cross.PointNum,1:cross.NumCtrT),[0,1]);    
    hold on
    plot(TPoint(1:cross.NumCtrT), group.ArrPt2(1:cross.NumCtrT), 'g');
    xlabel('Period (s)');
    ylabel('Travel Time (s)');
    
    pause(0.5)
    close(1)
end    
    
%% --- calculate envelope image, i.e., to obtain envelope at each T
function EnvelopeImage = EnvelopeImageCalculation(WinWave, fs, TPoint, StaDist)
%% new code for group velocity analysis using frequency domain Gaussian filter
alfa = [0 100 250 500 1000 2000 4000 20000; 5  8  12  20  25  35  50 75];
guassalfa = interp1(alfa(1,:), alfa(2, :), StaDist);

NumCtrT = length(TPoint);
PtNum = length(WinWave);

nfft = 2^nextpow2(max(PtNum,1024*fs));
xxfft = fft(WinWave, nfft);
fxx = (0:(nfft/2))/nfft*fs; 
IIf = 1:(nfft/2+1);
JJf = (nfft/2+2):nfft;

EnvelopeImage = zeros(NumCtrT, PtNum);
for i = 1:NumCtrT
    CtrT = TPoint(i);
    fc = 1/CtrT;                
    Hf = exp(-guassalfa*(fxx - fc).^2/fc^2);
    yyfft = zeros(1,nfft);
    yyfft(IIf) = xxfft(IIf).*Hf;
    yyfft(JJf) = conj(yyfft((nfft/2):-1:2));
    yy = real(ifft(yyfft, nfft));
    filtwave = abs(hilbert(yy(1:nfft)));
    EnvelopeImage(i, 1:PtNum) = filtwave(1:PtNum);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CrossCorrelation(hObject, handles)
% hObject    handle to CrossCorrelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sta filter cross group DeltaTInitial ClickPoint

h1 = handles.axes1;
h2 = handles.axes2;

TPoint = cross.StartT:cross.DeltaT:cross.EndT;
StaDistance = abs(sta(1).GCDkm - sta(2).GCDkm);

if cross.WaveType == 1  % Rayleigh Wave
    cross.VMin = 2.5;
    cross.VMax = 5.2;
    cross.DeltaV = 0.001;
elseif cross.WaveType == 2 % Love Wave
    cross.VMin = 2.8;
    cross.VMax = 5.8;
    cross.DeltaV = 0.001;
end
% cross.HalfBand = 125; % window half band with respect to the group arrival
cross.StartNum = 1;
cross.EndNum = cross.PointNum;

MaxTravT = StaDistance/cross.VMin;
MinTravT = StaDistance/cross.VMax;
MaxShiftNum = floor((MaxTravT - DeltaTInitial)/filter.SampleT+1);
MinShiftNum = floor((MinTravT - DeltaTInitial)/filter.SampleT-1);
ShiftNum = MaxShiftNum - MinShiftNum + 1;
CrossCorrImg = zeros(ShiftNum, cross.NumCtrT);

ShiftPtV = zeros(1,ShiftNum);
ShiftPtT = zeros(1,ShiftNum);

for i = 1:ShiftNum
    ShiftPtT(i) = (MinShiftNum + i - 1)*filter.SampleT + DeltaTInitial;
    ShiftPtV(i) = StaDistance/ShiftPtT(i);
end

% PtNum = 1:(cross.PointNum + HalfFilterNum);

for numt = 1:cross.NumCtrT
    
    % filter design
    filter.CtrT = cross.StartT + (numt - 1)*cross.DeltaT;
    filter.CtrF = (2/filter.SampleF)/filter.CtrT;
    filter.Length = round(max(512*filter.SampleF, round(5*filter.CtrT*filter.SampleF)));
    HalfFilterNum =  floor(filter.Length/2);
    
    switch filter.Domain
        case 1
            filter.LowF = (2/filter.SampleF)/(filter.CtrT + 0.5*filter.BandWidth);
            filter.HighF = (2/filter.SampleF)/(filter.CtrT - 0.5*filter.BandWidth);
        case 2
            filter.LowF = (2/filter.SampleF)*(filter.CtrF - 0.5*filter.BandWidth);
            filter.HighF = (2/filter.SampleF)*(filter.CtrF + 0.5*filter.BandWidth);
    end
    
    if filter.Window == 1   % Kaiser Window
        filterData = fir1(filter.Length, [filter.LowF, filter.HighF], kaiser(filter.Length + 1,filter.KaiserPara));
    elseif filter.Window == 2   % Gaussian Window
        filterData = fir1(filter.Length, [filter.LowF, filter.HighF], gausswin(filter.Length + 1,filter.GaussAlfa));
    end
    
    %Moving Window the waves 
    MovingWin1 = ones(1, cross.PointNum + HalfFilterNum);
    MovingWin2 = ones(1, cross.PointNum + HalfFilterNum);

% moving window type - 1 : Gaussian
%     alfa = 100;
%     MovingWin1(PtNum) = exp(-0.5*((PtNum - group.ArrPt1(numt))/sta(1).SampleT).^2/(alfa^2));
%     MovingWin2(PtNum) = exp(-0.5*((PtNum - group.ArrPt2(numt))/sta(2).SampleT).^2/(alfa^2));

% moving window type - 2 : boxcar + Gaussian taper   
    cross.HalfBand = round(2*filter.CtrT*filter.SampleF);
    WinLowerPt1 = round(group.ArrPt1(numt) - cross.HalfBand*filter.SampleF) - cross.StartNum + 1;
    WinLowerPt2 = round(group.ArrPt2(numt) - cross.HalfBand*filter.SampleF) - cross.StartNum + 1;
    WinUpperPt1 = round(group.ArrPt1(numt) + cross.HalfBand*filter.SampleF) - cross.StartNum + 1;
    WinUpperPt2 = round(group.ArrPt2(numt) + cross.HalfBand*filter.SampleF) - cross.StartNum + 1;
       
    alfa = 50*filter.SampleF; % in points
    if WinLowerPt1 > 1
        MovingWin1(1:WinLowerPt1) = exp(-(WinLowerPt1:-1:1).^2/(alfa^2));
    end
    if WinLowerPt2 > 1
        MovingWin2(1:WinLowerPt2) = exp(-(WinLowerPt2:-1:1).^2/(alfa^2));
    end
        
    if WinUpperPt1 <= cross.PointNum
        MovingWin1(WinUpperPt1:cross.PointNum) = exp(-((WinUpperPt1:cross.PointNum) - WinUpperPt1).^2/(alfa^2));
        MovingWin1((cross.PointNum+1):(cross.PointNum + HalfFilterNum)) = 0;
    else
        MovingWin1(WinUpperPt1:(cross.PointNum + HalfFilterNum)) = 0;
    end
   
    if WinUpperPt2 <= cross.PointNum
        MovingWin2(WinUpperPt2:cross.PointNum) = exp(-((WinUpperPt2:cross.PointNum) - WinUpperPt2).^2/(alfa^2));
        MovingWin2((cross.PointNum+1):(cross.PointNum + HalfFilterNum)) = 0;
    else
        MovingWin2(WinUpperPt2:(cross.PointNum + HalfFilterNum)) = 0;
    end   

    WinWave1 = zeros(1, cross.PointNum + HalfFilterNum);
    WinWave2 = zeros(1, cross.PointNum + HalfFilterNum);
    WinWave1 = cross.wave1(1:(cross.PointNum + HalfFilterNum)).*MovingWin1;
    WinWave2 = cross.wave2(1:(cross.PointNum + HalfFilterNum)).*MovingWin2;
    
    
%     hold(h2, 'off');
%     set(gcf,'CurrentAxes',h2);
%     plot(h2, cross.wave2, 'r');
%     hold on
%     plot(h2, MovingWin2, 'b');
%     hold on
%     plot(h2, WinWave2, 'g--');
%     
%     hold(h1, 'off');
%     set(gcf,'CurrentAxes',h1);
%     plot(h1, cross.wave1, 'r');
%     hold on
%     plot(h1, MovingWin1, 'b');
%     hold on
%     plot(h1, WinWave1, 'g--');
    
    %time-reversal filtering of two-pass filtering
    FilteredWave1 = fftfilt(filterData, WinWave1(1:(cross.PointNum + HalfFilterNum)));
    FilteredWave1 = FilteredWave1((cross.PointNum + HalfFilterNum):-1:1);
    FilteredWave1 = fftfilt(filterData, FilteredWave1(1:(cross.PointNum + HalfFilterNum)));
    FilteredWave1 = FilteredWave1((cross.PointNum + HalfFilterNum):-1:1);

    FilteredWave1(1:cross.PointNum) = FilteredWave1(1:cross.PointNum)/max(FilteredWave1(1:cross.PointNum));
	wavehilbert(1:cross.PointNum) = hilbert(FilteredWave1(1:cross.PointNum));
	cross.group1(1:cross.PointNum, numt) = abs(wavehilbert(1:cross.PointNum));
    cross.group1(1:cross.PointNum, numt) = cross.group1(1:cross.PointNum, numt)/max(cross.group1(1:cross.PointNum, numt));
    
    %time-reversal filtering of two-pass filtering
    FilteredWave2 = fftfilt(filterData,WinWave2(1:(cross.PointNum + HalfFilterNum)));
    FilteredWave2 = FilteredWave2((cross.PointNum + HalfFilterNum):-1:1);
    FilteredWave2 = fftfilt(filterData, FilteredWave2(1:(cross.PointNum + HalfFilterNum)));
    FilteredWave2 = FilteredWave2((cross.PointNum + HalfFilterNum):-1:1);

    FilteredWave2(1:cross.PointNum) = FilteredWave2(1:cross.PointNum)/max(FilteredWave2(1:cross.PointNum));
	wavehilbert(1:cross.PointNum) = hilbert(FilteredWave2(1:cross.PointNum));
	cross.group2(1:cross.PointNum, numt) = abs(wavehilbert(1:cross.PointNum));
    cross.group2(1:cross.PointNum, numt) = cross.group2(1:cross.PointNum, numt)/max(cross.group2(1:cross.PointNum, numt));
            
    for k = 1:ShiftNum
        shift = MinShiftNum + k - 1;
        if shift >= 0
            CrossCorrImg(k,numt) = dot(FilteredWave2((1 + shift):cross.PointNum), FilteredWave1(1:(cross.PointNum - shift)));
        else
            CrossCorrImg(k,numt) = dot(FilteredWave2(1:(cross.PointNum + shift)), FilteredWave1((1 - shift):cross.PointNum));
        end
    end
    
    CrossMaxAmp = max(CrossCorrImg(1:ShiftNum,numt));
    if CrossMaxAmp > 0
        CrossCorrImg(1:ShiftNum,numt) = CrossCorrImg(1:ShiftNum,numt)/CrossMaxAmp;
    end
    clear FilteredWave1 FilteredWave2 wavehilbert WinWave1 WinWave2 MovingWin1 MovingWin2 filterData
end

Tpoint = cross.StartT:cross.DeltaT:cross.EndT;
Ypoint = 1:cross.PointNum;


figure(1)
subplot(2,1,1);
%     colormap(jet);
imagesc(Tpoint(1:cross.NumCtrT),Ypoint(1:cross.PointNum),cross.group1(1:cross.PointNum,1:cross.NumCtrT),[0,1]); 
ylabel('Travel Time (s)');

subplot(2,1,2);    
%     colormap(jet);
imagesc(Tpoint(1:cross.NumCtrT),Ypoint(1:cross.PointNum),cross.group2(1:cross.PointNum,1:cross.NumCtrT),[0,1]);    
xlabel('Period (s)');
ylabel('Travel Time (s)');

pause(0.5)
close(1)

% hold(h1,'off');
% set(gcf,'CurrentAxes',h1);
% colormap(jet);
% imagesc(TPoint, ShiftPtT, CrossCorrImg(1:ShiftNum, 1:cross.NumCtrT), [-1, 1]); 
% % xlabel('Period (s)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('Shift Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
% set(gca, 'FontSize', 12, 'FontWeight', 'bold');

IsDispGood = 1;  % ... = 1: calculate dispersion; ... = other: do not caculate
h2 = handles.axes2;

while IsDispGood == 1
    
    set(gcf,'CurrentAxes',h2);
    hold(h2,'off');
%     colormap(jet);
    VPoint = cross.VMin:cross.DeltaV:cross.VMax;
    CImgPt = size(VPoint,2);
    cross.PhasVImg = zeros(CImgPt, cross.NumCtrT);
    for i = 1:cross.NumCtrT
       cross.PhasVImg(1:CImgPt, i) = interp1(ShiftPtV, CrossCorrImg(1:ShiftNum,i), VPoint, 'spline');
       MaxAmpPhaseVImg = max(cross.PhasVImg(1:CImgPt, i));
       if MaxAmpPhaseVImg > 0
           cross.PhasVImg(1:CImgPt, i) = cross.PhasVImg(1:CImgPt, i)/MaxAmpPhaseVImg;
       end       
    end
    imagesc(TPoint(1:cross.NumCtrT), VPoint(1:CImgPt), cross.PhasVImg(1:CImgPt, 1:cross.NumCtrT), [-1, 1]); 
    set(gca,'YDir','normal');

    xlabel('Period (s)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Phase Velocity (km/s)', 'FontSize', 12, 'FontWeight', 'bold');
    set(gca, 'FontSize', 12, 'FontWeight', 'bold');
    set(gca, 'XTick',0:20:300,'YTick',2:0.25:6,'XGrid','on','YGrid','on');
    IsDispGood = PhaseVDisper(hObject, handles);  % obtain the disperion curve
end

clear CrossCorrImg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IsDispGood = PhaseVDisper(hObject, handles)

global cross ClickPoint sta src PrevStaLonLat
global DispDirectory
h1 = handles.axes1;
h2 = handles.axes2;

SaveOrNot = questdlg('Do you want to get dispersion curve?','Dispersion Curve','Yes','No','Yes');
axes(h2);

if strcmp(SaveOrNot, 'Yes') == 1
    
%     k = 1;
%     ClickPoint = zeros(2,3);
%     while k ~= 0
%         set(handles.MsgEdit,'String','Please left click on lower figure to select disperion curve!');
%         k = waitforbuttonpress;
%         x = get(h2,'XLim');
%         y = get(h2,'YLim');
%         if ClickPoint(1,1) >= x(1,1) && ClickPoint(1,1) <= x(1,2) && ClickPoint(1,2) >= y(1,1) && ClickPoint(1,2) <= y(1,2)
%             hold on
%             plot(h2, ClickPoint(1,1), ClickPoint(1,2),'*g');
%             k = 0;
%             set(handles.MsgEdit, 'String', 'Successful click!');
%         else      
%             k = 1;
%             set(handles.MsgEdit, 'String', 'Wrong click! Please click on the lower figure!');
%         end
%     end
    
    k = 1;
    while k ~= 0
        set(handles.MsgEdit,'String','Left button click for first point and right for last point to select disperion curve!');
        % Initially, the list of points is empty.
        xy = [];
        n = 0;
        % Loop, picking up the points.
        disp('Left mouse button picks points.')
        disp('Right mouse button picks last point.')
        button = 1;
        x = get(h2,'XLim');
        y = get(h2,'YLim');        
        while button == 1
            [xi,yi,button] = ginput(1);
            if xi > x(2) || xi < x(1) || yi > y(2) || yi < y(1)
                set(handles.MsgEdit, 'String', 'Wrong click! Please click on the lower image!');
            else
                hold on; plot(xi,yi,'g+','MarkerSize',8)
                n = n+1;
                xy(:,n) = [xi;yi];  
            end
%             if n == 1
%                 break
%             end
        end
        hold on; plot(xi,yi,'m+','MarkerSize',8)

        if n == 0
            k = 1;
            set(handles.MsgEdit, 'String', 'Wrong click! Please click on the lower image!');
        else
            k = 0;
        end
    end
    
    
    DisperStartT = cross.StartT;
    DisperEndT = cross.EndT;

    StaDistance = abs(sta(1).GCDkm - sta(2).GCDkm);
    TPoint = cross.StartT:cross.DeltaT:cross.EndT;
%     InitialT = floor((ClickPoint(1,1) - cross.StartT)/cross.DeltaT + 1);
%     InitialV = ClickPoint(1,2);
%     InitialY = floor((InitialV - cross.VMin)/cross.DeltaV + 1);
    InitialT = round((xy(1,:) - cross.StartT)/cross.DeltaT + 1);
    InitialY = round((xy(2,:) - cross.VMin)/cross.DeltaV + 1);
    nSelectPt = length(InitialT);
    % sort picked points according to increasing periods
    [InitialT, II] = sort(InitialT);
    InitialY = InitialY(II);
    
    DispPt = zeros(1, cross.NumCtrT); 
    PhaseVDisp = zeros(1, cross.NumCtrT); 
    CImgPt = (cross.VMax - cross.VMin)/cross.DeltaV + 1;
    % DispPt(1:cross.NumCtrT) = AutoSearch(InitialY, InitialT, cross.PhasVImg(1:CImgPt,1:cross.NumCtrT));
    if nSelectPt == 1
        DispPt(1:cross.NumCtrT) = AutoSearch(InitialY, InitialT, cross.PhasVImg(1:CImgPt,1:cross.NumCtrT));
    elseif nSelectPt > 1
        DispPt(1:cross.NumCtrT) = AutoSearchMultiplePoints(InitialY, InitialT, cross.PhasVImg(1:CImgPt,1:cross.NumCtrT));
    end       
    
    PhaseVDisp(1:cross.NumCtrT) = cross.VMin + (DispPt - 1)*cross.DeltaV;
    hold(h2,'on')
    plot(h2, TPoint(1:cross.NumCtrT), PhaseVDisp(1:cross.NumCtrT), 'k-', 'LineWidth', 3);
    
    IsDispGood = 2;
    
    InputOrNotIndex = 1;
    while InputOrNotIndex == 1    
        prompt = {'Enter Start Period:','Enter End Period:'};
        title = ['Set start and end period (s) for saving dispersion data'];
        line = 2; 
        def = {num2str(cross.StartT), num2str(cross.EndT)};
        DisperPeriod = inputdlg(prompt,title,line, def);
        if size(DisperPeriod,1)~=line
            InputOrNotIndex = 1;
        else
            DisperStartT = str2num(DisperPeriod{1});
            DisperEndT = str2num(DisperPeriod{2});
            if isempty(DisperStartT) || isempty(DisperEndT)
                InputOrNotIndex = 1;
            else
                StartTIndex = round((DisperStartT - cross.StartT)/cross.DeltaT) + 1;
                EndTIndex = round((DisperEndT - cross.StartT)/cross.DeltaT) + 1;    
                if DisperStartT >= cross.StartT && DisperEndT <= cross.EndT
                    InputOrNotIndex = 0;
                else
                    InputOrNotIndex = 1;
                end
            end
        end
    end
       

    %write T-V to file 
    if DispDirectory == 0
        DispDirectory = pwd;
    end
    
    YYChar = num2str(src.YY);
    
    MonChar = num2str(src.Month);
    if length(MonChar) == 1
        MonChar = strcat('0',MonChar);
    end
    
    DDChar = num2str(src.Day);
    if length(DDChar) == 1
        DDChar = strcat('0',DDChar);
    end   
    
    HHChar = num2str(src.HH);
    if length(HHChar) == 1
        HHChar = strcat('0',HHChar);
    end
    
    MMChar = num2str(src.MM);
    if length(MMChar) == 1
        MMChar = strcat('0',MMChar);
    end   
    
    
    SrcTime = strcat(YYChar(3:4),MonChar,DDChar,'_',HHChar,MMChar);
    
    for i = 1:max(size(sta(1).Name, 2), size(sta(2).Name, 2))
        if double(sta(1).Name(i)) > double(sta(2).Name(i))
            StaNamePair = strcat(sta(2).Name,'-', sta(1).Name);
            index1 = 2;
            index2 = 1;
            break
        elseif double(sta(1).Name(i)) < double(sta(2).Name(i))
            StaNamePair = strcat(sta(1).Name,'-', sta(2).Name);
            index1 = 1;
            index2 = 2;
            break
        else
            continue
        end
    end
    
    if sum(sum(PrevStaLonLat)) ~= 0
        set(gcf,'CurrentAxes',h1);
        hold(h1,'on');
        plot(PrevStaLonLat(1:2,1), PrevStaLonLat(1:2,2), 'b-');
        plot(h1, PrevStaLonLat(1:2,1), PrevStaLonLat(1:2,2), 'r^', 'MarkerSize',6, 'MarkerFaceColor','r');
    end

    
    PrevStaLonLat = [sta(index1).Lon, sta(index1).Lat;sta(index2).Lon, sta(index2).Lat ];

    
    dispfilename = strcat('/C' ,SrcTime, StaNamePair, '.dat');
    TVfile = strcat(DispDirectory, dispfilename);
    
    ftv = fopen(TVfile,'w');
    fprintf(ftv,'%f     ', sta(index1).Lon);
    fprintf(ftv,'%f\n', sta(index1).Lat);
    fprintf(ftv,'%f     ', sta(index2).Lon);
    fprintf(ftv,'%f\n', sta(index2).Lat);
    DataExistIndex = 0;
    for i = StartTIndex:EndTIndex
       wavelength = PhaseVDisp(i)*TPoint(i);
       if wavelength <= 2*StaDistance
           DataExistIndex = 1;
           fprintf(ftv,'%4.1f   ',TPoint(i));
           fprintf(ftv,'%4.3f\n',PhaseVDisp(i));
           set(gcf,'CurrentAxes',h2);
           hold(h2,'on');
           plot(h2, TPoint(i), PhaseVDisp(i), 'r*');
       else
           break
       end
    end
    fclose(ftv);
    
    
    ReviseOrNot = questdlg('Want to revise the saved dispersion?','Revise dispersion data','Yes','No','No');
    if strcmp(ReviseOrNot, 'Yes') == 1
        IsDispGood = 1;
    else
        if DataExistIndex ~= 1
            delete(TVfile)
            set(handles.MsgEdit, 'String', 'No Disperion Data Written! Disper File Deleted!');
        else
            set(gcf,'CurrentAxes',h1);
            hold(h1,'on');
            plot([sta(index1).Lon, sta(index2).Lon], [sta(index1).Lat, sta(index2).Lat], 'r-');
            plot(h1, [sta(index1).Lon, sta(index2).Lon], [sta(index1).Lat, sta(index2).Lat], 'k^', 'MarkerSize',6, 'MarkerFaceColor','g');
        end
    end

else
    IsDispGood = 2;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Automatically search arrival time line on a image ---
function ArrPt = AutoSearch(InitialY, InitialX, ImageData)
% Input: InitialY  InitlaX   ImageData
% OutPut: ArrPt

YSize = size(ImageData, 1);
XSize = size(ImageData, 2);

ArrPt = zeros(1,XSize);

% Center_T search up
step = 3;
point_left = 0;
point_right = 0;

for i = InitialX:XSize
	index1 = 0;
	index2 = 0; 
	point_left = InitialY;
	point_right = InitialY;
	while index1 == 0
        point_left_new = max(1, point_left - step);
	    if ImageData(point_left,i) < ImageData(point_left_new,i)
		  point_left = point_left_new;
%          point_right = point_right - step;
		else
		   index1 = 1;
		   point_left = point_left_new;
        end
    end
    while index2 == 0
        point_right_new = min(point_right + step, YSize);
		if ImageData(point_right,i) < ImageData(point_right_new,i)
		   point_right = point_right_new;
%           point_left = point_left + step;
		else
           index2=1;
		   point_right = point_right_new;
		end
    end

    [MaxAmp, index_max] = max(ImageData(point_left:point_right,i));
    ArrPt(i) = index_max + point_left - 1;
    InitialY = ArrPt(i);
        
end  %end for

% Center_T search down

InitialY = ArrPt(InitialX);
for i = (InitialX - 1):(-1):1
	index1 = 0;
	index2 = 0; 
    point_left = InitialY;
	point_right = InitialY;

	while index1 == 0
        point_left_new = max(1, point_left - step);
	    if ImageData(point_left,i) < ImageData(point_left_new,i)
		  point_left = point_left_new;
%          point_right = point_right - step;
		else
		   index1 = 1;
		   point_left = point_left_new;
        end
    end
    while index2 == 0
        point_right_new = min(point_right + step, YSize);
		if ImageData(point_right,i) < ImageData(point_right_new,i)
		   point_right = point_right_new;
%           point_left = point_left + step;
		else
           index2=1;
		   point_right = point_right_new;
		end
    end
    
    [MaxAmp, index_max] = max(ImageData(point_left:point_right,i));
    ArrPt(i) = index_max + point_left - 1;
    InitialY = ArrPt(i);
    
end  %end for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Automatically search arrival time line on a image with multiple points constraints---
function ArrPt = AutoSearchMultiplePoints(ptY, ptX, ImageData)
% Input: InitialY  InitlaX   ImageData
% OutPut: ArrPt

% sort ptX and ptY according to the increasing of ptX
[ptX, II] = sort(ptX);
ptY = ptY(II);

YSize = size(ImageData, 1);
XSize = size(ImageData, 2);
nPt = length(ptX);  % number of input searching points

ArrPt = zeros(1,XSize);

% X searching up for the point with maximum X
step = 3;
point_left = 0;
point_right = 0;

InitialX = ptX(nPt);
InitialY = ptY(nPt);
for i = ptX(nPt):XSize
	index1 = 0;
	index2 = 0; 
	point_left = InitialY;
	point_right = InitialY;
	while index1 == 0
        point_left_new = max(1, point_left - step);
	    if ImageData(point_left,i) < ImageData(point_left_new,i)
		  point_left = point_left_new;
%          point_right = point_right - step;
		else
		   index1 = 1;
		   point_left = point_left_new;
        end
    end
    while index2 == 0
        point_right_new = min(point_right + step, YSize);
		if ImageData(point_right,i) < ImageData(point_right_new,i)
		   point_right = point_right_new;
%           point_left = point_left + step;
		else
           index2=1;
		   point_right = point_right_new;
		end
    end

    [MaxAmp, index_max] = max(ImageData(point_left:point_right,i));
    ArrPt(i) = index_max + point_left - 1;
    InitialY = ArrPt(i);
        
end  %end for

% X searching down for the point with maximum X. There will other points
% with smaller X which will act as internal constraints for the searching
% process

InitialX = ptX(nPt);
InitialY = ArrPt(ptX(nPt));
midX = ptX(nPt-1);
midY = ptY(nPt-1);
kk = 0;
for i = ptX(nPt):(-1):1
	index1 = 0;
	index2 = 0;
    
    if i == midX
        InitialY = midY;
        kk = kk + 1;
        if (nPt - kk) > 1
            midX = ptX(nPt - kk - 1);
            midY = ptY(nPt - kk - 1);
        end
    end
            
    point_left = InitialY;
	point_right = InitialY;

	while index1 == 0
        point_left_new = max(1, point_left - step);
	    if ImageData(point_left,i) < ImageData(point_left_new,i)
		  point_left = point_left_new;
%          point_right = point_right - step;
		else
		   index1 = 1;
		   point_left = point_left_new;
        end
    end
    while index2 == 0
        point_right_new = min(point_right + step, YSize);
		if ImageData(point_right,i) < ImageData(point_right_new,i)
		   point_right = point_right_new;
%           point_left = point_left + step;
		else
           index2=1;
		   point_right = point_right_new;
		end
    end
    
    [MaxAmp, index_max] = max(ImageData(point_left:point_right,i));
    ArrPt(i) = index_max + point_left - 1;
    InitialY = ArrPt(i);
    
end  %end for



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in ProcessAllData.
function ProcessAllData_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessAllData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ProcessAllData

if get(handles.ProcessAllData, 'Value')
    set(handles.ProcessSelectedData, 'Value', 0);
else
    set(handles.ProcessSelectedData, 'Value', 1);
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in ProcessSelectedData.
function ProcessSelectedData_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessSelectedData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ProcessSelectedData

if get(handles.ProcessSelectedData, 'Value')
    set(handles.ProcessAllData, 'Value', 0);
else
    set(handles.ProcessAllData, 'Value', 1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object deletion, before destroying properties.
function TSFigure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to TSFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear all
