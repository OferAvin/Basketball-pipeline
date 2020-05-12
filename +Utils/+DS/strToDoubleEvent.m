function EEG = strToDoubleEvent(EEG)
    evnts = extractfield(EEG.event, 'type'); % extract the data
    evnts = strrep(evnts, 'boundary', '1'); % change strings no char number
    evnts = str2double(evnts); % change string to double array
    evnts = num2cell(evnts); % change array back to cell
    [EEG.event.type] = evnts{:}; % override EEG.event.type to double
end