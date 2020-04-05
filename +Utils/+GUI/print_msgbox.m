
function print = print_msgbox(dbox_title, msgbox_text)
% print_msgbox - this functin print out a simple generic msgbox, with provided title and text.
    opts.Default = {'Yes'}; 
    opts.Interpreter = 'tex'; 
    questdlg(msgbox_text,dbox_title,'Yes', opts);
end
