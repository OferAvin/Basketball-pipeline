
function [EEG, ALLEEG, CURRENTSET] = creatingEpochs (EEG, ALLEEG, CURRENTSET, t_start, t_end, file_name)
% creatingEpochs - this function creates epochs, cuts data t_start seconds before 'go' 
% and t_end second after a throw event. 
    EEG = pop_epoch( EEG, {  '8'  '9' '3' }, [t_start         t_end], 'newname', [file_name '.set'], 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
    EEG = eeg_checkset( EEG );
end
