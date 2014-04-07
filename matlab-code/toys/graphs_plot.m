% Resultate Plotten

load '../graphs/ids-uds-04.5.mat'
xy45=xy;
load '../graphs/ids-uds-05.0.mat'
xy50=xy;
load '../graphs/ids-uds-05.5.mat'
xy55=xy;
load '../graphs/ids-uds-06.0.mat'
xy60=xy;

loglog(xy45(:,1),xy45(:,2),'- .',xy50(:,1),xy50(:,2),'- .',xy55(:,1),xy55(:,2),'- .',xy60(:,1),xy60(:,2),'- .')
axis([0.1 10 1 100])
xlabel('U_{DS} [V]')
ylabel('I_{DS} [A]');
grid on
legend('4.5V = U_{GS}','5.0V','5.5V','6.0V','Location','Best');
