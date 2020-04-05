
function EEG = aligningEvents(EEG)
% aligningEvents - this function alining throw events by 'the_jump' artifact
    for i=2:2:length(EEG.event)-120 % run over all the epoch 
    event_latency = EEG.event(i).latency;
    [~,ind]= max(EEG.data(:,event_latency:event_latency+120)); ind= ind'; the_jump= (median (ind))+event_latency; % find where the jump is (inside the epoch)
    EEG.event(i).latency = the_jump - 90;  % changin the event time to 300ms before the jump 
    end 
end
