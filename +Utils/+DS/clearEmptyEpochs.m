
function EEG = clearEmptyEpochs(EEG, NAN_ELECTRODES_TH)
% clearEmptyEpochs - this function clear epochs with more nan electrodes data than defined threshold.
    empty_epocs = 0;
    j = 1;
    for i = 1:length(EEG.epoch)
        nan_elct = isnan(EEG.data(:,350,i));
        if sum(nun_elct) > NAN_ELECTRODES_TH
            empty_epocs(j) = i;
            j = j + 1;
        end
    end
    EEG = pop_rejepoch(EEG, empty_epocs, 0);
end
