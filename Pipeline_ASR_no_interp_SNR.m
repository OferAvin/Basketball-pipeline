clear all
%Constants
SAPMLE_RATE = 300;
MIN_DIF_BETWEEN_2_AND_3_SEC = 0.6;
MAX_DIF_BETWEEN_2_AND_3_SEC = 2;
MIN_DIF_BETWEEN_2_AND_3_TPNT = MIN_DIF_BETWEEN_2_AND_3_SEC * SAPMLE_RATE; 
MAX_DIF_BETWEEN_2_AND_3_TPNT = MAX_DIF_BETWEEN_2_AND_3_SEC * SAPMLE_RATE;
RESAMPLING_RATE = 250;
LOW_CUTOFF = 4;
HIGH_CUTOFF = 35;
SD_for_ASR = 20;
%FREQUECY_TO_FILTER = linspace(4,35,39);
%MAX_AMPLITUDE = 12;
%load eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%set option to double precision
pop_editoptions('option_single', 0);

%% arranging dataset 
[EEG, sub_num, trial_num] = loadFile(ALLEEG, EEG, CURRENTSET);
file_name = ['sub' num2str(sub_num) '_' num2str(trial_num) '_ed'];
EEG = orderingEvent(EEG);                                         
EEG = deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1);%leaves only 2->3/8/9 trials
EEG = check2To3TimeDiff (EEG, MIN_DIF_BETWEEN_2_AND_3_TPNT, MAX_DIF_BETWEEN_2_AND_3_TPNT);
EEG = deleteEventTypes (EEG, ALLEEG, CURRENTSET, 1);

%% Cleaning The Data
EEG = pop_resample (EEG, RESAMPLING_RATE);          %Downsampling
[EEG, ALLEEG, CURRENTSET] = highPass_filter(EEG, ALLEEG,  CURRENTSET, LOW_CUTOFF,  file_name);

% ChannelData
if isfield(EEG.chaninfo, 'filename') == 0
    del = set_del();
    %set chanloc.
    chanloc_file_path = construct_chanloc_file_path(EEG,del);
    EEG=pop_chanedit(EEG, 'lookup', chanloc_file_path);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
end



% [EEG, ALLEEG, CURRENTSET] = CleanLine(EEG, ALLEEG,  CURRENTSET);

[EEG, ALLEEG, CURRENTSET] = lowPass_filter(EEG, ALLEEG, HIGH_CUTOFF, file_name);
%[EEG, ALLEEG, CURRENTSET] = bandFilteringData(EEG, ALLEEG, CURRENTSET, FREQUECY_TO_FILTER, file_name);

%% Alingning events and cutting data byb events
EEG = aligningEvents(EEG);

%EEG = aligningEventsByEpochs(EEG);

EEG = pop_rmdat( EEG, {'3' '8' '9'},[-4 0.06] ,0); % cutting data by event

%% ASR

[EEG, SNR, eliminatedChannels, signal, noise] = ASRCleaning (EEG, ALLEEG, CURRENTSET, SD_for_ASR);

figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');

%% Re-reference to average

% EEG = reReferenceToAverage(EEG);

figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
%% allocating short epochs
t_start= -2.4; % time of beginning of short epoch in sec.
t_end= 0.05; % time of end of long short in sec.

% pop_eegplot( EEG, 1, 1, 1);
% uiwait;

EEG = creatingEpochs(EEG, ALLEEG, CURRENTSET, t_start, t_end, file_name);


% EEG = clearEmptyEpochs(EEG);


%% confirm and save


%save dataset to local tempdir
check_set_and_save(ALLEEG, EEG, CURRENTSET, file_name);

pop_eegplot( EEG, 1, 1, 1);

figure(1);
hold on;
% figure; pop_spectopo(EEG, 1, [0      482343.3333], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
uiwait;

eeglab redraw

copy_to_userDir(file_name);



%% FUNCTIONS

%this function opens the file explorer and the user need to choose a set file.
%the function extract from the file sub_num and trial_num.
function [EEG, sub_num, trial_num] =  loadFile(ALLEEG, EEG, CURRENTSET)
    [fileName , filePath] = uigetfile('*.set','Please select a .set file');
    EEG = pop_loadset(fileName , filePath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    sub_num = char(extractBetween(fileName,"sub","_"));
    trial_num = char(extractBetween(fileName,"_","_"));
end

%this function loops over EEG.event and look for good trials,
%in case it finds a good one (2->3->4/5/6) it reclassefy 4/5/6 events to 3/8/9
%in case events are not in the right order it puts 1 till next 2.
function EEG = orderingEvent(EEG)
    index = 1;
    while (index < length(EEG.event) - 1)
        if EEG.event(index).type == 2
            if EEG.event(index+1).type == 3
                if (EEG.event(index+2).type == 4 || EEG.event(index+2).type == 5 || ...
                    EEG.event(index+2).type == 6)
                    fixedShotType = index+2;
                    while ((fixedShotType <  length(EEG.event)) && ...
                        (EEG.event(fixedShotType+1).type == 4 || ...
                        EEG.event(fixedShotType+1).type == 5 || ...
                       EEG.event(fixedShotType+1).type == 6))
                        EEG.event(fixedShotType).type = 1;
                        fixedShotType = fixedShotType + 1;
                    end
                    EEG = classefyEvent(EEG, index, fixedShotType);
                    EEG.event(index+2).type = 1;
                    index = index + 3;   
                elseif EEG.event(index+2).type == 2          %in case 3  and than 2
                    if EEG.event(index+2).latency - EEG.event(index+1).latency > 900
                        [EEG,index] = setToOneAndJump(EEG, index, 2);
                    else
                        [EEG,index] = setToOneAndJump(EEG, index, 3);       
                    end
                else
                    [EEG,index] = setToOneAndJump(EEG, index, 3);   
                end
            elseif EEG.event(index+1).type == 2            %in case 2 twos in a row
                if EEG.event(index+1).latency - EEG.event(index).latency > 900
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
    
 %this function reclassefy shot type events from 5/6 to 9/8 respectively.
 %shot types 4 deleted and 3 type left instead.
function EEG = classefyEvent(EEG, index, fixedShotType)
    for i = 1:length(EEG.event)
        toReclassefy = EEG.event(fixedShotType).type;
        if (toReclassefy == 5)
            EEG.event(index+1).type = 9;
        elseif (toReclassefy == 6)
            EEG.event(index+1).type = 8;
        end
    end
end

%this function checks the time difference between 2 and 3 event types 
%if diference is less than DIF_BETWEEN_2_AND_3_TPNT the trial will be
%eresed
function EEG = check2To3TimeDiff (EEG, MIN_DIF_BETWEEN_2_AND_3_TPNT, MAX_DIF_BETWEEN_2_AND_3_TPNT)
    for i = 1:length(EEG.event)
        if(EEG.event(i).type==2)
            time_diff = EEG.event(i+1).latency - EEG.event(i).latency;
            if(time_diff < MIN_DIF_BETWEEN_2_AND_3_TPNT || time_diff > MAX_DIF_BETWEEN_2_AND_3_TPNT ) 
            EEG.event(i).type = 1;
            EEG.event(i+1).type = 1;
            end
        end
    end
end

%this function set to one all indices from index to index+num_of_indices
function [EEG,index] = setToOneAndJump(EEG, index, num_of_indices)
    for i = 1:num_of_indices
        EEG.event(index).type = 1;
        index = index + 1;
    end
end
      
%this function gets a vector and event type and delete all the event type's
%occurrence from the vector
function EEG = deleteEventTypes (EEG, ALLEEG, CURRENTSET, eventType)
    events2delete = find (extractfield(EEG.event,'type') == eventType); 
    EEG = pop_editeventvals(EEG,'delete',events2delete);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end

function [EEG, ALLEEG, CURRENTSET] = highPass_filter(EEG, ALLEEG, CURRENTSET, lowCut, file_name)
    EEG = pop_eegfiltnew(EEG, 'locutoff',lowCut,'plotfreqz',0);
    EEG = eeg_checkset( EEG );
end

function [EEG, ALLEEG, CURRENTSET] = CleanLine(EEG, ALLEEG, CURRENTSET)
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:21] ,'computepower',1,'linefreqs',[50 120] ,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
    EEG = eeg_checkset( EEG );
end

function [EEG, ALLEEG, CURRENTSET] = lowPass_filter(EEG, ALLEEG, highCut, file_name)
    EEG = pop_eegfiltnew(EEG, 'hicutoff',highCut,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[file_name '.set'],'gui','off'); 
    EEG = eeg_checkset( EEG );
  end

%this function does band filter
function [EEG, ALLEEG, CURRENTSET] = bandFilteringData(EEG, ALLEEG, CURRENTSET, frex, file_name)
    EEG = pop_eegfiltnew(EEG, frex (1),frex (end),826,0,[],1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[file_name '.set'],'gui','off'); 
    EEG = eeg_checkset( EEG );
end

%this function creates epochs, cuts data t_start seconds before 'go' 
%and t_end second after a throw event. 
function [EEG, ALLEEG, CURRENTSET] = creatingEpochs (EEG, ALLEEG, CURRENTSET, t_start, t_end, file_name)
    EEG = pop_epoch( EEG, {  '8'  '9' '3' }, [t_start         t_end], 'newname', [file_name '.set'], 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
    EEG = eeg_checkset( EEG );
end

%this function alining throw events by 'the_jump' artifact
function EEG = aligningEvents(EEG)
    for i=2:2:length(EEG.event)-120 % run over all the epoch 
    event_latency = EEG.event(i).latency;
    [~,ind]= max(EEG.data(:,event_latency:event_latency+120)); ind= ind'; the_jump= (median (ind))+event_latency; % find where the jump is (inside the epoch)
    EEG.event(i).latency = the_jump - 90;  % changin the event time to 300ms before the jump 
    end 
end

%this function alining throw events *by epochs* with the 'the_jump' artifact
function EEG = aligningEventsByEpochs(EEG)
    for i=1: size (EEG.data,3) % run over all the epoch 
    [~,ind]= max(EEG.data(:,:,i)'); ind= ind'; the_jump= (median (ind)); % find where the jump is (inside the epoch)
    EEG.event(max(EEG.epoch(i).event)).latency = the_jump + size(EEG.data,2)*(i-1)-90;  % changin the event time to 300ms before the jump 
    end 
end

%this function perform ASR using clean_rawdata() it returns 
%the channels that has been eliminated by ASR and SNR
function [EEG, SNR, eliminatedChannels, signal, noise] = ASRCleaning (EEG, ALLEEG, CURRENTSET, SD_for_ASR)   
    preASR_EEG = EEG;
    EEG = clean_artifacts(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
%     EEG = clean_rawdata(EEG, 5, -1, 0.8, 4, SD_for_ASR, -1 );
    eliminatedChannels = findEliminatedChannels(preASR_EEG ,EEG);
    [SNR, signal, noise] = getSNR(preASR_EEG, EEG, eliminatedChannels(2,:));
    EEG = eeg_checkset( EEG );
end

%this function get the EEG struct before and after ASR and finds
%the removed channels
function eliminatedChannels = findEliminatedChannels(EEG ,EEG_clean)
    chanNum = size(EEG.chanlocs,2);
    cleanChanNum = size(EEG_clean.chanlocs,2);
    eliminatedChannels = repmat(" ",[2 chanNum-cleanChanNum]);
    cleanIndex = 1;
    elimIndex = 1;
    msg = char(chanNum-cleanChanNum+" "+ "channels was eliminated by clean_rawdata function ");
    waitfor(msgbox(msg));
    for i = 1:size(EEG.chanlocs,2)
        if(EEG.chanlocs(i).labels == EEG_clean.chanlocs(cleanIndex).labels)
            cleanIndex = cleanIndex + 1;
        else
            eliminatedChannels(1,elimIndex) = EEG.chanlocs(i).labels;
            eliminatedChannels(2,elimIndex) = i;
            elimIndex = elimIndex + 1;
        end
    end
end

%this function calculate SNR, it uses fillNaNRaws() on the removed channels
%in order to do matrix subtraction
function [SNR, signal, noise] = getSNR (EEG, EEG_clean, NaNChannels)
    signal = fillNaNRaws(EEG_clean, NaNChannels);
    noise = EEG.data - signal;
    SNR = 10*log10(var(signal,0,2)./var(noise,0,2)); % SNR per channel, column vector
end

%this function get the cleaned EEG after ASR and a vector of the 
%channels that has been eliminated by ASR and fill NaN instead
function cleanData = fillNaNRaws(EEG_clean, NaNChannels)
    cleanData = EEG_clean.data;
    for i = 1:length(NaNChannels)
        addNaNIndex = str2num(NaNChannels(i));
        cleanData = [cleanData(1:addNaNIndex-1,:);nan(1,size(cleanData,2));cleanData(addNaNIndex:end,:)];
    end
end

%this function add a zeros channel and than re-reference the data to
%average. zeros chennel is removed at the end.
function EEG = reReferenceToAverage(EEG)
    EEG.nbchan = EEG.nbchan+1;
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
    EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';
    EEG = pop_reref(EEG, []);
    EEG = pop_select( EEG,'nochannel',{'initialReference'});
end

%go over every trial, and remove channel whith higher amplitude than amp 
%hinting its an artifact
function EEG = removeHighAmps(EEG, amp)
    for itrial= 1: EEG.trials
       for ichan= 1: size (EEG.data,1)
           threshold = std (EEG.data(ichan,:,itrial)) > amp ; % if channel std is bigger then 12 at the specific trial, the channel will removed
           if threshold == 1 , EEG.data (ichan,:,itrial) = nan; end     
       end
    end
end

%this function store EEG to ALLEEG and save dataset to local tempdir
function check_set_and_save(ALLEEG, EEG, CURRENTSET, file_name)
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',tempdir);
end


function EEG = clearEmptyEpochs(EEG)
    empty_epocs = 0;
    j = 1;
    for i = 1:length(EEG.epoch)
        nun_elct = isnan(EEG.data(:,350,i));
        if sum(nun_elct) > 15
            empty_epocs(j) = i;
            j = j + 1;
        end
    end
    EEG = pop_rejepoch(EEG, empty_epocs, 0);
end


function copy_to_userDir(file_name)
    source_file_set = char(tempdir+""+file_name+".set");
    source_file_fdt = char(tempdir+""+file_name+".fdt");
    dest_dir = uigetdir;
    display([dest_dir+"\"+file_name]);
    if exist(dest_dir+"\"+file_name+".set") == 2
        time_stemp = strrep(datestr(now,'dd-mm-yyyy HH_MM_SS FFF')," ","_");
        copyfile(source_file_set,  dest_dir+"\"+file_name+"_"+time_stemp+".set", 'f');
        copyfile(source_file_fdt,  dest_dir+"\"+file_name+"_"+time_stemp+".fdt", 'f');
    else
        copyfile(source_file_set,  dest_dir, 'f');        
        copyfile(source_file_fdt,  dest_dir, 'f');        
    end
end

function del = set_del()
%this fumction set the path delimiter according to os.
    if isunix
        del = '/';
    else
        del = '\';
    end
end

function chanloc_file_path = construct_chanloc_file_path(EEG, del)
%this function construct the 'standard_1005.elc' file path (used for setting chanloc at the main code block.)
%(this file location may change from one workstation to another, according to the location of the installed eeglab.)
    eeglab_ver = strrep(char(EEG.etc.eeglabvers),".","_");
	sys_path = path;
    sys_path = strsplit(sys_path, ";");
    sys_path_index = find(contains(sys_path,char(eeglab_ver)+""+del+"plugins"+del+"dipfit"));
    chanloc_file_path = char(sys_path(sys_path_index(1))+""+del+"standard_BEM"+del+"elec"+del+"standard_1005.elc");
end

