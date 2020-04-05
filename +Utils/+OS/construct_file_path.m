function [path] = construct_file_path(files, file_type)
	idx = strcmp(file_type,{files.type});
	file = files(idx);
	if length(file) > 1
		printf("Too many "+file_type+" files were selected.")
		return;
	end
	path = char(file.path+""+file.name);
end
