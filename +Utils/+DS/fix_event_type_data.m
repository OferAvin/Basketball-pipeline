
function [EEG] = fix_event_type_data(EEG, csv_file)
% fix_event_type_data - this function accept an EEG data struct and a csv_file
% {fileName,filePath}, and will fix the EEG.event.type,EEG.urevent.type numbers
% corresponding to the csv file data.
	try
		csv_data = readtable(csv_file);
		csv_data_comments = csv_data.Comments;
		if csv_data_comments(1) > 0
            zeroTimeEvent = true;
            csv_data_comments(1) = 1;
		end
		csv_data_comments(csv_data_comments == 0) = [];
		if (length(csv_data_comments) > length([EEG.event.type])) && zeroTimeEvent
            csv_data_comments(1) = [];
		end       
		clear csv_data;
		c = num2cell(csv_data_comments);
		[EEG.event.type] = c{:};
		[EEG.urevent.type] = c{:};
	catch
		error("Error fixing events type data. CSV file: " + csv_file)
	end
end
