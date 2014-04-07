function [ i_corr ] = entzerren_stromzange( i )
%ENTZERREN_STROMZANGE Stromzange hat je nach Messbereich unterschiedliche
%Fehler -> entzerren

global instruments

% Current/Division v
%      100       200       500         1         2
% v soll
ytable = ...
[0     0         0         0         0         0      % 0A
 0.1   0.1020       NaN       NaN       NaN       NaN % 0.1A
 0.2   0.2000    0.2120       NaN       NaN       NaN % 0.2A
 0.5   0.4900    0.5020    0.5400       NaN       NaN % 0.5A
 1        NaN    0.9000    1.0250    1.0900       NaN % 1A
 2        NaN       NaN    2.0000    2.1000    1.900];% 2A
x=ytable(:,1);

amps=instruments.ampsperdiv;

if amps==0.1
    y=ytable(:,2);
elseif amps==0.2
    y=ytable(:,3);
elseif amps==0.5
    y=ytable(:,4);
elseif amps==1
    y=ytable(:,5);
elseif amps==2
    y=ytable(:,6);
else
    i_corr=i;
    return
end

ix=find(~isnan(y));
deg=length(ix)-1;
p=polyfit(y(ix),x(ix),deg);
i_corr=polyval(p,i);

end