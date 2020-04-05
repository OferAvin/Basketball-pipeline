
function EEG = orderingEvents(EEG)
% orderingEvents - this function loops over EEG.event and look for good trials.
% in case it finds a good one (2->3->4/5/6), it reclassefys 4/5/6 events to 3/8/9.
% in case events are not in the right order it puts 1 till next 2.
	global SHOTS_TYPE;
	global GO_Q;
	global BALL_RELEASE;
	global SHOTS_LATENCY_INTERVAL;
    index = 1;
    while (index < length(EEG.event) - 1)
        if EEG.event(index).type == GO_Q
            if EEG.event(index+1).type == BALL_RELEASE
                if ismember(EEG.event(index+2).type,SHOTS_TYPE)
                    fixedShotType = index+2;
                    while ((fixedShotType <  length(EEG.event)) && ...
                        (ismember(EEG.event(fixedShotType+1).type, SHOTS_TYPE))) % shot type mark error 
                        EEG.event(fixedShotType).type = 1;
                        fixedShotType = fixedShotType + 1;
                    end
                    EEG = classefyEvent(EEG, index, fixedShotType);
                    EEG.event(fixedShotType).type = 1;
                    index = fixedShotType + 1;   
                elseif EEG.event(index+2).type == GO_Q          % in case 3  and than 2
                    if EEG.event(index+2).latency - EEG.event(index+1).latency > SHOTS_LATENCY_INTERVAL
                        [EEG,index] = setToOneAndJump(EEG, index, 2);
                    else
                        [EEG,index] = setToOneAndJump(EEG, index, 3);       
                    end
                else
                    [EEG,index] = setToOneAndJump(EEG, index, 3);   
                end
            elseif EEG.event(index+1).type == GO_Q            % in case 2 twos in a row
                if EEG.event(index+1).latency - EEG.event(index).latency > SHOTS_LATENCY_INTERVAL
                    [EEG,index] = setToOneAndJump(EEG, index, 1);  
                else
                    [EEG,index] = setToOneAndJump(EEG, index, 2);
                end
            else
                [EEG,index] = setToOneAndJump(EEG, index, 2);   
            end
        else
            [EEG,index] = setToOneAndJump(EEG, index, 1);
       end
    end
end



function EEG = classefyEvent(EEG, index, fixedShotType)
% classefyEvent - this function reclassefys shot type events from 5/6 to 9/8 respectively.
% shot types 4 deleted and 3 type left instead.
    toReclassefy = EEG.event(fixedShotType).type;
	if (toReclassefy == 5)
		EEG.event(index+1).type = 9;
	elseif (toReclassefy == 6)
		EEG.event(index+1).type = 8;
	end
end


function [EEG,index] = setToOneAndJump(EEG, index, num_of_indices)
% setToOneAndJump - this function set to one all indices from index to index+num_of_indices
    for i = 1:num_of_indices
        EEG.event(index).type = 1;
        index = index + 1;
    end
end
