
function [EEG, ALLEEG, CURRENTSET] = bandFilteringData(EEG, ALLEEG, CURRENTSET, frex, file_name)
%this function does band filter
    EEG = pop_eegfiltnew(EEG, frex (1),frex (end),826,0,[],1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[file_name '.set'],'gui','off'); 
    EEG = eeg_checkset( EEG );
end
