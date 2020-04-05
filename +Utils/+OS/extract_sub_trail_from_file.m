
function [sub trail] = extract_sub_trail_from_file(filename, naming_convention)
% extract_sub_trail_from_file - this function accepts a file name and naming convention 
% and extract sub num and trail num.
% input:
% 	filename = the file name to extract the data from.
%	naming_convention = use the reserved regex "SUB" and "TRIAL" to form file naming convention.
%						(until we'll have a better solution, it's ugly).  
%						an example for convention: 'sub_SUB_TRIAL_T'.
    sub = -1; 	trail = -1;
	sub_pre = char(extractBetween(naming_convention,"","SUB"));
	sub_post = char(extractBetween(naming_convention,"SUB","TRIAL"));
	trail_post = char(extractAfter(naming_convention,"TRIAL"));
	if length(sub_pre) < 1  | length(sub_post) < 1 | length(trail_post) < 1
		disp('Could not process given naming convention.');
		return;
	end
	sub_num = char(extractBetween(filename,sub_pre,sub_post));
	if length(sub_num)>1
		trail_pre = char(sub_pre+""+sub_num+""+sub_post);
		trail_num = char(extractBetween(filename,trail_pre,trail_post));
		if length(trail_num)>1
			sub_num= Utils.OS.validate_seq_number(sub_num, 3);
			trail_num= Utils.OS.validate_seq_number(trail_num, 2);
			if ~isempty(sub_num) && ~isempty(trail_num)
				sub = sub_num; trail = trail_num;
			end
		else
			disp('Could not find trail number.');
		end
	else
		disp('Could not find subject number.');
	end
end
