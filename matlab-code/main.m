function main
%MAIN Messkonsole (GUI) starten

    

    
    if enable_instruments==1
        initvisa();
    else
        disp 'enable_instruments=0: initvisa() skipped'
    end
    
    gui
    
end