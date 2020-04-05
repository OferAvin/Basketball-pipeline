
function [files_struct] = load_input_files(file_types)
% load_input_files - this function allow the end user to load input files for the script use.
	types = file_types;
	types = types(~cellfun('isempty',types));
	if length(types) < 1
		disp("Empty file types list.");
		return;
	end
	types = arrayfun(@validate_file_type, types);
	max_selection_itertion = length(types);
	files_struct = struct();
	req_files = types;
	for i=1:max_selection_itertion
		[files_struct, types_selected] = choose_files(files_struct, types);
		types = setdiff(types,types_selected);
		if isempty(types)
			break;
		end
	end
	if ~isempty(types) % not all file types were selected
		files_struct = struct();
	end
	files_struct(1) = [];
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
	t = strsplit(name,"."); t = char(t(length(t)));
	files_selected(files_index).type = t;
	type_selected = "."+t;
end
