
function copy_ds_to_userDir(ds_name, ds_path, dest_dir)
% copy_ds_to_userDir - this function accepts a dataset name and requests
% the end user for a destination directory. the function moves the dataset
% files to the destination directory. if files with same names already exist 
% in the directory, the dataset files name will be add with a timestamp.
    source_file_set = char(ds_path+""+ds_name+".set");
    source_file_fdt = char(ds_path+""+ds_name+".fdt");
	del = Utils.OS.get_delimiter();
    if ~exist(dest_dir, 'dir')
        dest_dir = uigetdir;
    end
    if exist(char(dest_dir+""+del+ds_name+".set"), 'file') == 2
        time_stemp = strrep(datestr(now,'dd-mm-yyyy HH_MM_SS FFF')," ","_");
        file_path = [dest_dir del ds_name];
        copyfile(source_file_set,  file_path+"_"+time_stemp+".set", 'f');
        copyfile(source_file_fdt,  file_path+"_"+time_stemp+".fdt", 'f');
    else
        copyfile(source_file_set,  dest_dir, 'f');        
        copyfile(source_file_fdt,  dest_dir, 'f');        
    end
end
