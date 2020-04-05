
function [EEG] = fix_chanlocs_labels(EEG)
% fix_chanlocs_labels - this function accept an EEG data struct, 
% and ommit prefix, suffix and whitespaces from the chanlocs names.
	chanlocsLables = {EEG.chanlocs.labels};
	for i=1:length(chanlocsLables)
		if startsWith(chanlocsLables(i),'EEG') && endsWith(chanlocsLables(i),"-Vref")
			lable_name = char(extractBetween(chanlocsLables(i),"EEG ","-Vref"));
			EEG.chanlocs(i).labels = lable_name;
		end
	end
end
