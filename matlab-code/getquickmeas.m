function [ res ] = getquickmeas(oszi)
%GETQUICKMEAS Quick Meas des Oszi auslesen
% Werden in initvisa eingestellt

    %{
-> :MEASure:RESults?
<- +3.186E+00,+4.5E+00,+2.5E-03
    %}

    r=query(oszi,':MEASure:RESults?');
    
    [uds, r] = strtok(r, ',');
    [ugs, r] = strtok(r, ',');
    [ids, r] = strtok(r, ',');
    
    res.uds=str2double(uds);
    res.ugs=str2double(ugs);
    res.ids=str2double(ids);
end

