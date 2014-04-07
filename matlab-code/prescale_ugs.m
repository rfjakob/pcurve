function [ setugsv ] = prescale_ugs( targetugsv )
%PRESCALE_UGS Pulser-Einstellung statisch vorverzerren
%    Der Pulser lag ziemlich daneben sonst
%    Das mag aber auch an einem ungenauen Spannungsteiler liegen


% Woher sind die Messerte? Im GUI für U_GS linspace(1,10,100) eintragen,
% für U_DS 0.1 und 0.2, Messreihe starten, .mat File laden und Daten
% extrahieren (Spannungsteiler berücksichtigen nicht vergessen!)
%{
k=[];
for m=mr.messungen(1,:)
    k=[k;m.params.ugsv m.params.setugsv];
end
%}
messwerte=[...
...%Soll       Ist
    0.1533         0
    5.9698    5.2632
   11.7030   10.5263
   17.5204   15.7895
   23.3864   21.0526
   29.1707   26.3158
   35.1252   31.5789
   40.9556   36.8421
   46.2369   42.1053
   52.3218   47.3684
   57.9371   52.6316
   63.7670   57.8947
   69.4487   63.1579
   74.9736   68.4211
   80.6073   73.6842
   86.5069   78.9474
   92.2658   84.2105
   97.9935   89.4737
  103.8351   94.7368
  110.5561  100.0000];

    p=polyfit(messwerte(:,2),messwerte(:,1),1);
    %plot(messwerte(:,2),messwerte(:,1),1:100,polyval(p,1:100))

    setugsv=polyval(p,targetugsv);
end

