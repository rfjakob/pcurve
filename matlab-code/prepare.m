function [ params ] = prepare( handles )
% Global gültige Einstellungen einlesen, VISA verbinden

    global instruments
    
    params.spannungsteiler=str2double(get(handles.spannungsteiler,'String'));
    params.pmax=str2double(get(handles.pmax,'String'));
    params.L=str2double(get(handles.L,'String'))/1e6;
    params.D=str2double(get(handles.D,'String'))/1e6;
    params.B=str2double(get(handles.B,'String'))/1e6;
    
    assert(params.D+params.B < params.L);
    
    c.oszi_visastring=get(handles.oszi_visastring,'String');
    c.dc_visastring=get(handles.dc_visastring,'String');
    c.stromz_visastring=get(handles.stromz_visastring,'String');
    c.pulser_visastring=get(handles.pulser_visastring,'String');
    initvisa(c);

end

