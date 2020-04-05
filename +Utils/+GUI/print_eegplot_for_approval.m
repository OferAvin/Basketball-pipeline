
function [user_response] = print_eegplot_for_approval(EEG, ALLEEG)
	EEG = pop_eegfiltnew(EEG, 4, 40, 826, 0, [], 1);
    h = get(groot,'CurrentFigure');
    [ALLEEG, EEG,CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    EEG = eeg_checkset( EEG );
    pop_eegplot( EEG, 1, 1, 1);
    g = get(groot,'CurrentFigure');
    uiwait;
    try
        close(h);
        close(g);
    catch
        fprintf("Please close all open windows before continue.");
    end
    dbox_title = 'EDF Data extruction'; 
    quest_text = {'\fontsize{13}Complete operation and save dataset? (unfiltered dataset will be save.)',' Press No to abort operation.'}; 
    opts.Default = {'Yes'}; 
    opts.Interpreter = 'tex'; 
    quest_user_response = questdlg(quest_text,dbox_title,'Yes','No', opts);
    if ~isempty(quest_user_response)
        user_response = strcmp(quest_user_response,'Yes');
end
