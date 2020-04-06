

function [EEG, EEG_org, SNR, eliminatedChannels, signal, noise] = ASRCleaning (EEG, ALLEEG, CURRENTSET, SD_for_ASR)
% ASRCleaning - this function perform ASR using clean_rawdata() it returns 
% the channels that has been eliminated by ASR and SNR.
	EEG_org = EEG;
    EEG = clean_artifacts(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
    eliminatedChannels = findEliminatedChannels(EEG ,EEG_clean);
    [SNR, signal, noise] = getSNR(EEG, EEG_clean, eliminatedChannels(2,:));
    EEG = EEG_clean;
	EEG.etc.SNR = SNR;
    EEG.etc.eliminatedChannels = eliminatedChannels;
    EEG = eeg_checkset( EEG );
end


function eliminatedChannels = findEliminatedChannels(EEG ,EEG_clean)
% findEliminatedChannels - this function get the EEG struct before and after ASR and finds
% the removed channels.
    chanNum = size(EEG.chanlocs,2);
    cleanChanNum = size(EEG_clean.chanlocs,2);
    eliminatedChannels = repmat(" ",[2 chanNum-cleanChanNum]);
    msg = char(chanNum-cleanChanNum+" "+ "channels was eliminated by clean_rawdata function ");
    waitfor(msgbox(msg));
    cl_chanloc = extractfield(EEG_clean.chanlocs, 'labels');
    org_eeg_chanloc =  extractfield(EEG.chanlocs, 'labels');
    eliminatedChannels(1,:) = setdiff(org_eeg_chanloc,cl_chanloc);
    eliminatedChannels(2,:) = find(contains(org_eeg_chanloc,eliminatedChannels(1,:)));
end


function [SNR, signal, noise] = getSNR (EEG, EEG_clean, NaNChannels)
% getSNR - this function calculate SNR, it uses fillNaNRaws() on the removed channels
% in order to do matrix subtraction
    signal = fillNaNRaws(EEG_clean, NaNChannels);
    noise = EEG.data - signal;
    SNR = 10*log10(var(signal,0,2)./var(noise,0,2)); % SNR per channel, column vector
end


function cleanData = fillNaNRaws(EEG_clean, NaNChannels)
% fillNaNRaws - this function get the cleaned EEG after ASR and a vector of the 
% channels that has been eliminated by ASR and fill NaN instead.
    cleanData = EEG_clean.data;
    for i = 1:length(NaNChannels)
        addNaNIndex = str2num(NaNChannels(i));
        cleanData = [cleanData(1:addNaNIndex-1,:);nan(1,size(cleanData,2));cleanData(addNaNIndex:end,:)];
    end
end
