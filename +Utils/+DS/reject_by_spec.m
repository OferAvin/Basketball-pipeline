function [EEG, ALLEEG, CURRENTSET] = reject_by_spec(EEG, ALLEEG, CURRENTSET, bands, specra, nSD,...
    max_bad_channel, max_bad_epochs_per_channel)
% reject_by_spec - this function reject and interpolate epochs according to
%   frequencies tresholds.
% Input:
%   EEG, ALLEEG, CURRENTSET - EEG struct.
%   bands - cell array of bands' bounds. each entry represent a band,
%       contains to elements vector (band's lower and higher frequency).
%   specra - a struct with the following fields:
%       method: the method used for spectral analysis (either bandpower or 
%           wavelet, default bandpower).
%       freq_resolution: for wavelet analysis.
%       tStart: for bandpower analysis.
%       tEnd: for bandpower analysis.
        
    if strcmpi(specra.method, 'wavelet')
        [rejfreqE] = Utils.DS.get_by_wavelet(EEG, bands,  specra, nSD);
    else
        [rejfreqE] = Utils.DS.bandpowerTBT(EEG, bands, nSD, specra);
    end
    [EEG, ALLEEG, CURRENTSET] = Utils.DS.reject_band_by_spectra_th(EEG, ALLEEG, CURRENTSET, rejfreqE,...
        max_bad_channel, max_bad_epochs_per_channel);  
end
