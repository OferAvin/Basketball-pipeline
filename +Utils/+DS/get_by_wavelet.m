function [rejfreqE] = get_by_wavelet(EEG, bands, specra, nSD)
% get_by_wavelet - this function performs wavelet spectral analysis and
%   returns a logical matrix of rejected trials.
    low_freq = bands{1,1}(1); high_freq = bands{end,1}(2); elec = 1:EEG.nbchan;
    [electrodes_tf, freqs]= arrayfun(@(x) get_tf_data(EEG, x, high_freq, low_freq, specra.freq_resolution,specra),...
        elec, 'un', false); % get spectral analysis to each electrode.
    rel_electrodes_tf = cellfun(@(x) get_relative_tf(x, bands, freqs{1,1}), electrodes_tf, 'un', false); % transform to relative power.
    elec_bands_bounds = cellfun(@(x) get_band_bounds(x, nSD), rel_electrodes_tf, 'un', false); % get for each signal, bands' bounds.
    rejfreqE = cellfun(@(x,y) get_rej_trials(x, y), rel_electrodes_tf, elec_bands_bounds, 'un', false); % find rejected trials.
    rejfreqE = cell2mat(rejfreqE');
end

function [tf_data, freqs] = get_tf_data(EEG, chan, high_freq, low_freq, freq_resolution, specra)
% get_tf_data - this function perform wavelet spectral analysis.
   figure; [~,~,~,times,freqs,~,~,tf_data]= pop_newtimef( EEG, 1, chan, [specra.tStart    specra.tEnd], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', EEG.chanlocs(chan).labels, 'baseline',[-2300 -1800], 'freqs', [low_freq high_freq],'nfreqs', freq_resolution, 'plotphase', 'off', 'padratio', 1,'trialbase','off');
    close;
    tf_data = abs(tf_data).^2;
    tf_data = newtimeftrialbaseln(tf_data, times, 'baseline', [-2300 -1800],'trialbase','off');
end

function [rel_tf] = get_relative_tf(tf_data, bands, freqs)
% get_relative_tf - this function transforms each signal's bands to relative
%   power.
    rel_tf = cellfun(@(x) squeeze(get_band_rel(tf_data, x, freqs)), bands, 'un', false);
end

function band_rel = get_band_rel(tf_data, band_range, freqs)
% get_band_rel - this function applys relative power transformation.
    band = freqs>=band_range(1) & freqs<band_range(2);
    band_data = sum(tf_data(band,:,:),1);
    all_power = sum(tf_data(:,:,:),1);
    band_rel = mean(band_data./all_power);
end

function [bounds] = get_band_bounds(tf_data, nSD) 
% get_band_bounds - this function finds each bands' bounds according to
%   provided nSD.
    [lower_bounds, upper_bounds] = cellfun(@(x) Utils.DS.getNsdAroundMean(x, nSD), tf_data, 'un', false);
    bounds = cellfun(@(x,y) [x,y],lower_bounds,upper_bounds, 'un', false);
end

function rej_trials = get_rej_trials(trials, bounds)
% get_rej_trials - this function finds each signal rejected trials
%   according to provided bounds.
    bands_rej_trials = cellfun(@(x,y) (x>y(2) | x<y(1))' ,trials, bounds, 'un', false);
    rej_trials = sum(cell2mat(bands_rej_trials));
    rej_trials(rej_trials>1) = 1;
end