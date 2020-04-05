
function EEG = deleteEventTypes (EEG, ALLEEG, CURRENTSET, eventType)
% deleteEventTypes - this function gets a vector and event type and delete all the event type's
% occurrence from the vector.
    events2delete = find (extractfield(EEG.event,'type') == eventType); 
    EEG = pop_editeventvals(EEG,'delete',events2delete);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end
