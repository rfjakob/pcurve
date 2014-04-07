function [ x,y ] = batchanalyze( results )
%BATCHANALYZE Daten aus allen Oszilloskop-Graphen extrahieren
%   und auf die Platte speichern

    res1=results(1);
    lastugsv=res1.params.targetugsv;
    ugsvvals=lastugsv;
    xy=[];
    for rowindex=1:length(results)
        res1=results(rowindex);
        %{
        if lastugsv~=res1.params.ugsv
            loglog(xy(:,1),xy(:,2),'o');
            xy=[];
            ugsvvals=[ugsvvals; res1.params.ugsv];
            lastugsv=res1.params.ugsv;
        end
        %}

        dp=getdatapointfromwave(res1);

        xy=[xy;dp.uds,dp.ids];
        %xy=sortrows(xy,1);
    end
        
    try
        close(4)
    end
    figure(4)
    set(gca, 'XScale', 'log') 
    set(gca, 'YScale', 'log') 
    loglog(xy(:,1),xy(:,2),'o');
    
    legend(num2str(ugsvvals));
    
    save(sprintf('graphs/ids-uds-%04.1f.mat',res1.params.targetugsv),'xy');
end

