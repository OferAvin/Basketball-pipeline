
function del = get_delimiter()
% get_delimiter - this function set the path delimiter according to os.
% (Windows: '\', Unix: '/').
    if isunix
        del = '/';
    else
        del = '\';
    end
end
