function [name] = construct_file_name(files, file_type)
	idx = strcmp(file_type,{files.type});
	file = files(idx);
	if length(file) > 1
		printf("Too many "+file_type+" files were selected.")
		return;
	end
	name = file.name;
end
