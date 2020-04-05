function [EEG, ALLEEG, CURRENTSET] = highPass_filter(EEG, ALLEEG, CURRENTSET, lowCut, file_name)
    EEG = pop_eegfiltnew(EEG, 'locutoff',lowCut,'plotfreqz',0);
    EEG = eeg_checkset( EEG );
end
