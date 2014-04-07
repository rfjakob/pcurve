function [ newugs ] = calibratepulser( params )
%CALIBRATEPULSER Pulser auf 1% genau auf Sollwert einstellen
%   Iterativ: Puls abfeuern, mit Oszi Ist-Wert messen, Pulser-Einstellung
%   nachregeln
    
    global instruments stopbatch
    
    pulser=instruments.pulser;
    
    h=[];
    
    % Auf kleine Spannung setzen
    params.udsv=1;
    % Pulser-Einstellung, erstmal statisch vorverzerren
    params.setugsv=prescale_ugs(params.ugsv*params.spannungsteiler) ;
    okonce=0; % Zweimal testen
    while 1
        if stopbatch==1
            newugs=0;
            return
        end
        instruments.ampsperdiv=5; % Auf Maximum setzen damit ja nichts hin wird, für die Kalibration wurscht
        fprintf(instruments.stromz,'AMPS %u',instruments.ampsperdiv);
        % Pulser braucht laaange um Spannung einzustellen
        % v.a. wenn sie niedriger wird, hier einstellen und 1s warten
        fprintf(pulser,'voltage %f',params.setugsv)
        %fprintf(pulser,'trig:sour IMM');
        %pause(1)
        %fprintf(pulser,'trig:sour IMM');
        % Abfeuern
        dp=oneshot(params);
        ugs=dp.ugs;
        h=[h;ugs params.setugsv/params.spannungsteiler params.ugsv];
        absfehler=params.ugsv-ugs;
        relfehler=abs((params.ugsv-ugs)/params.ugsv);
        fprintf('calibratepulser: soll_ugsv=%f, ist_ugsv=%f set_ugsv=%f',params.ugsv,ugs,params.setugsv)
        
        ax=findobj('Tag','kennlinienplot');
        cla(ax);
        set(ax,'XScale','lin');
        set(ax,'YScale','lin');
        x=1:size(h,1);
        plot(ax,x,h(:,1),'-o',x,h(:,2),'-o',x,h(:,3),'black');
        xlabel(ax,'Iteration');
        ylabel(ax,'U_{GS} ( V )');
        title(ax,'Pulser Kalibration');
        grid(ax,'on');
        legend(ax,'ist','eingestellt','soll','Location','best');
        
        if abs(absfehler) < 0.001 ...  % Wenn soll=0 ist der relative Fehler unbrauchbar
                || relfehler < 0.001 % 0.1%
           if okonce==1
               fprintf(' GOOD#2, Done!\n');
               break
           else
               fprintf(' GOOD#1, Validating...\n');
               okonce=1;
           end
        else
            fprintf(' BAD\n');
            okonce=0;
        end
        
        params.setugsv=params.setugsv + ...
            absfehler*params.spannungsteiler*0.3; % Warum 0.3? Braucht nicht viel länger
                                                  % und ist viel stabiler 
     
        assert(params.setugsv < params.ugsv*params.spannungsteiler*1.3,...
            'Einstellspannung > 130% Sollspannung - Hardwarefehler??')
    end
    newugs=params.setugsv;
    fprintf('calibratepulser: OK.\n');
end

