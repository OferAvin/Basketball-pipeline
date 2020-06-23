function [EEG, ALLEEG, CURRENTSET] = reject_band_by_spectra_th(EEG, ALLEEG, CURRENTSET, rejfreqE, max_bad_channel, max_bad_epochs_per_channel)
% reject_by_spectra_th - this function use TBT tool to reject epochs and interpolate according to
%   rejfreqE (logical matrix of rejected epochs).
    EEG = pop_TBT(EEG,rejfreqE,max_bad_channel,max_bad_epochs_per_channel,0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end 