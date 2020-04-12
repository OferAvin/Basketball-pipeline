%
%	BGU - Computational and EEG Lab
%		


% !!!CHECK PREREQUISITES!!!
addpath(pwd);
%% Consts
FILES_SUFFIXES = [".edf" ".csv"];
CHECK_MONTAGE = true;
FIX_EVENTS_TYPE_DATA = true;
FIX_CHANLOCS_LABELS = true;
SET_CHANLOC = true;
RAW_DATA_NAME_CONVENTION = "sub_SUB_TRIAL_";
APPROVAL_REQUIRED = true;
ENTER_SUB_TRIAL_INFO = true;

%% Script code
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

files = Utils.OS.load_input_files(FILES_SUFFIXES, '');
if isempty(files)
	disp("Files not selected.");
	return;
end
csv_path = Utils.OS.construct_file_path(files, 'csv');
edf_path = Utils.OS.construct_file_path(files, 'edf');

if isempty(csv_path) || isempty(edf_path)
	return;
end

if CHECK_MONTAGE
	montage = Utils.OS.check_for_montage(csv_path);
end

EEG = pop_biosig(edf_path);

if FIX_EVENTS_TYPE_DATA
	[EEG] = Utils.DS.fix_event_type_data(EEG, csv_path);
end

if FIX_CHANLOCS_LABELS
	[EEG] = Utils.DS.fix_chanlocs_labels(EEG);
end

EEG = eeg_checkset( EEG );
% ommit triger channel.
EEG = pop_select( EEG, 'nochannel',{'Trigger'});

if SET_CHANLOC
    [EEG, ALLEEG] = Utils.DS.set_chanloc(EEG, ALLEEG, CURRENTSET);
end

edf_file =  Utils.OS.construct_file_name(files, 'edf');
[sub trail] = Utils.OS.extract_sub_trail_from_file(edf_file, RAW_DATA_NAME_CONVENTION);
setname = char("sub" + sub + "_" + trail + "_rawData"); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname', setname,'gui','off');

if ENTER_SUB_TRIAL_INFO
	EEG.subject = sub;
	EEG.session = trail;
end
% save dataset at the system temp folder.
EEG = pop_saveset( EEG, 'filename', setname, 'filepath', tempdir);
if APPROVAL_REQUIRED
	Utils.GUI.print_msgbox('EDF Data extruction', {'\fontsize{13}Complete operation and save dataset? (unfiltered dataset will be save.)',' Press No to abort operation.'} )
	save_final_dataset = Utils.GUI.print_eegplot_for_approval(EEG, ALLEEG);
else
	save_final_dataset = true;
end

if save_final_dataset
	Utils.OS.copy_ds_to_userDir(setname,'');
else
	disp("Aborting operation.")
end
