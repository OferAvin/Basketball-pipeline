
function chanloc_file_path = construct_chanloc_file_path(EEG)
% construct_chanloc_file_path - this function construct the 'standard_1005.elc' 
% file path (used for setting chanloc at the main code block.)
%(this file location may change from one workstation to another, 
% according to the location of the installed eeglab.)
	del = Utils.OS.get_delimiter();
    eeglab_ver = strrep(char(EEG.etc.eeglabvers),".","_");
	sys_path = path;
    sys_path = strsplit(sys_path, ";");
    path_index = find(contains(sys_path,char(eeglab_ver)+""+del+"plugins"+del+"dipfit"));
    chanloc_file_path = char(sys_path(path_index(1))+""+del+"standard_BEM"+del+"elec"+del+"standard_1005.elc");
end
