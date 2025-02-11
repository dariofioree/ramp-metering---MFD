clear
system(['sumo-gui --remote-port 8873 -c' '/Users/dario/Desktop/ramp_metering_scenari_3/Scenario_3/Tangenziale_Ingressi_RM_TRACI.sumocfg &']);
[traciVersion sumoVersion]= traci.init(8873);
tutto_assieme_occ = [];
tempo_simulazione=4900;
lista_detector = {'15.2_0','15.2_1','15.2_2'};
rampa = {'15.4_rampa'};
lista_semafori = traci.trafficlights.getIDList();
tempo_aggregazione = 180;
contatore_intervalli_tre_minuti = 1;
flag_disattivato_1 = 0;
s=1;
TLEvaluation_time = 20; %60
gating = 0; contatore = 0;
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
  
        
        if nanmean(OCCUPANCY_AGG(contatore_intervalli_tre_minuti-1,:))>=30
            for d = 1:length(lista_semafori)
                traci.trafficlights.setRedYellowGreenState(lista_semafori{d},'r');
            end
            disp('GatingActivated')
            gating = 1;
            contatore = contatore +1;
        else
            %if gating ==1
            for d = 1:length(lista_semafori)
                traci.trafficlights.setRedYellowGreenState(lista_semafori{d},'G'); %else
            end
            disp('GatingNotActivated')
            gating = 0;
        end
    end
    
    %Controllare curva dopo il rosso semaforico per assicurarci che non
    %crei problemi ad altri archi
    if i == TLEvaluation_time*s
        if gating == 1
            for r = 1:length(rampa)
                occupancy_evaluation =traci.inductionloop.getLastStepOccupancy(rampa{r});
                if occupancy_evaluation >=80 %PERCENTUALE
                    traci.trafficlights.setRedYellowGreenState(lista_semafori{r},'G');%nome semaforo associato
                    flag_disattivato_1 = 1;
                    gating=0
                end
            end
            s = s+1;
        else
            s = s+1;
        end
    end
end

traci.close()