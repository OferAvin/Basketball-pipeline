function [bandpower_data] = get_bandpower(EEG, chan, bands, T_window_ind)

    bandpower_data = cellfun(@(x) bandpower(permute(EEG.data(chan,T_window_ind,:),[3 2 1])',EEG.srate,x)',...
        bands, 'un', false);

end