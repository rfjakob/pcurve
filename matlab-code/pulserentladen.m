function [ output_args ] = pulserentladen( input_args )
%PULSERENTLADEN Summary of this function goes here
%   Detailed explanation goes here
    global instruments
    
    pulser=instruments.pulser;
    oszi=instruments.oszi;
    wavegen=instruments.wavegen;
    
    % Laden
    fprintf(pulser,'voltage 100')
    fprintf(pulser,'pulse:delay 0ns')
    fprintf(pulser,'pulse:width 100ns') % 100us=max
    
    fprintf(oszi,':RUN')
    fprintf(wavegen, 'volt 0.1')
    fprintf(pulser,'voltage 2')
    fprintf(pulser,'pulse:delay 0ns')
    fprintf(pulser,'pulse:width 100000ns') % 100us=max
    fprintf(pulser,'trig:sour IMM')
    fprintf(pulser,'trig:sour IMM')
    fprintf(pulser,'trig:sour IMM')
    fprintf(pulser,'trig:sour IMM')
    fprintf(pulser,'trig:sour IMM')
end

