function EEG = checkGOToReleaseTimeDiff (EEG, MIN_DIF_BETWEEN_2_AND_3_TPNT, MAX_DIF_BETWEEN_2_AND_3_TPNT)
% checkGOToReleaseTimeDiff - this function checks the time difference between 2 and 3 event types 
% if diference is less than DIF_BETWEEN_2_AND_3_TPNT the trial will be
% eresed.
	global GO_Q;
    for i = 1:length(EEG.event)
        if(EEG.event(i).type==GO_Q)
            time_diff = EEG.event(i+1).latency - EEG.event(i).latency;
            if(time_diff < MIN_DIF_BETWEEN_2_AND_3_TPNT || time_diff > MAX_DIF_BETWEEN_2_AND_3_TPNT ) 
				EEG.event(i).type = 1;
				EEG.event(i+1).type = 1;
            end
        end
    end
end
