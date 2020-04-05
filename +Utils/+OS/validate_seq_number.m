%this functin make sure the sequance number is a valid number, at a specific length.
function [valid_seq_num]= validate_seq_number(num, num_length)
    if ~(isnan(str2double(num)))
        valid_seq_num = num;
        if length(num)<num_length
            valid_seq_num = pad(num,num_length,'left','0');
        end 
    else
        valid_seq_num = -1;
    end
end
