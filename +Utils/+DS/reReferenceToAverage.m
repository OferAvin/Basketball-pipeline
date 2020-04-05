
function EEG = reReferenceToAverage(EEG)
% reReferenceToAverage - this function add a zeros channel and than re-reference the data to
% average. zeros chennel is removed at the end.
    EEG.nbchan = EEG.nbchan+1;
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
    EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';
    EEG = pop_reref(EEG, []);
    EEG = pop_select( EEG,'nochannel',{'initialReference'});
end
