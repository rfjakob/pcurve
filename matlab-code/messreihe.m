function [ mr ] = messreihe(params)
%MESSREIHE Batch-Messung ausführen
%   Wird aus dem GUI aufgerufen

    global stopbatch instruments
    
    udsarray = eval(params.udsevaltext);
    ugsarray = eval(params.ugsevaltext);
    
    try
        close(3)
    end
    
    xtable=ones(length(udsarray),length(ugsarray))*NaN; % Spalten sind Messreihen für ein U_GS
    ytable=xtable; % Spalten sind Messreihen für ein U_GS
    legends={};
    
    ax=findobj('Tag','kennlinienplot');
    cla(ax);
    
    messungen=[]; % Messreihen für ein U_GS in den *Spalten*
    % for each U_GS
    for ugsi=1:length(ugsarray) % U_GS Index
        if stopbatch==1
            break
        end
        params.ugsv=ugsarray(ugsi);
        params.setugsv=calibratepulser(params);
        legends{ugsi}=sprintf('U_{GS}=%fV',params.ugsv);
        
        % for each U_DS
        udsi=1; % U_DS Index
        while udsi<=length(udsarray)   % Geht nicht mit "for" weil ich nochmal das selbe messen können muss
            overpmax=0;
            if stopbatch==1
                disp 'Abbruch durch Benutzer'
                break
            end
            params.udsv=udsarray(udsi);
            if params.udsv > 25 || params.udsv < 0.01
                fprintf('U_DS=%uV out of range, skipping',params.udsv)
                continue
            end
            dp=oneshot(params);
            
            p=dp.uds*dp.ids;
            if p > params.pmax
                mylog(sprintf('Pmax=%f ueberschritten (Pcurr=%f), keine weiteren Messungen fuer U_GS=%u\n',params.pmax,p,params.ugsv));
                overpmax=1;
            else % Nur machen wir unter pmax sind
                % Skalierung von Stromzange ggf anpassen
                if skalierung_stromzange(dp.ids)==1
                    %continue
                end
            end
            
            messungen(udsi,ugsi).ampsperdiv=instruments.ampsperdiv;
            messungen(udsi,ugsi).messwerte=dp;
            messungen(udsi,ugsi).params=params;
            
            % *Spalten* sind Messreihen für ein U_GS
            xtable(udsi,ugsi)=dp.uds;
            ytable(udsi,ugsi)=dp.ids;
            plotIt(ax)

            if overpmax==1
                break;
            end
            
            udsi=udsi+1;
        end
    end
    
    % Pulser wieder auf 0 setzen, braucht laaange bis er wirklich ankommt
    fprintf(instruments.pulser,'voltage 0')
    % DC Source auch
    fprintf(instruments.dc,'voltage 0')
    
    mr.messungen=messungen;
    mr.udstable=xtable;
    mr.idstable=ytable;
    mr.legends=legends;
    % Auf die Platte speichern zur Sicherheit
    fn=sprintf('messreihe_%u_%u_%u_%02uh%02um%02.0fs.mat',datevec(now));
    mylog(sprintf('Messreihe abgeschlossen! Speichere Ergebnisse in %s...\n',fn));
    save(fn,'mr');
    figure();
    plotIt(gca);
    
    function plotIt(ax)
            cla(ax);
            set(ax,'XScale','log');
            set(ax,'YScale','log');
            loglog(ax,xtable,ytable,'-o');
            xlabel(ax,'U_{DS} (V)');
            ylabel(ax,'I_{DS} (A)');
            title(ax,'Kennlinienfeld');
            grid(ax,'on');
            % Verlustleistungshyperbel
            lims=axis(ax);
            s=params.pmax / lims(4);
            e=lims(2);
            legends1=legends;
            if(s<e)
                hold on
                pmaxhypx=linspace(s,e,100);
                pmaxhypy=params.pmax./pmaxhypx;
                plot(ax,pmaxhypx,pmaxhypy,'- black');
                legends1{end+1}='P_{max}';
            end
            legend(ax,legends1,'Location','Best');
    end
end

