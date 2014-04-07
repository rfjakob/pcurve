function datapoint=oneshot(params)
%ONESHOT Eine Messung durchführen (einen Shot mit dem Pulser)

    global instruments
    
    result.params=params;
    %{
    params.udsv V
    params.ugsv V
    params.udslen ns
    params.ugslen ns
    params.ugsdelay ns
    %}
    
    oszi=instruments.oszi;
    pulser=instruments.pulser;
    oszi=instruments.oszi;
    
    % Pulser und DC Source brauchen ein Zeitl um Spannung einzustellen - als erstes Spannung setzen!
    fprintf(pulser,'voltage %f',params.setugsv)
    
    %fprintf(pulser,'pulse:delay %uns',-params.ugsdelay)
    fprintf(pulser,'pulse:width %fns',params.L * 1e9)
    fprintf(instruments.dc,'voltage %f',params.udsv)
    
    fprintf(oszi,':SINGLE');
    % Bei mehr als 500mV/div wird die Genauigkeit *MIES*
    % D.h. er zeigt z.B. statt 7.5V 6.0V an!
    range=min(0.5*8,params.udsv);
    fprintf(oszi,'CHANnel1:RANGE %fV',range);
    fprintf(oszi,'CHANnel1:OFFSET %fV',params.udsv);
    range=min(0.5*8,params.ugsv);
    fprintf(oszi,'CHANnel2:RANGE %fV', range )
    fprintf(oszi,'CHANnel2:OFFSET %fV',params.ugsv);
    probe=instruments.ampsperdiv/0.01;
    fprintf(oszi,':CHANNEL4:PROBE %f',probe);
    fprintf(oszi,':TIMebase:RANGe %fns',params.L*1e9*2);
    fprintf(oszi,':TIMebase:DELay %f',params.L/2)
    
    % Warten bis DC Source die Spannung eingestellt hat
    k=0;
    soll=params.udsv;
    lim=100;
    for k=1:lim
        pause(0.1);
        ist=query(instruments.dc,'MEASure:VOLTage?');
        ist=str2double(ist);
        relfehler=abs((ist-soll)/soll);
        absfehler=abs(ist-soll); % Wenn soll=0 ist der relative Fehler unbrauchbar
        if absfehler < 0.01 || relfehler < 0.05
            break
        end
    end
    if k>=lim
        fprintf('Warnung: Ungenaue U_DS, soll=%uV ist=%uV\n',soll,ist);
    end
   
    % trig:sour IMM - generates a single pulse, and then
    % stops triggering.
    fprintf(pulser,'trig:sour IMM');
    fprintf(pulser,'trig:sour MAN'); % Damit man "Single Pulse" drücken kann
   
    pause(0.1) % oszi braucht Zeit zum Zeichnen, wenn man zu früh nachfragt
             % bleibt der Schirm schwarz. Für die Messung egal, aber nicht
             % schön.
    waves.uds=getwaveform(1, oszi);
    waves.ugs=getwaveform(2, oszi);
    waves.ids=getwaveform(4, oszi);
    datapoint=getdatapointfromwave(waves,params);
    datapoint.quickmeas=getquickmeas(oszi);
    
    % Da verliert er das Bild, also besser nicht
    %fprintf(oszi,':RUN');
    
    %fprintf('oneshot(%u,%u): Done.\n',params.udsv,params.udslen);
end
