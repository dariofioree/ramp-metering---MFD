clear all
% close all

FILES = dir('*.txt');



for c = 1:length(FILES)
    Dati_Simulazione = fileread (FILES(c).name);
    k = strfind(Dati_Simulazione,'<interval');
    j = strfind(Dati_Simulazione,'/>');
    differenza = length(j)+ 1 -length(k);
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
velocita(indice) = 80/3.6;



