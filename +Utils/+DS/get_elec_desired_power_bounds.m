function elec_desired_power_bounds = get_elec_desired_power_bounds(EEG, desired_power_precentage)

temp = {EEG.event(([EEG.event(:).type] == 1)).latency};
time_boundrey = cell2mat(temp);
time_windows_duration = diff(time_boundrey);

ELECTRODS = size(EEG.data,1);
SHOTS_COUNT = length(time_boundrey );



window_start = zeros(length(time_boundrey),1); window_start(1) = 1;
for i=1:length(time_windows_duration)
    window_start(i+1) = window_start(i)+time_windows_duration(i);
end
last_windows_duration = size(EEG.data,2)-window_start(length(window_start));
time_windows_duration(length(time_windows_duration)+1) = last_windows_duration;
data_mat = zeros(ELECTRODS, length(time_boundrey));
for j=1:length(time_boundrey)
    data_mat(:,j) =  max(abs(EEG.data(:,window_start(j)+time_windows_duration(j))),[],2);
end

elec_desired_power_bounds = cell(ELECTRODS,1);
for k=1:ELECTRODS
    curr_elec = data_mat(k,:);
    max_b = floor(1+max(curr_elec)); min_b = floor(min(curr_elec));
    bins = min_b:max_b;
    h = histcounts(curr_elec,bins);
    power_counter = 0;
    desired_value = SHOTS_COUNT * desired_power_precentage;
    for l=1:length(bins)
        power_counter = power_counter + h(l);
        if power_counter >= desired_value
            elec_desired_power_bounds{k,1} = bins(l+1);
            break
        end
    end   
end


