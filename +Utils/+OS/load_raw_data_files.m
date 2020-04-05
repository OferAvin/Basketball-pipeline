%this function asks the user to choose two files, edf and csv. 
%it will return two cells contains {file_name, file_path}. if only one
%file seleced it will will ask for the second file. if worng file types were
%selected, the function return stat=2 and empty edf_file, csv_file.
function [edf_file csv_file stat str] = load_raw_data_files()
	stat = 1;
	str = "Select edf and csv files... ";
	[files, path] = uigetfile('*.edf;*.csv',"Select an edf File and a csv File",'MultiSelect', 'On');
	if isequal(files,0)
		stat = 2;
		str = ("No files were selected.");
	%only one file selected.
	elseif class(files) == 'char'
		if contains(files,".edf")
			edf_file = {files path};
			str = str + " edf file selected. Need to select csv file.";
			sec_file_type = "csv";
			[csvFile csvFilePath  stat_csv str_csv] = sec_file_selection(sec_file_type);
			if stat_csv == 0
				csv_file = {csvFile, csvFilePath};
			end
			stat = stat_csv;
			str = str + str_csv;
		elseif contains(files,".csv")
			csv_file = {files path};
			str = str + " csv file selected. Need to select edf file.";
			sec_file_type = "edf";
			[edfFile edfFilePath  stat_edf str_edf] = sec_file_selection(sec_file_type);
			if stat_edf == 0
				edf_file = {edfFile, edfFilePath};
			end
			stat = stat_edf;
			str = str_edf;
		else
			stat = 2;
			str = "Wrong file type selected.";
		end
	elseif length(files) == 2
		if contains(files(1),".edf") && contains(files(2),".csv")
			edf_file = {char(files(1)), path};
			csv_file = {char(files(2)), path};
            stat = 0;
            str = str + " Files selected.";
		elseif contains(files(1),".csv") && contains(files(2),".edf")
			csv_file = {char(files(1)), path};
			edf_file = {char(files(2)), path};
            stat = 0;
            str = str + " Files selected.";
		else
			stat = 2;
			str = ("Wrong files types were selected.");
		end
	else
		stat = 2;
		str = ("Too many files were selected.");
	end
end


%this functin is a sublimatory function for choose_file().
%in case only one file was selected, this function asks the user for the
%other file. again, if a worng file type was selected, the stat=2, and empy
%secFile will be returned.
function [secFile secFilePath  stat str] = sec_file_selection(fileType)
	secFile = nan;
	secFilePath = nan;
	stat = 1;
	str = "Select " + fileType + " file.";
	selection_type = "*." + fileType;
	selection_type_instruction = "Select "+ fileType + " File";
	[sec secPath] = uigetfile(selection_type,selection_type_instruction);
	if contains(sec,"." + fileType)
		secFile = sec;
		secFilePath = secPath;
		stat = 0;
		str = "Second file selection completed.";
	else
		stat = 2;
		str = fileType + " file not selected.";
	end	
end
