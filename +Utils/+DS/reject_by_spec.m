function [EEG, ALLEEG, CURRENTSET] = reject_by_spec(EEG, ALLEEG, CURRENTSET, bands, spec, nSD)
    

    if strcmpi(spec.method, 'wavelet')
        [rejfreqE] = Utils.DS.get_by_wavelet(EEG, bands,  spec, nSD);
    else
        
    end
    
end
