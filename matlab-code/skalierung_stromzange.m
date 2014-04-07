function [ geandert ] = skalierung_stromzange( ids )
%SKALIERUNG_STROMZANGE Skalierung der Stromzange ggf anpassen
    
    global instruments

    % Spannungabschwächung des Transformators/Spannungsteilers (1 wenn keiner dran ist)
    %instruments.transformer=10; Wird jetzt über GUI eingestellt
    % Mögliche "Amps per Division" Einstellungen für die Stromzange
    ampsarray=[5,2,1,0.5,0.2,0.1,0.05,0.02,0.01];
    instruments.ampsarray=ampsarray;
    
    curamps=instruments.ampsperdiv;
    curidx=find(curamps == ampsarray);
    if ids > 5*curamps ... % Größer als 5 divisions
            && curidx > 1 % Und noch nicht auf höchster Stufe
        %fprintf('ids=%f > 5*curamps=5*%f\n',ids,curamps);
        newamps=ampsarray(curidx-1);
    elseif ids < 1*curamps ... % Kleiner als 1 division
            && curidx < length(ampsarray) % Und noch nicht niedrigste Stufe
        %fprintf('ids=%f < 1*curamps=1*%f\n',ids,curamps); 
        newamps=ampsarray(curidx+1);
    else
         newamps=curamps;
    end
    if newamps ~= curamps
        instruments.ampsperdiv=newamps;
        fprintf('Neue Skalierung der Stromzange: %u/div\n',instruments.ampsperdiv);
        fprintf(instruments.stromz,'AMPS %u',instruments.ampsperdiv);
        % Probe Faktor des Oszi wird in in oneshot gesetzt
        geandert=1;
    else
        geandert=0;
    end

end

