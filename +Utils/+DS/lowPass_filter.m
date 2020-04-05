function [EEG, ALLEEG, CURRENTSET] = lowPass_filter(EEG, ALLEEG, highCut, file_name)
    EEG = pop_eegfiltnew(EEG, 'hicutoff',highCut,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[file_name '.set'],'gui','off'); 
    EEG = eeg_checkset( EEG );
end
