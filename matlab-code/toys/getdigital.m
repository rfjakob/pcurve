%{
USAGE:

oszi=visa('agilent','TCPIP0::128.131.85.225::inst0::INSTR');
oszi.InputBufferSize = 10000000;
oszi.Timeout=1;
fopen(oszi);
data=getdigital(oszi);
%}

function result=getdigital(oszi)
% Jakob Unterwurzacher 2010
% Basiert auf
% http://www.mathworks.com/matlabcentral/fileexchange/28887
    fprintf(oszi,':WAVEFORM:SOURCE POD1'); 
    fprintf(oszi,':WAVeform:POINts:MODE RAW');
    fprintf(oszi,':WAVEFORM:POINTS 10000');
    fprintf(oszi,':WAVEFORM:FORMAT WORD');
    fprintf(oszi,':WAVEFORM:BYTEORDER LSBFirst');
    fprintf(oszi,':WAV:DATA?');
    data=uint16(binblockread(oszi,'uint16'))';
    
    result=zeros(20,10000);
    
    for k=0:15
       result(k+1,:)=bitand(data,uint16(2^k));
    end
end