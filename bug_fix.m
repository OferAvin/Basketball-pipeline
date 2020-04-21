% baseline with rng
rng(0);
files = Utils.OS.load_input_files(["set"], 'dir');
dest_dir1 = uigetdir;
eeglab;
for i=1:length(files)
    [ALLEEG, EEG, CURRENTSET] = preprocess_pipeline(files(i).file, dest_dir1, ALLEEG, EEG);
    eeg_array1{:,i} = EEG; 
end
dest_var1 = [dest_dir1 '\array1.mat'];
save(dest_var1, 'eeg_array1');
clear; close all; clc;

% compare baseline with rng
rng(0);
files = Utils.OS.load_input_files(["set"], 'dir');
dest_dir2 = uigetdir;
eeglab;
for i=1:length(files)
    [ALLEEG, EEG, CURRENTSET] = preprocess_pipeline(files(i).file, dest_dir2, ALLEEG, EEG);
    eeg_array2{:,i} = EEG;
end
dest_var2 = [dest_dir2 '\array2.mat'];
save(dest_var2, 'eeg_array2');
clear; close all; clc;


% compare without rng
files = Utils.OS.load_input_files(["set"], 'dir');
dest_dir3 = uigetdir;
eeglab;
for i=1:length(files)
    [ALLEEG, EEG, CURRENTSET] = preprocess_pipeline(files(i).file, dest_dir3, ALLEEG, EEG);
    eeg_array3{:,i} = EEG;
end
dest_var3 = [dest_dir3 '\array3.mat'];
save(dest_var3, 'eeg_array3');
clear; close all; clc;

dest_var1 = 'C:\WS\TestZone\preprocess\tests\r1\array1.mat';
dest_var2 = 'C:\WS\TestZone\preprocess\tests\r2\array2.mat';
dest_var3 = 'C:\WS\TestZone\preprocess\tests\r3\array3.mat';
load(dest_var1); load(dest_var2); load(dest_var3);
% compare first run to sec
for i=1:length(eeg_array1)
   r1_snr = eeg_array1{1,i}.etc.SNR; r1_snr = r1_snr(~isnan(r1_snr));
   r2_snr = eeg_array2{1,i}.etc.SNR; r2_snr = r2_snr(~isnan(r2_snr));
   if ~isequal(r1_snr, r2_snr)
      disp("r1 and r2 not equal"); disp(i); break; 
   end
end

% compare first run to third
for i=1:length(eeg_array1)
   r1_snr = eeg_array1{1,i}.etc.SNR; r1_snr = r1_snr(~isnan(r1_snr));
   r3_snr = eeg_array3{1,i}.etc.SNR; r3_snr = r3_snr(~isnan(r3_snr));
   if ~isequal(r1_snr, r3_snr)
      disp("r1 and r3 not equal"); disp(i); break; 
   end
end