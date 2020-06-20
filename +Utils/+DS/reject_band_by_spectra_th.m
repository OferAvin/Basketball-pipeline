function [EEG, ALLEEG, CURRENTSET] = reject_band_by_spectra_th(EEG, ALLEEG, CURRENTSET, method, th, band_limits, max_bad_channel, max_bad_epochs_per_channel)
% reject_by_spectra_th - this function use TBT tool to reject epoch according to
%   spectra treshholds.
    [EEG, ~, comrej]    = pop_rejspec(EEG, 1,'method' , method , 'threshold' , th ,'freqlimits' , band_limits);
    EEG = pop_TBT(EEG,EEG.reject.rejthreshE,max_bad_channel,max_bad_epochs_per_channel,0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end 