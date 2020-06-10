function [EEG, ALLEEG, CURRENTSET] = reject_by_tresh(EEG, ALLEEG, CURRENTSET, neg_th, pos_th, win_start, win_end, max_bad_channel, max_bad_epochs_per_channel)
% reject_by_tresh - this function use TBT tool to reject epoch according to
%   amplitutdes treshholds.
    EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, neg_th, pos_th, win_start, win_end, 1, 0);
    EEG = pop_TBT(EEG,EEG.reject.rejthreshE,max_bad_channel,max_bad_epochs_per_channel,0);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end 