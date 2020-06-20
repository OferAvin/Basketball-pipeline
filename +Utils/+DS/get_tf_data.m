function tf_data = get_tf_data(EEG, chan, high_freq, low_freq, freq_resolution)
    [~,~,~,times,~,~,~,tf_data]= pop_newtimef( EEG, 1, chan, [-2800    496], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', EEG.chanlocs(chan).labels, 'baseline',[-2300 -1800], 'freqs', [low_freq high_freq],'nfreqs', freq_resolution, 'plotphase', 'off', 'padratio', 1,'trialbase','on');
    close;
    tf_data = abs(tf_data).^2;
    tf_data = newtimeftrialbaseln(tf_data, times, 'baseline', [-2300 -1800],'trialbase','on');
end