function result=getwaveform(channelno, oszi)
% Graph aus dem Oszi holen
% Jakob Unterwurzacher 2010
% Basiert auf
% http://www.mathworks.com/matlabcentral/fileexchange/28887
%{
% USAGE:

oszi=visa('agilent','TCPIP0::128.131.85.225::inst0::INSTR');
oszi.InputBufferSize = 10000000;
oszi.Timeout=1;
fopen(oszi);
result=getwaveform(1, oszi);
plot(result.xvals,result.yvals);
%}

    visaObj=oszi;
    
    % Specify data from Channel 1
    fprintf(visaObj,':WAVEFORM:SOURCE CHAN%u',channelno); 
    % Specify 1000 points at a time by :WAV:DATA?
    %fprintf(visaObj,':WAVEFORM:POINTS 1000');
    fprintf(visaObj,':WAVEFORM:POINTS 10000');
    % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
    fprintf(visaObj,':WAVEFORM:FORMAT WORD');
    % Set the byte order on the instrument as well
    fprintf(visaObj,':WAVEFORM:BYTEORDER LSBFirst');
    % Get the preamble block
    preambleBlock = query(visaObj,':WAVEFORM:PREAMBLE?');
    % The preamble block contains all of the current WAVEFORM settings.  
    % It is returned in the form <preamble_block><NL> where <preamble_block> is:
    %    FORMAT        : int16 - 0 = BYTE, 1 = WORD, 2 = ASCII.
    %    TYPE          : int16 - 0 = NORMAL, 1 = PEAK DETECT, 2 = AVERAGE
    %    POINTS        : int32 - number of data points transferred.
    %    COUNT         : int32 - 1 and is always 1.
    %    XINCREMENT    : float64 - time difference between data points.
    %    XORIGIN       : float64 - always the first data point in memory.
    %    XREFERENCE    : int32 - specifies the data point associated with
    %                            x-origin.
    %    YINCREMENT    : float32 - voltage diff between data points.
    %    YORIGIN       : float32 - value is the voltage at center screen.
    %    YREFERENCE    : int32 - specifies the data point where y-origin
    %                            occurs.

    % Now send commmand to read data
    fprintf(visaObj,':WAV:DATA?');
    % read back the BINBLOCK with the data in specified format and store it in
    % the waveform structure
    waveform.RawData = binblockread(visaObj,'uint16');

    % Close the VISA connection.
    %fclose(visaObj);


    % Data processing: Post process the data retreived from the scope
    % Extract the X, Y data and plot it 

    % Maximum value storable in a INT16
    maxVal = 2^16; 

    %  split the preambleBlock into individual pieces of info
    preambleBlock = regexp(preambleBlock,',','split');

    % store all this information into a waveform structure for later use
    waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
    waveform.Type = str2double(preambleBlock{2});
    waveform.Points = str2double(preambleBlock{3});
    waveform.Count = str2double(preambleBlock{4});      % This is always 1
    waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
    waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
    waveform.XReference = str2double(preambleBlock{7});
    waveform.YIncrement = str2double(preambleBlock{8}); % V
    waveform.YOrigin = str2double(preambleBlock{9});
    waveform.YReference = str2double(preambleBlock{10});
    waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
    waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
    waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
    waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

    % Generate X & Y Data
    waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement + waveform.XOrigin;
    waveform.YData = (waveform.RawData - waveform.YReference) .* waveform.YIncrement + waveform.YOrigin; 
    
    result.xvals=waveform.XData;
    result.yvals=waveform.YData';
end