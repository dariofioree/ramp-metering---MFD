clear
system(['sumo -c' 'Users/dario/Desktop/esercitazione_MFD_3/MFD_per_Lezione/esempio_base_TRACI.sumocfg &']);

[traciVersion sumoVersion]= traci.init(8873);
tutto_assieme_occ = [];
tempo_simulazione=18300;
lista_detector = traci.inductionloop.getIDList();
lista_semafori = traci.trafficlights.getIDList();
lista_detector_semafori = lista_detector(:,20:22);
tempo_aggregazione = 180;
contatore_intervalli_tre_minuti = 1;
flag_disattivato_1 = 0;flag_disattivato_2 = 0;flag_disattivato_3 = 0;
contatore_intervalli_20_secondi=1;
TLEvaluation_time = 20; %60
gating_attivato = 0; contatore = 0;

lunghezza_archi = repmat (100,1,length(lista_detector)-4);

for i = 1:tempo_simulazione
    traci.simulationStep();
    
    for p = 1:length(lista_detector)
        VEL(i-tempo_aggregazione*(contatore_intervalli_tre_minuti-1),p) = traci.inductionloop.getLastStepMeanSpeed(lista_detector{p});
        OCCUPANCY(i-tempo_aggregazione*(contatore_intervalli_tre_minuti-1),p) = traci.inductionloop.getLastStepOccupancy(lista_detector{p});
        VEICOLI(i-tempo_aggregazione*(contatore_intervalli_tre_minuti-1),p) = traci.inductionloop.getLastStepVehicleNumber(lista_detector{p});
    end
    
    if i == tempo_aggregazione*contatore_intervalli_tre_minuti
        contatore_intervalli_tre_minuti = contatore_intervalli_tre_minuti + 1
        OCCUPANCY(OCCUPANCY ==-1) = NaN;
        VEL(VEL==-1) = NaN;
        VEL_AGG(contatore_intervalli_tre_minuti-1,:) = harmmean(VEL, 'omitnan'); %ogni volta che incrementiamo questo contatore, automaticamentesi scrive una nuova riga in questo file. Es la riga 3 è relativa all'intervallo di aggregazione 3. Harmmean è la media armonica
        VEICOLI_AGG(contatore_intervalli_tre_minuti-1,:) = sum(VEICOLI,1); %somma tra le colonne
        OCCUPANCY_AGG(contatore_intervalli_tre_minuti-1,:) = nanmean(OCCUPANCY);  
        OCCUPANCY_AGG_MFD(contatore_intervalli_tre_minuti-1,:) = nanmean(OCCUPANCY(:,1:19));        
%         tutto_assieme_occ = [tutto_assieme_occ;OCCUPANCY];
        if sum(OCCUPANCY_AGG_MFD(contatore_intervalli_tre_minuti-1,:).*lunghezza_archi)...
                /sum(lunghezza_archi) >=15
            for d = 1:length(lista_semafori)                
                traci.trafficlights.setRedYellowGreenState(lista_semafori{d},'r');
            end
            disp('GatingActivated')
            gating_attivato = 1;
            contatore = contatore +1;    
        else
            for d = 1:length(lista_semafori)
                traci.trafficlights.setRedYellowGreenState(lista_semafori{d},'G'); %else
            end
%             disp('GatingDisactivated')
            gating_attivato = 0;      
        end
    end
    
    
    %Controllare curva dopo il rosso semaforico per assicurarci che non
    %crei problemi ad altri archi
    if i == TLEvaluation_time*contatore_intervalli_20_secondi
        if gating_attivato == 1
            for r = 1:length(lista_detector_semafori)
                occupancy_evaluation(i,r) =traci.inductionloop.getLastStepOccupancy(lista_detector_semafori{r});
                if occupancy_evaluation(i,r) >=80  && r==1 %PERCENTUALE
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'G');%nome semaforo associato
                    flag_disattivato_1 = 1;
                elseif occupancy_evaluation(i,r) <=20  && r==1 && flag_disattivato_1 == 1
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'r');%nome semaforo associato
                    flag_disattivato_1 = 0;
                end
                if occupancy_evaluation(i,r) >=80  && r==2 %PERCENTUALE
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'G');%nome semaforo associato
                    flag_disattivato_2 = 1;
                elseif occupancy_evaluation(i,r) <=20  && r==2 && flag_disattivato_2 == 1
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'r');%nome semaforo associato
                    flag_disattivato_2 = 0;
                end
                if occupancy_evaluation(i,r) >=80  && r==3 %PERCENTUALE
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'G');%nome semaforo associato
                    flag_disattivato_3 = 1;
                elseif occupancy_evaluation(i,r) <=20  && r==3 && flag_disattivato_3 == 1
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'r');%nome semaforo associato
                    flag_disattivato_3 = 0;
                end
            end
            contatore_intervalli_20_secondi=contatore_intervalli_20_secondi+1;
        else
            contatore_intervalli_20_secondi = contatore_intervalli_20_secondi+1;
        end
    end
end

traci.close()
