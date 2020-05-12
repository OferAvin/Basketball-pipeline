function [EEG, ALLEEG, CURRENTSET] = CleanLine(EEG, ALLEEG, CURRENTSET)
    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan] ,'computepower',1,'linefreqs',[50 120] ,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
    EEG = eeg_checkset( EEG );
end
