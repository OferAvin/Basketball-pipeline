
files = Utils.OS.load_input_files([".set"], 'dir');
dest_folder = uigetdir; % or manualy write the destinaton folder
eeglab

for i=1:length(files)
   [ALLEEG, EEG, CURRENTSET] = preprocess_pipeline(files(i).file, dest_folder, ALLEEG, EEG);
   eeg_array{:,i} = EEG;
end