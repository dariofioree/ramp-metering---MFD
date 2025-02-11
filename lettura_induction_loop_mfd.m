clear all
% close all

FILES = dir('*.txt');

zona_1 = [1 2 3];

for c = 1:length(FILES)
    Dati_Simulazione = fileread (FILES(c).name);
    k = strfind(Dati_Simulazione,'<interval');
    j = strfind(Dati_Simulazione,'/>');
    differenza = length(j)-length(k);
    j (1:differenza) = [];
    for d=1:length(j)
        SingoloTimeStep=Dati_Simulazione(k(d):j(d));
        valuesLim=find(SingoloTimeStep=='"');
        
        Begin(d,c)=str2double(SingoloTimeStep(valuesLim(1)+1:valuesLim(2)-1));
        End(d,c)=str2double(SingoloTimeStep(valuesLim(3)+1:valuesLim(4)-1));
        flusso(d,c)=str2double(SingoloTimeStep(valuesLim(9)+1:valuesLim(10)-1));
        occupancy(d,c)=str2double(SingoloTimeStep(valuesLim(11)+1:valuesLim(12)-1));
        velocita(d,c)=str2double(SingoloTimeStep(valuesLim(13)+1:valuesLim(14)-1));
        lunghezza(d,c)=str2double(SingoloTimeStep(valuesLim(15)+1:valuesLim(16)-1));
        veicoli_passati(d,c)=str2double(SingoloTimeStep(valuesLim(7)+1:valuesLim(8)-1));
    end
end

indice = find(velocita == -1);
velocita(indice) = NaN;
indice = find(lunghezza == -1);
lunghezza(indice) = NaN;
lunghezza_archi = repmat (100,1,length(FILES));

%%
s = max(unique(lunghezza));


%definizione qw
for g= 1:size(flusso,1)
    qw (g,:) = ((flusso(g,:)).*lunghezza_archi);
    qu (g,:) = ((flusso(g,:)));
end
for g= 1:size(flusso,1)
    ow (g,:) = ((occupancy(g,:)).*lunghezza_archi);
    ou (g,:) = ((occupancy(g,:)));
end
qw_m = sum(qw,2)/sum(lunghezza_archi);
qu_m = sum(qu,2)/sum(lunghezza_archi);
ow_m = sum(ow,2)/sum(lunghezza_archi);
ou_m = sum(ou,2)/sum(lunghezza_archi);

kw_m = ow_m*1000/5/100;
ku_m = ou_m*1000/5/100;
vu_m = qu_m./ku_m;

figure()
plot(kw_m,qw_m,'+')
ylim([0 550])
xlim([0 50])
xlabel('Density [veh/km]','FontWeight','bold')
ylabel('Flow [veh/h]','FontWeight','bold')