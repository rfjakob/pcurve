function [ dp ] = getdatapointfromwave( waves, params )
%GETDATAPOINTFROMWAVE UGS und IDS aus Oszilloskop-Waveform-Graph extrahieren
%   Mittelt nach dem Einschwingen drüber
% L,D,B: Siehe Zeichnung im GUI 
    
        uds=waves.uds;
        ugs=waves.ugs;
        ids=waves.ids;
        
        L=params.L;
        D=params.D;
        B=params.B;
        
        % Anfang des UGS Puls finden, ist bei t=0 weil da ist der Trigger
        % t=0 index
        % Allerdings gibts of keine exakte Null,
        % also suchen wir mit 1ns Toleranz
        t0i = find(abs(uds.xvals) < 1e-9,1);
        assert(length(t0i)==1);
        xdelta=(max(uds.xvals)-min(uds.xvals))/(length(uds.xvals)-1);
        % Puls end index
        endi=t0i+round(L/xdelta);
        meas_start_index=t0i+round(D/xdelta);
        meas_end_index=endi-round(B/xdelta);
        assert(meas_end_index>0);
        
        dp.uds=mean(uds.yvals(meas_start_index:meas_end_index) );
        dp.ugs=mean(ugs.yvals(meas_start_index:meas_end_index) );
        % In den ersten Samples das DC Offset messen und abziehen
        cal_end_index=round(t0i*0.8); % Index des Anfang des Pulses minus 20%
        dcoffset=mean(ids.yvals(1:cal_end_index) );
        dp.ids=mean(ids.yvals(meas_start_index:meas_end_index))-dcoffset;
        dp.ids=entzerren_stromzange(dp.ids);
        
        ax=findobj('Tag','currplot');
        cla(ax)
        fullxi=1:length(ids.yvals);
        fullx=(fullxi-t0i)*xdelta*1e6;
        measxi=[meas_start_index:20:meas_end_index meas_end_index];
        measx=(measxi-t0i)*xdelta*1e6;
        calxi=[1:20:cal_end_index cal_end_index];
        calx=(calxi-t0i)*xdelta*1e6;
        
        plot(ax,fullx,ids.yvals,'red',...
            fullx,uds.yvals,'yellow',...
            fullx,ugs.yvals, 'green' ,...
            measx,ids.yvals(measxi),'o black' ,...
            calx,ids.yvals(calxi),'^ black',...
            measx,ugs.yvals(measxi),'o black',...
            measx,uds.yvals(measxi),'o black');
        legend(ax,'I_{DS}','U_{DS}','U_{GS}','Messb.','DC Cal',...
            'Location','Best','Orientation','horizontal');
        grid(ax,'on')
        title(ax,'Aktuelle Messung');
        xlabel(ax,'Zeit (us)');
        ylabel(ax,'(A / V)');
        
        global ugs_soll_ist
        ugs_soll_ist=[ugs_soll_ist; params.setugsv dp.ugs];
end

