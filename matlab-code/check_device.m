function [ output_args ] = check_device( fd,regex, idncmd )
%CHECK_DEVICE Prüfen ob IDN String mit Regex übereinstimmt, error() wenn
%nicht

    try
        fopen(fd)
    catch ex
        error(ex.message);
    end
    
    if ~exist('idncmd') % Die Stromzange versteht *IDN? nicht
        idncmd='*IDN?';
    end
    
    if(length(regex)>0)
        idn=query(fd,idncmd);
        if isempty(regexp(idn,regex))
            error(sprintf('Falsches Gerät angeschlossen?\nTatsächliche IDN: %s\nErwartet: %s\n',idn,regex));
        end
    end

end

