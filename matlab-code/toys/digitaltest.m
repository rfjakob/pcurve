fclose(instrfind())
oszi=visa('agilent','TCPIP0::128.131.85.225::inst0::INSTR');
oszi.InputBufferSize = 1000000;
oszi.Timeout=1;
fopen(oszi);
digitaldata=getdigital(oszi);
analogres=getwaveform(1, oszi);
analogdata=analogres.yvals;
x=analogres.xvals;

plot(x, analogdata, x, digitaldata(1,:));