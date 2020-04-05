
function [EEG, ALLEEG] = set_chanloc(EEG, ALLEEG, CURRENTSET) 
% set_chanloc - this function checks if chanloc file was set on current eeg dataset.
% if file was not set, this function sets it.
	if isfield(EEG.chaninfo, 'filename') == 0 % file not set, setting chanloc.
		chanloc_file_path = Utils.OS.construct_chanloc_file_path(EEG);
		EEG=pop_chanedit(EEG, 'lookup', chanloc_file_path); % ,'eval','chans = pop_chancenter( chans, [],[]);');
		[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
	end
end
