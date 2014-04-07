%% 1
k=[];
for m=mr.messungen(1,:)
    k=[k;m.params.ugsv m.params.setugsv];
end
k

%% 2
k=[];
for m=mr.messungen(:)'
    k=[k;m.messwerte.ugs];
end
k