% Global
global SHOTS_TYPE;
global GO_Q;
global BALL_RELEASE;
global SHOTS_LATENCY_INTERVAL;

% Constants
SHOTS_TYPE = [4 5 6];
GO_Q = 2;
BALL_RELEASE = 3;
SHOTS_LATENCY_INTERVAL = 900;
SAPMLE_RATE = 300;
MIN_DIF_BETWEEN_GO_AND_RELEASSE_SEC = 0.6;
MAX_DIF_BETWEEN_GO_AND_RELEASSE_SEC = 2;
MIN_DIF_BETWEEN_GO_AND_RELEASSE_TPNT = MIN_DIF_BETWEEN_GO_AND_RELEASSE_SEC * SAPMLE_RATE; 
MAX_DIF_BETWEEN_GO_AND_RELEASSE_TPNT = MAX_DIF_BETWEEN_GO_AND_RELEASSE_SEC * SAPMLE_RATE;
APPLY_RESAMPLING = true;
RESAMPLING_RATE = 250;
LOW_CUTOFF = 4;
HIGH_CUTOFF = 35;
SD_for_ASR = 20;
APPLY_DOUBLE_PERCISION = true;
SET_FILE = [".set"];
DATASET_NAME_CONVENTION = "subSUB_TRIAL_rawData";
APPLY_HIGHPASS_FILTER = true;
APPLY_CHANLOC = true;
APPLY_CLEANLINE = false;
APPLY_LOWPASS_FILTER = false;
APPLY_BAND_FILTER = false;
APPLY_ASR = true;
SHOW_SPECTOPO_POST_ASR = false;
APPLY_REREFERENCE_TO_AVERAGE = false;
SHOW_SPECTOPO_POST_REREFERENCE = true;
APPLY_CHANNELS_INTERPOLATE = true;
% epochs constants
T_START = -2.4; % time of beginning of short epoch in sec.
T_END = 0.05; % time of end of long short in sec.
APPLY_CLEAR_NAN_ELECTRODES = false;
NAN_ELECTRODES_TH = 15;
addpath(pwd);

%load eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

if APPLY_DOUBLE_PERCISION
	pop_editoptions('option_single', 0); % set option to double precision
end

% load dataset file
files = Utils.OS.load_input_files(SET_FILE);
if isempty(files)
	disp("Files not selected.");
	return;
end

% get dataset info 
ds_path = Utils.OS.construct_file_path(files, 'set');
ds_name = Utils.OS.construct_file_name(files, 'set');
[sub, trail] = Utils.OS.extract_sub_trail_from_file(ds_name, DATASET_NAME_CONVENTION);
file_name = ['sub' sub '_' trail '_ed'];

% load dataset to eeglab
EEG = pop_loadset(ds_path);

% handle events
EEG = Utils.DS.orderingEvents(EEG); 
EEG = Utils.DS.deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1); % leaves only 2->3/8/9 trials 
EEG = Utils.DS.checkGOToReleaseTimeDiff (EEG, MIN_DIF_BETWEEN_GO_AND_RELEASSE_TPNT, MAX_DIF_BETWEEN_GO_AND_RELEASSE_TPNT);
EEG = Utils.DS.deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1); % leaves only trials that meets time condition.

% Cleaning The Data
if APPLY_RESAMPLING
	EEG = pop_resample (EEG, RESAMPLING_RATE);          % Downsampling
end

if APPLY_HIGHPASS_FILTER
	[EEG, ALLEEG, CURRENTSET] = Utils.DS.highPass_filter(EEG, ALLEEG,  CURRENTSET, LOW_CUTOFF,  file_name);
end

if APPLY_CHANLOC
	[EEG, ALLEEG] = Utils.DS.set_chanloc(EEG, ALLEEG, CURRENTSET);
end

if APPLY_CLEANLINE
	[EEG, ALLEEG, CURRENTSET] = Utils.DS.CleanLine(EEG, ALLEEG,  CURRENTSET);
end

if APPLY_LOWPASS_FILTER
	[EEG, ALLEEG, CURRENTSET] = Utils.DS.lowPass_filter(EEG, ALLEEG, HIGH_CUTOFF, file_name);
end

if APPLY_BAND_FILTER
	[EEG, ALLEEG, CURRENTSET] = Utils.DS.bandFilteringData(EEG, ALLEEG, CURRENTSET, FREQUECY_TO_FILTER, file_name);
end

EEG = Utils.DS.aligningEvents(EEG);
EEG = pop_rmdat( EEG, {'3' '8' '9'},[-4 0.06] ,0); % cutting data by event

if APPLY_ASR
	[EEG, EEG_org, SNR, eliminatedChannels, signal, noise] = Utils.DS.ASRCleaning (EEG, ALLEEG, CURRENTSET, SD_for_ASR);
end

if APPLY_CHANNELS_INTERPOLATE
	EEG = pop_interp(EEG, EEG_org.chanlocs, 'spherical');
end

if SHOW_SPECTOPO_POST_ASR
	figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
end

if APPLY_REREFERENCE_TO_AVERAGE
	EEG = Utils.DS.reReferenceToAverage(EEG);
end

if SHOW_SPECTOPO_POST_REREFERENCE
	figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
end


EEG = Utils.DS.creatingEpochs(EEG, ALLEEG, CURRENTSET, T_START, T_END, file_name);

if APPLY_CLEAR_NAN_ELECTRODES
	EEG = Utils.DS.clearEmptyEpochs(EEG);
end

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',tempdir);

pop_eegplot( EEG, 1, 1, 1);

figure(1);
hold on;
uiwait;

eeglab redraw
Utils.OS.copy_ds_to_userDir(file_name);
