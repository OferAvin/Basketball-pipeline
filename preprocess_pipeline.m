
function [ALLEEG, EEG, CURRENTSET] = preprocess_pipeline(ds_path, dest_dir, ALLEEG, EEG)
% preprocess_pipeline - pipeline function. accepts a dataset ('.set') file
% path, a destination directory for auto saving, ALLEEG and EEG.


%%%%%%% Experiment parameters %%%%%%%

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
    
% Epochs constants
    T_START = -2.4; % time of beginning of short epoch in sec.
    T_END = 0.05; % time of end of long short in sec.

    
%%%%%%% Pipeline parameters %%%%%%%

% Double percision parameters
    APPLY_DOUBLE_PERCISION = true;

% Resampling parameters
    APPLY_RESAMPLING = true;
    RESAMPLING_RATE = 250;

% Filter parameters
    LOW_CUTOFF = 4;
    HIGH_CUTOFF = 30;
    APPLY_HIGHPASS_FILTER = true;
    APPLY_LOWPASS_FILTER = true;
    APPLY_BAND_FILTER = false;

% Channloc info parameters
	APPLY_CHANLOC = true;

% Cleanline parameters    
    APPLY_CLEANLINE = false;
   
% ASR parameters
    APPLY_ASR = true;
    SD_for_ASR = 15;
    SHOW_SPECTOPO_POST_ASR = false;
    Line_Noise_Criterion = 1;
    %need more parameters

% Interpolation parameters
    APPLY_CHANNELS_INTERPOLATE = true;

% Re-referencing to average parameters
    APPLY_REREFERENCE_TO_AVERAGE = false;
    SHOW_SPECTOPO_POST_REREFERENCE = false;

% Remove empty epochs parameters
	APPLY_CLEAR_NAN_ELECTRODES = false;
	NAN_ELECTRODES_TH = 15;
    
% Clean epochs
    MAX_BAD_CHANNEL_PER_EPOCH = 4;
    MAX_BAD_EPOCHS_PER_CHANNEL = 0.3; % in 0 to 1 scale.
    APPLY_CLEAN_CHANNEL_BY_TH = true;
    NEG_TH = -35;
    POS_TH = 35;
    WIN_STRAT = T_START;
    WIN_END = T_END;
    APPLY_CLEAN_CHANNEL_SPECTRA_TH = true;
    SPECRA.method = "wavelet"; % wavelet or bandpower.
    SPECRA.freq_resolution = 40;
    SPECRA.tStart = -2100;
    SPECRA.tEnd = 0;
    NSD = 2;
    
% Bands ranges
    bands_range.theta = [4 8];
    bands_range.alpha = [8 15];
    bands_range.beta = [15 30];
    bands = struct2cell(bands_range);
    
    
DATASET_NAME_CONVENTION = "subSUB_TRIAL_rawData";
%%%%%%%%%%%%%%%%%%%%%%%%%% PIPELINE start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load eeglab
if ~exist('ALLEEG', 'var')
	[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
else
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
end


if APPLY_DOUBLE_PERCISION
	pop_editoptions('option_single', 0); % set option to double precision
end

% load dataset to eeglab
EEG = pop_loadset(ds_path);

[~,ds_name,~] = fileparts(ds_path);
if isempty(EEG.subject) || isempty(EEG.session)
    [sub, trail] = Utils.OS.extract_sub_trail_from_file(ds_name, DATASET_NAME_CONVENTION);
    EEG.subject = str2double(sub);
    EEG.session = str2double(trail);
else
    sub = EEG.subject;
    trail = EEG.session;
end
file_name = ['sub' sub '_' trail '_ed'];



% handle events
EEG = Utils.DS.orderingEvents(EEG); 
EEG = Utils.DS.deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1); % leaves only 2->3/8/9 trials 
EEG = Utils.DS.checkGOToReleaseTimeDiff (EEG, MIN_DIF_BETWEEN_GO_AND_RELEASSE_TPNT, MAX_DIF_BETWEEN_GO_AND_RELEASSE_TPNT);
EEG = Utils.DS.deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1); % leaves only trials that meet time condition.

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
EEG = Utils.DS.strToDoubleEvent(EEG); %change event type back to double

if APPLY_ASR
	[EEG, EEG_org, SNR, eliminatedChannels, signal, noise] = Utils.DS.ASRCleaning (EEG, ALLEEG, CURRENTSET,...
        SD_for_ASR, Line_Noise_Criterion);
	if SHOW_SPECTOPO_POST_ASR
		figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
	end
end

EEG = Utils.DS.creatingEpochs(EEG, ALLEEG, CURRENTSET, T_START, T_END, file_name);

if APPLY_CLEAN_CHANNEL_BY_TH
    [EEG, ALLEEG, CURRENTSET] = Utils.DS.reject_by_tresh(EEG, ALLEEG, CURRENTSET, NEG_TH, POS_TH,...
        WIN_STRAT, WIN_END, MAX_BAD_CHANNEL_PER_EPOCH, MAX_BAD_EPOCHS_PER_CHANNEL);
end

if APPLY_CLEAN_CHANNEL_SPECTRA_TH
    [EEG, ALLEEG, CURRENTSET] = Utils.DS.reject_by_spec(EEG, ALLEEG, CURRENTSET, bands, SPECRA, NSD,...
        MAX_BAD_CHANNEL_PER_EPOCH, MAX_BAD_EPOCHS_PER_CHANNEL);
end

if APPLY_CHANNELS_INTERPOLATE
	EEG = pop_interp(EEG, EEG_org.chanlocs, 'spherical');
end


if APPLY_REREFERENCE_TO_AVERAGE
	EEG = Utils.DS.reReferenceToAverage(EEG);
	if SHOW_SPECTOPO_POST_REREFERENCE
		figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
	end
end



if APPLY_CLEAR_NAN_ELECTRODES
	EEG = Utils.DS.clearEmptyEpochs(EEG, NAN_ELECTRODES_TH);
end

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',tempdir); 
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

Utils.OS.copy_ds_to_userDir(file_name, tempdir, dest_dir);
end