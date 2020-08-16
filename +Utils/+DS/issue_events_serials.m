function [EEG] = issue_events_serials(EEG)
    [EEG.event(:).SR] = deal(0); [EEG.event(:).Class] = deal(0);
    t = num2cell(1:size(EEG.event,2)/2);
    t2 = extractfield(EEG.event,'type'); t2 = (t2==2);
    [EEG.event(t2).SR] = t{:};
    t3 = [EEG.event(~t2).type]; t3 = num2cell(t3);
    [EEG.event(t2).Class] = t3{:};
end