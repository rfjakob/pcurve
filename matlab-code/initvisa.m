function instruments=initvisa(visastrings)
%INITVISA Instruments inititialisieren
%   GPIB/VISA Verbindungen öffnen

    % VISA Handles für die Instruments
    global instruments
    
    if isfield(instruments, 'initialized') && instruments.initialized==1
        return
    end
    
    % Start-Einstellung
    instruments.ampsperdiv=0.1;
    
    mylog('Init instruments... ')
    if isempty(instrfind())==0;
        fclose(instrfind())
        delete(instrfind())
    end


    % Agilent MSO7104A
    %oszi=visa('agilent','USB0::0x0957::0x1755::MY48040040::0::INSTR'); % Über USB
    %oszi=visa('agilent','TCPIP0::mwoszi2.emce.tuwien.ac.at::inst0::INSTR'); % Funktioniert nicht mit DNS, weiß der Teufel warum.
    oszi=visa('agilent',visastrings.oszi_visastring); % Mit der IP funktionierts, DNS nicht
    oszi.InputBufferSize = 10000000;
    oszi.Timeout=1;
    check_device(oszi,'MSO7104A')
    
    fprintf(oszi,'*RST');
    fprintf(oszi,':SINGLE');
    fprintf(oszi,':TRIGger:EDGE:SOURce EXTernal ');
    fprintf(oszi,':TRIGger:LEVel 4V');
    % Channel UDS (1)
    fprintf(oszi,':MEASure:VAVerage CHANnel1');
    fprintf(oszi,':CHANnel1:BWLimit ON');
    fprintf(oszi,':CHANnel1:IMPedance ONEM'); % Geht manchmal auf 50 Ohm von selber - besser hier setzen!
    % Channel UGS (2)
    fprintf(oszi,':MEASure:VTOP CHANnel2');
    fprintf(oszi,':CHANnel2:BWLimit ON');
    fprintf(oszi,':CHANnel2:DISPlay ON');
    fprintf(oszi,':CHANnel2:IMPedance ONEM');
     % Channel IDS=Stromzange (4)
    fprintf(oszi,':MEASure:VTOP CHANnel4');
    fprintf(oszi,':CHANnel4:IMPedance FIFTY');
    fprintf(oszi,':CHANnel4:SCALe 10mV');
    fprintf(oszi,':CHANnel4:OFFSET 30mV');
    fprintf(oszi,':CHANnel4:BWLimit ON');
    fprintf(oszi,':CHANnel4:UNIT AMP');
    fprintf(oszi,':CHANnel4:DISPlay ON');
    % Brauch keine Statistiken, macht parsen in getquickmeas() nur
    % schwieriger
    fprintf(oszi,':MEASure:STATistics CURR');

    fprintf(oszi,':TRIGger:SWEep normal');
    instruments.oszi=oszi;
    
    % AVTECH Pulse Generator
    pulser = visa('agilent',visastrings.pulser_visastring);
    check_device(pulser,'AVTECH')
    fprintf(pulser,'*RST')
    % trig:sour HOLD - selects no trigger source (triggering stops)
    %           MAN  - selects the "Single Pulse" pushbutton as the trigger source.
    fprintf(pulser,'trig:sour MAN')
    fprintf(pulser,'output on')
    instruments.pulser=pulser;

    % Stromzange+AM5030
    stromz = visa('agilent',visastrings.stromz_visastring);
    check_device(stromz,'AM5030','ID?'); % Versteht *IDN? nicht
    % query statt fprintf weil das Ding immer was zurückgibt ("ÿ")
    query(stromz,'INIT');
    query(stromz,'FPLOCK ON');
    query(stromz,'coupling dc');
    query(stromz,sprintf('AMPS %u',instruments.ampsperdiv));
    % Hier unbedingt query statt fprintf weil sonst wird nicht gewartet bis
    % Degaussing fertig ist
    query(stromz,'DEGAUSS');
    instruments.stromz=stromz;

    %{
    % Agilent 33522A Waveform Generator
    try
        %wavegen = visa('agilent','USB0::0x0957::0x2307::MY50000160::0::INSTR');
        wavegen = visa('agilent','USB0::0x0957::0x2307::MY50001047::0::INSTR');
        fopen(wavegen);
        query(wavegen,'*IDN?');
        fprintf(wavegen,'*RST'); % query() hier gibt Fehler
        fprintf(wavegen, 'TRIGGER:SOURCE EXT');
        fprintf(wavegen, 'function square');
        fprintf(wavegen, 'volt 1');
        fprintf(wavegen, 'volt:offset 0.5');
        fprintf(wavegen, 'frequency 1000000')
        fprintf(wavegen, 'burst:mode triggered')
        fprintf(wavegen, 'burst:ncycles 1')
        fprintf(wavegen, 'burst:state on')
        fprintf(wavegen, 'output on');
        instruments.wavegen=wavegen;
    catch exception
        wavegen=0
    end
    %}
    
    % Agilent 6633B DC Power Suppy
    dc=visa('agilent',visastrings.dc_visastring);
    check_device(dc,'6633B');
    fprintf(dc,'*RST');
    fprintf(dc,'CURRENT 0.1');
    fprintf(dc,'OUTPut ON');
    instruments.dc=dc;
   
    instruments.initialized=1;
    mylog('OK\n');
end

