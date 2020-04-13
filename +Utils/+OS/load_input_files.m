
function [files_struct] = load_input_files(file_types, input_mode)
% load_input_files - this function asks the end user to load input files for a script use.
%   Input: file_types - an array of file extensions. cannot be empty. 
%               Example: [".set"]
%          input_mode - either 'file' or 'dir' (default is 'file'). if set
%          to 'file', user will be asked to select files. if set to 'dir'
%          user will be asked to select a folder, and all files with
%          file_types extension will be loaded.
%
%   Output: files_struct - a files struct array with fields:
%               name
%               path
%               file
%               type
%               to access a file use: files_struct(1) or files_struct(i).file

    if ~isequal(input_mode,'dir')
        input_mode = 'file';
    end
    
    
    % Function code
	types = file_types;
	types = types(~cellfun('isempty',types));
	if length(types) < 1
		disp("Empty file types list.");
		return;
	end
	types = arrayfun(@validate_file_type, types);
    files_struct = struct();
    if isequal(input_mode,'file')
        [files_struct, types] = load_files(files_struct, types);
        if ~isempty(types) % not all file types were selected
            files_struct = struct();
        end
    else
        files_struct = load_dir(files_struct, types);
    end
	
	files_struct(1) = [];
end

function [files_struct, types] = load_files(files_struct, types)
    max_selection_itertion = length(types);
	for i=1:max_selection_itertion
		[files_struct, types_selected] = choose_files(files_struct, types);
		types = setdiff(types,types_selected);
		if isempty(types)
			break;
		end
	end
end


function pref = validate_file_type(s)
	if ~startsWith(s,".")
		pref = "."+lower(s);
	else
		pref = lower(s);
	end
end

function [files_struct, types_selected] = choose_files(files_struct, types)
	types_selected = [""];
	filter_form = @(s) "*"+s+";";
	types_filter = strjoin(arrayfun(filter_form, types)); 
	[files, path] = uigetfile(types_filter,"Files selection",'MultiSelect', 'On');
	if isequal(files,0) % no file were selected.
		return;
	end
	if class(files) == 'char' % only one file was selected
		[files_struct, types_selected(1)] = enter_file(files_struct, files, path);
	else
		for i=1:length(files)
			[files_struct, type_selected] = enter_file(files_struct, files{i}, path);
			types_selected(length(types_selected)+1) = type_selected;
		end
		types_selected = types_selected(~cellfun('isempty',types_selected));
	end	
end

function [files_selected, type_selected] = enter_file(files_selected, name, path)
	files_index = length(files_selected) + 1; 
	files_selected(files_index).name = name;
	files_selected(files_index).path = path;
    del = Utils.OS.get_delimiter();
    files_selected(files_index).file = [path, del, name];
	t = strsplit(name,"."); t = char(t(length(t)));
	files_selected(files_index).type = t;
	type_selected = "."+t;
end

function files_struct = load_dir(files_struct, types)
    input_dir = uigetdir;
    input_dir_files = dir(input_dir);
    for i=1:size(input_dir_files,1)
        if ~(input_dir_files(i).isdir)
            if is_file_type(types, input_dir_files(i).name)
                files_struct = enter_file(files_struct,  input_dir_files(i).name, input_dir_files(i).folder);
            end
        end
    end
end

function isFileType = is_file_type(types , file_name)
    t = strsplit(file_name,"."); t = char(t(length(t)));
    isFileType = ismember(['.' t], types);
end
