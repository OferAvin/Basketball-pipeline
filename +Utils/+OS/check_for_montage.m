%this function check for the montage used on recording.
function [montage] = check_for_montage(csv_file)
	disp(csv_file);
	try
		fmt = repmat('%s',1,30);
		fileID = fopen(csv_file);
		csv_head = textscan(fileID, fmt, 20,'delimiter',',');
		
		montageIdx = find(strcmp(csv_head{1,1},'Montage='));
		if montageIdx > 0
			montage = char(csv_head{1,2}(montageIdx));
			disp("Recorded using montage: " + montage + newline);			
		else
			warning('Recorded without montage.');
		end
    catch
		warning('Could not check montage.');
	end
end
