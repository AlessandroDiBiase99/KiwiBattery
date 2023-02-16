classdef ProbERatesEMacchinari < matlab.apps.AppBase
    %PROBERATESEMACCHINARI L'applicazione permette di gestire facilmente le
    %transizioni del sistema, identificando se sono temporizzate o
    %immediate, le probabilità e i rates.
    %   L'applicazione richiede in ingresso un'array di stringhe dei nomi
    %   delle transizioni. Questi sono mostrati a schermo affiancati dai
    %   comandi che permettono di classificarla e caratterizzarla. Nella
    %   prima colonna sono presenti i nomi delle transizioni, nella seconda
    %   la classificazione (immediata/temporizzata), nella terza la
    %   probabilità e nella quarta il rate. L'ultima colonna risulta
    %   abilitata solo per le transizioni temporizzate. Completata la
    %   trattazione, il bottone salva permette di salvare il file
    %   sistema.mat contenente tutte le informazioni inserite riguardanti
    %   le transizioni del sistema. Qualora il file sistema.mat sia già
    %   presente, verifica i dati precedenti per mantenere i dati
    %   preesistenti e non sovrascriverli.
    %   
    %   Autori
    %      - Caponi Luca
    %      - Catalini Federico
    %      - Di Biase Alessandro

    % Properties that correspond to app components
    properties (Access = public)
        Figura              matlab.ui.Figure
        GridLayout2         matlab.ui.container.GridLayout
        SALVAButton         matlab.ui.control.Button
        TabGroup            matlab.ui.container.TabGroup
        PostiTab            matlab.ui.container.Tab
        GridLayout8         matlab.ui.container.GridLayout
        GridLayout9         matlab.ui.container.GridLayout
        MACCHINARIOLabel_5  matlab.ui.control.Label
        POSTOLabel          matlab.ui.control.Label
        GrigliaPosti        matlab.ui.container.GridLayout
        MacchinariTab       matlab.ui.container.Tab
        GridLayout3         matlab.ui.container.GridLayout
        GridLayout5         matlab.ui.container.GridLayout
        MACCHINARIOLabel_3  matlab.ui.control.Label
        DAANALIZZARELabel   matlab.ui.control.Label
        GrigliaMacchinari   matlab.ui.container.GridLayout
        TransizioniTab      matlab.ui.container.Tab
        GridLayout6         matlab.ui.container.GridLayout
        GridLayout7         matlab.ui.container.GridLayout
        MACCHINARIOLabel_4  matlab.ui.control.Label
        RATELabel           matlab.ui.control.Label
        PROBABILITLabel     matlab.ui.control.Label
        TIPOLabel           matlab.ui.control.Label
        TRANSIZIONELabel    matlab.ui.control.Label
        GrigliaTransizioni  matlab.ui.container.GridLayout
    end

    
    properties (Access = private)
        pathToMLAPP = fileparts(mfilename('fullpath'));

        Transizioni 
        Posti
        Macchinari

        % Tab macchinari
        Aggiungi                    matlab.ui.control.Button
        NomeMacchinario             matlab.ui.control.EditField
        DaAnalizzare                matlab.ui.container.ButtonGroup
        AnalizzareSi                matlab.ui.control.RadioButton
        AnalizzareNo                matlab.ui.control.RadioButton
        Rimuovi                     matlab.ui.control.Button

        % Tab transizioni
        Transizioni_nomi            matlab.ui.control.EditField
        Scelta_tipo                 matlab.ui.container.ButtonGroup
        Temporizzata                matlab.ui.control.RadioButton
        Immediata                   matlab.ui.control.RadioButton
        Transizioni_Prob            matlab.ui.control.NumericEditField
        Transizioni_Rate            matlab.ui.control.NumericEditField
        Transizioni_Macc            matlab.ui.control.DropDown

        colore_Immediata    = [1.0 1.0 0.3];
        colore_Temporizzata = [0.5 0.5 1.0];
        colore_disabilitata = [0.9 0.9 0.9];
        colore_abilitata    = [1.0 1.0 1.0];
        colore_AnalizzareSi = [0.0 1.0 0.0];
        colore_AnalizzareNo = [1.0 0.5 0.0];

        % Tab posti
        Posti_nomi                  matlab.ui.control.EditField
        Posti_Macc                  matlab.ui.control.DropDown

        Salva                       matlab.ui.control.Button
    end
    
    methods (Access = private)

        function NomeMacchinarioValueChanged(app, event)
            id = str2num(event.Source.Tag);
            ok=true;
            for i=1:length(app.NomeMacchinario)
                if id~=i && string(app.NomeMacchinario(id).Value)==string(app.NomeMacchinario(i).Value)
                    ok=false;
                    break;
                end
            end
            if ok
                lista_vecchia=app.Macchinari;
                app.Macchinari(id)=app.NomeMacchinario(id).Value;
                CorreggiMacchinariScelti(app,lista_vecchia);
            else
                app.NomeMacchinario(id).Value=app.Macchinari(id);
            end
        end

        function CorreggiMacchinariScelti(app,lista_vecchia)
            for i=1:length(app.Transizioni_Macc)
                prima=find(["",lista_vecchia]==string(app.Transizioni_Macc(i).Value));
                app.Transizioni_Macc(i).Items=["",app.Macchinari];
                if prima>1
                    app.Transizioni_Macc(i).Value=app.Macchinari(prima-1);
                else
                    app.Transizioni_Macc(i).BackgroundColor=app.colore_disabilitata;
                end
            end
            for i=1:length(app.Posti_Macc)
                prima=find(["",lista_vecchia]==string(app.Posti_Macc(i).Value));
                app.Posti_Macc(i).Items=["",app.Macchinari];
                if prima>1
                    app.Posti_Macc(i).Value=app.Macchinari(prima-1);
                else
                    app.Posti_Macc(i).BackgroundColor=app.colore_disabilitata;
                end
            end 
        end

        function DaAnalizzareSelectionChanged(app, event)
            id=str2num(event.Source.Tag);
            if app.DaAnalizzare(id).SelectedObject.Text=="Si"
                colore = app.colore_AnalizzareSi;
            else
                colore = app.colore_AnalizzareNo;
            end
            app.DaAnalizzare(id).BackgroundColor=colore;
            for i=1:length(app.Transizioni)
                if app.Transizioni_Macc(i).Value==app.Macchinari(id) 
                   app.Transizioni_Macc(i).BackgroundColor=colore; 
                end
            end
            for i=1:length(app.Posti)
                if app.Posti_Macc(i).Value==app.Macchinari(id) 
                   app.Posti_Macc(i).BackgroundColor=colore; 
                end
            end
        end

        function AggiungiButtonPushed(app, ~)
            
            n = length(app.NomeMacchinario)+1;
            app.GrigliaMacchinari.RowHeight(n)={50};

            k=n;
            ok=true;
            while ok
                ok=false;
                nuovonome=['Macchinario',num2str(k)];
                for i=1:n-1
                    if string(nuovonome)==string(app.NomeMacchinario(i).Value)
                        ok=true;
                        break;
                    end
                end
                k=k+1;
            end
            
            % Create NomeMacchinario
            app.NomeMacchinario(n) = uieditfield(app.GrigliaMacchinari, 'text');
            app.NomeMacchinario(n).Layout.Row = n;
            app.NomeMacchinario(n).Layout.Column = 2;
            app.NomeMacchinario(n).Value = nuovonome;
            app.NomeMacchinario(n).Tag = num2str(n);
            app.NomeMacchinario(n).CharacterLimits = [1 Inf];
            app.NomeMacchinario(n).ValueChangedFcn = createCallbackFcn(app, @NomeMacchinarioValueChanged, true);

            % Create DaAnalizzare
            app.DaAnalizzare(n) = uibuttongroup(app.GrigliaMacchinari);
            app.DaAnalizzare(n).BackgroundColor = [1 1 1];
            app.DaAnalizzare(n).Layout.Row = n;
            app.DaAnalizzare(n).Layout.Column = 3;
            app.DaAnalizzare(n).SelectionChangedFcn = createCallbackFcn(app, @DaAnalizzareSelectionChanged, true);
            app.DaAnalizzare(n).BackgroundColor=app.colore_AnalizzareSi;
            app.DaAnalizzare(n).Tag=num2str(n);
            
            % Create AnalizzareSi
            app.AnalizzareSi = uiradiobutton(app.DaAnalizzare(n));
            app.AnalizzareSi.Text = 'Si';
            app.AnalizzareSi.Position = [10 25 100 22];
            app.AnalizzareSi.Value = true;

            % Create AnalizzareNo
            app.AnalizzareNo = uiradiobutton(app.DaAnalizzare(n));
            app.AnalizzareNo.Text = 'No';
            app.AnalizzareNo.Position = [10 2 100 22];

            app.Rimuovi(n) = uibutton(app.GrigliaMacchinari, 'push');
            app.Rimuovi(n).Icon = fullfile(app.pathToMLAPP, 'remove.png');
            app.Rimuovi(n).ButtonPushedFcn = createCallbackFcn(app, @RimuoviButtonPushed, true);
            app.Rimuovi(n).BackgroundColor = [0.6902 0.8392 1];
            app.Rimuovi(n).Layout.Row = n;
            app.Rimuovi(n).Layout.Column = 4;
            app.Rimuovi(n).Text = '';
            app.Rimuovi(n).Tag = num2str(n);

            app.GrigliaMacchinari.RowHeight(n+1)={50};
            app.Aggiungi.Layout.Row=n+1;
            
            app.Macchinari=[app.Macchinari,string(nuovonome)];
            CorreggiMacchinariScelti(app,app.Macchinari);
        end

        function RimuoviButtonPushed(app, event)
            id = str2num(event.Source.Tag);
            
            delete(app.NomeMacchinario(id));
            delete(app.DaAnalizzare(id));
            delete(app.Rimuovi(id));

            app.Macchinari=[app.Macchinari(1:id-1),app.Macchinari(id+1:end)];
            app.NomeMacchinario=[app.NomeMacchinario(1:id-1),app.NomeMacchinario(id+1:end)];
            app.DaAnalizzare=[app.DaAnalizzare(1:id-1),app.DaAnalizzare(id+1:end)];
            app.Rimuovi=[app.Rimuovi(1:id-1),app.Rimuovi(id+1:end)];
            
            for i=id:length(app.NomeMacchinario)
                app.NomeMacchinario(i).Layout.Row=i;
                app.NomeMacchinario(i).Tag=num2str(i);
                app.DaAnalizzare(i).Layout.Row=i;
                app.DaAnalizzare(i).Tag=num2str(i);
                app.Rimuovi(i).Layout.Row=i;
                app.Rimuovi(i).Tag=num2str(i);
            end
            app.Aggiungi.Layout.Row=length(app.NomeMacchinario)+1;
            app.GrigliaMacchinari.RowHeight=ones(1,length(app.NomeMacchinario)+1)*50;
            
            CorreggiMacchinariScelti(app,app.Macchinari)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, Transizioni, Posti)
            
            app.Transizioni=Transizioni;
            app.Posti=Posti;
            
            if exist("sistema.mat","file")
                file=load("sistema.mat",'sistema');
                try
                    Prob = file.sistema.Probabilita;
                catch
                    Prob = table("",0,'VariableNames',["Transizione" "Probabilita"]);
                end
                try
                    Rate = file.sistema.Rate;
                catch
                    Rate = table("",0,'VariableNames',["Transizione" "Rate"]);
                end
                try
                    Transizioni_maschera = file.sistema.Transizioni;
                    maschera = file.sistema.maschera;
                catch
                    Transizioni_maschera = app.Transizioni;
                    maschera = ones(size(app.Transizioni));
                end
                try
                    Macchinari_ = file.sistema.Macchinari.Macchinario';
                    Tabella_Macchinari = file.sistema.Macchinari;
                    if ~ismember("DaAnalizzare",Tabella_Macchinari.Properties.VariableNames)
                        Tabella_Macchinari.DaAnalizzare=ones(height(Tabella_Macchinari),1);
                    end
                catch
                    Macchinari_=[];
                    Tabella_Macchinari = table();
                end
            else
                Macchinari_=[];
                Tabella_Macchinari = table("",{[]},{[]},1,'VariableNames',["Macchinario","Transizioni","Posti","DaAnalizzare"]);
                Prob = table("",0,'VariableNames',["Transizione" "Probabilita"]);
                Rate = table("",0,'VariableNames',["Transizione" "Rate"]);
                Transizioni_maschera = app.Transizioni;
                maschera = ones(size(app.Transizioni));
            end
            app.Macchinari=Macchinari_;

%% MACCHINARI =============================================================
            for i=1:length(app.Macchinari)
            
                app.GrigliaMacchinari.RowHeight(i)={50};

                % Create NomeMacchinario
                app.NomeMacchinario(i) = uieditfield(app.GrigliaMacchinari, 'text');
                app.NomeMacchinario(i).Layout.Row = i;
                app.NomeMacchinario(i).Layout.Column = 2;
                app.NomeMacchinario(i).Value = app.Macchinari(i);
                app.NomeMacchinario(i).Tag = num2str(i);
                app.NomeMacchinario(i).CharacterLimits = [1 Inf];
                app.NomeMacchinario(i).ValueChangedFcn = createCallbackFcn(app, @NomeMacchinarioValueChanged, true);

                % Create DaAnalizzare
                app.DaAnalizzare(i) = uibuttongroup(app.GrigliaMacchinari);
                app.DaAnalizzare(i).BackgroundColor = [1 1 1];
                app.DaAnalizzare(i).Layout.Row = i;
                app.DaAnalizzare(i).Layout.Column = 3;
                app.DaAnalizzare(i).SelectionChangedFcn = createCallbackFcn(app, @DaAnalizzareSelectionChanged, true);
                app.DaAnalizzare(i).Tag = num2str(i);

                % Create AnalizzareSi
                app.AnalizzareSi = uiradiobutton(app.DaAnalizzare(i));
                app.AnalizzareSi.Text = 'Si';
                app.AnalizzareSi.Position = [10 25 100 22];
            
                % Create AnalizzareNo
                app.AnalizzareNo = uiradiobutton(app.DaAnalizzare(i));
                app.AnalizzareNo.Text = 'No';
                app.AnalizzareNo.Position = [10 2 100 22];
                
                if Tabella_Macchinari.DaAnalizzare(i)
                    app.AnalizzareSi.Value=true;
                    app.DaAnalizzare(i).BackgroundColor=app.colore_AnalizzareSi;
                else
                    app.AnalizzareSi.Value=false;
                    app.DaAnalizzare(i).BackgroundColor=app.colore_AnalizzareNo;
                end

                % Create Rimuovi
                app.Rimuovi(i) = uibutton(app.GrigliaMacchinari, 'push');
                app.Rimuovi(i).Icon = fullfile(app.pathToMLAPP, 'remove.png');
                app.Rimuovi(i).ButtonPushedFcn = createCallbackFcn(app, @RimuoviButtonPushed, true);
                app.Rimuovi(i).BackgroundColor = [0.6902 0.8392 1];
                app.Rimuovi(i).Layout.Row = i;
                app.Rimuovi(i).Layout.Column = 4;
                app.Rimuovi(i).Text = '';
                app.Rimuovi(i).Tag = num2str(i);
            end

            % Create Aggiungi
            app.Aggiungi = uibutton(app.GrigliaMacchinari, 'push');
            app.Aggiungi.Icon = fullfile(app.pathToMLAPP, 'add.png');
            app.Aggiungi.ButtonPushedFcn = createCallbackFcn(app, @AggiungiButtonPushed, true);
            app.Aggiungi.BackgroundColor = [0.6902 0.8392 1];
            app.GrigliaMacchinari.RowHeight(length(app.NomeMacchinario)+1)={50};
            app.Aggiungi.Layout.Row = length(app.NomeMacchinario)+1;
            app.Aggiungi.Layout.Column = 1;
            app.Aggiungi.Text = '';

%% TRANSIZIONI ============================================================
            for i=1:length(Transizioni)
                app.GrigliaTransizioni.RowHeight(i)={50};
                app.Transizioni_nomi(i) = uieditfield(app.GrigliaTransizioni, 'text');
                app.Transizioni_nomi(i).Value = Transizioni(i);
                app.Transizioni_nomi(i).Editable = 'off';
                app.Transizioni_nomi(i).Layout.Row = i;
                app.Transizioni_nomi(i).Layout.Column = 1;

                % Create ButtonGroup
                app.Scelta_tipo(i) = uibuttongroup(app.GrigliaTransizioni);
                app.Scelta_tipo(i).Tag = num2str(i);
                app.Scelta_tipo(i).SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            
                % Create ImmediataButton
                app.Immediata = uiradiobutton(app.Scelta_tipo(i));
                app.Immediata.Text = 'Immediata';
                app.Immediata.Position = [11 24 100 22];

                % Create TemporizzataButton
                app.Temporizzata = uiradiobutton(app.Scelta_tipo(i));
                app.Temporizzata.Text = 'Temporizzata';
                app.Temporizzata.Position = [11 2 100 22];
                
                app.Transizioni_Prob(i) = uieditfield(app.GrigliaTransizioni, 'numeric');
                app.Transizioni_Prob(i).Layout.Row = i;
                app.Transizioni_Prob(i).Layout.Column = 3;
                if ismember(app.Transizioni(i),Prob.Transizione)
                    app.Transizioni_Prob(i).Value=Prob.Probabilita(Prob.Transizione==app.Transizioni(i));
                end

                app.Transizioni_Rate(i) = uieditfield(app.GrigliaTransizioni, 'numeric');
                app.Transizioni_Rate(i).Layout.Row = i;
                app.Transizioni_Rate(i).Layout.Column = 4;
                if ismember(app.Transizioni(i),Rate.Transizione)
                    app.Transizioni_Rate(i).Value=Rate.Rate(Rate.Transizione==app.Transizioni(i));
                end
   
                if ismember(app.Transizioni(i),Transizioni_maschera)
                    app.Immediata.Value = logical(maschera(Transizioni_maschera==app.Transizioni(i)));
                else
                    app.Immediata.Value = true;
                end
                if app.Immediata.Value
                    app.Transizioni_Rate(i).Editable='off';
                    app.Transizioni_Rate(i).BackgroundColor=app.colore_disabilitata;
                    app.Scelta_tipo(i).BackgroundColor=app.colore_Immediata;
                else
                    app.Transizioni_Rate(i).Editable='on';
                    app.Transizioni_Rate(i).BackgroundColor=app.colore_abilitata;
                    app.Scelta_tipo(i).BackgroundColor=app.colore_Temporizzata;
                end

                app.Transizioni_Macc(i) = uidropdown(app.GrigliaTransizioni);
                app.Transizioni_Macc(i).ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
                app.Transizioni_Macc(i).Layout.Row = i;
                app.Transizioni_Macc(i).Layout.Column = 5;
                app.Transizioni_Macc(i).Items = ["",app.Macchinari];
                app.Transizioni_Macc(i).Tag = string(['T',num2str(i)]);
                app.Transizioni_Macc(i).BackgroundColor=app.colore_disabilitata;
                for j=1:height(Tabella_Macchinari)
                    if ~isempty(Tabella_Macchinari.Posti{j}) && ismember(app.Transizioni(i),Tabella_Macchinari.Transizioni{j})
                        app.Transizioni_Macc(i).Value=Tabella_Macchinari.Macchinario(j);
                        if Tabella_Macchinari.DaAnalizzare(j)
                            app.Transizioni_Macc(i).BackgroundColor = app.colore_AnalizzareSi;
                        else
                            app.Transizioni_Macc(i).BackgroundColor = app.colore_AnalizzareNo;
                        end
                        break;
                    end
                end
            end

%% POSTI ==================================================================
            for i=1:length(Posti)
                app.GrigliaPosti.RowHeight(i) = {50};
                app.Posti_nomi(i) = uieditfield(app.GrigliaPosti, 'text');
                app.Posti_nomi(i).Value = Posti(i);
                app.Posti_nomi(i).Editable = 'off';
                app.Posti_nomi(i).Layout.Row = i;
                app.Posti_nomi(i).Layout.Column = 1;

                app.Posti_Macc(i) = uidropdown(app.GrigliaPosti);
                app.Posti_Macc(i).ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
                app.Posti_Macc(i).Layout.Row = i;
                app.Posti_Macc(i).Layout.Column = 2;
                app.Posti_Macc(i).Items = ["",app.Macchinari];
                app.Posti_Macc(i).BackgroundColor=[1 1 1];
                app.Posti_Macc(i).Tag = string(['P',num2str(i)]);
                app.Posti_Macc(i).BackgroundColor=app.colore_disabilitata;
                for j=1:height(Tabella_Macchinari)
                    if ~isempty(Tabella_Macchinari.Posti{j}) && ismember(app.Posti(i),Tabella_Macchinari.Posti{j})
                        app.Posti_Macc(i).Value=Tabella_Macchinari.Macchinario(j);
                        if Tabella_Macchinari.DaAnalizzare(j)
                            app.Posti_Macc(i).BackgroundColor = app.colore_AnalizzareSi;
                        else
                            app.Posti_Macc(i).BackgroundColor = app.colore_AnalizzareNo;
                        end
                        break;
                    end
                end
            end
        end

        % Callback function
        function ButtonGroupSelectionChanged(app, event)
            id = str2num(event.Source.Tag);
            selectedButton = app.Scelta_tipo(id).SelectedObject.Text;
            if selectedButton=="Immediata"
                app.Transizioni_Rate(id).Editable='off';
                app.Transizioni_Rate(id).BackgroundColor=app.colore_disabilitata;
                app.Scelta_tipo(id).BackgroundColor=app.colore_Immediata;
            elseif selectedButton=="Temporizzata"
                app.Transizioni_Rate(id).Editable='on';
                app.Transizioni_Rate(id).BackgroundColor=app.colore_abilitata;
                app.Scelta_tipo(id).BackgroundColor=app.colore_Temporizzata;
            end
        end

        % Button pushed function: SALVAButton
        function SALVAButtonPushed(app, event)
            sistema.Transizioni=app.Transizioni;
            sistema.Posti = app.Posti;
            sistema.Macchinari = table(); 
            sistema.Probabilita=table();
            sistema.Rate=table();

            for i=1:length(app.Macchinari)
                val=app.DaAnalizzare(i).SelectedObject.Text=="Si";
                sistema.Macchinari(i,:)=table(app.Macchinari(i),{[]},{[]},val,'VariableNames',["Macchinario","Transizioni","Posti","DaAnalizzare"]);
            end
            for i=1:length(app.Transizioni_nomi)
                % Nome della transizione
                nome = string(app.Transizioni_nomi(i).Value);
                % 1 o 0 per transizione immediata o temporizzata
                sistema.maschera(i)=app.Scelta_tipo(i).SelectedObject.Text=="Immediata";
                % Probabilità della transizione, salvata solo se maggiore
                % di 0
                prob=app.Transizioni_Prob(i).Value;
                if prob>0
                    sistema.Probabilita(height(sistema.Probabilita)+1,:)=table(string(nome),prob);
                end
                % Rate della transizione, salvata solo se è temporizzata
                rate=app.Transizioni_Rate(i).Value;
                if sistema.maschera(i)==0
                    sistema.Rate(height(sistema.Rate)+1,:)=table(string(nome),rate);
                end
                % Inserimento nella tabella macchinario
                macc=string(app.Transizioni_Macc(i).Value);
                if ~isempty(app.Macchinari)
                    id=find(macc==app.Macchinari);
                    if ~isempty(id)
                        sistema.Macchinari.Transizioni(id)={[sistema.Macchinari.Transizioni{id},nome]};
                    end
                end
            end
            for i=1:length(app.Posti_nomi)
                % Nome del posto
                nome = string(app.Posti_nomi(i).Value);
                % Inserimento nella tabella macchinario
                macc=string(app.Posti_Macc(i).Value);
                if ~isempty(app.Macchinari)
                    id=find(macc==app.Macchinari);
                    if ~isempty(id)
                        sistema.Macchinari.Posti(id)={[sistema.Macchinari.Posti{id},nome]};
                    end
                end
            end
            if height(sistema.Probabilita)>=1
                sistema.Probabilita.Properties.VariableNames = ["Transizione" "Probabilita"];
            end
            if height(sistema.Rate)>=1
                sistema.Rate.Properties.VariableNames = ["Transizione" "Rate"];
            end
            save("sistema.mat","sistema");
        end

        % Callback function: not associated with a component
        function DropDownValueChanged(app, event)
            caratteri=char(event.Source.Tag);
            id=str2num(caratteri(2:end));
            fprintf("Tag: %s;",event.Source.Tag);
            if caratteri(1)=='T'
                value = app.Transizioni_Macc(id).Value;
                if value~=""
                    id_macc=find(value==app.Macchinari);
                    if app.DaAnalizzare(id_macc).SelectedObject.Text=="Si"
                        app.Transizioni_Macc(id).BackgroundColor = app.colore_AnalizzareSi;
                    else
                        app.Transizioni_Macc(id).BackgroundColor = app.colore_AnalizzareNo;
                    end
                else
                    app.Transizioni_Macc(id).BackgroundColor=app.colore_disabilitata;
                end
            elseif event.Source.Tag(1)=='P'
                value = app.Posti_Macc(id).Value;
                if value~=""
                    id_macc=find(value==app.Macchinari);
                    if app.DaAnalizzare(id_macc).SelectedObject.Text=="Si"
                        app.Posti_Macc(id).BackgroundColor = app.colore_AnalizzareSi;
                    else
                        app.Posti_Macc(id).BackgroundColor = app.colore_AnalizzareNo;
                    end
                else
                    app.Posti_Macc(id).BackgroundColor=app.colore_disabilitata;
                end
            end
            fprintf("\n");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Figura and hide until all components are created
            app.Figura = uifigure('Visible', 'off');
            app.Figura.Position = [100 100 662 566];
            app.Figura.Name = 'MATLAB App';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Figura);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1x', 50};
            app.GridLayout2.RowSpacing = 1;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout2);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 1;

            % Create MacchinariTab
            app.MacchinariTab = uitab(app.TabGroup);
            app.MacchinariTab.Title = 'Macchinari';
            app.MacchinariTab.BackgroundColor = [1 1 1];

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.MacchinariTab);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {50, '1x'};
            app.GridLayout3.RowSpacing = 0;
            app.GridLayout3.Padding = [0 0 0 0];

            % Create GrigliaMacchinari
            app.GrigliaMacchinari = uigridlayout(app.GridLayout3);
            app.GrigliaMacchinari.ColumnWidth = {25, '1x', '1x', 25};
            app.GrigliaMacchinari.RowHeight = {};
            app.GrigliaMacchinari.ColumnSpacing = 2;
            app.GrigliaMacchinari.RowSpacing = 2;
            app.GrigliaMacchinari.Padding = [5 10 5 2];
            app.GrigliaMacchinari.Layout.Row = 2;
            app.GrigliaMacchinari.Layout.Column = 1;
            app.GrigliaMacchinari.Scrollable = 'on';
            app.GrigliaMacchinari.BackgroundColor = [1 1 1];

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout3);
            app.GridLayout5.RowHeight = {50};
            app.GridLayout5.ColumnSpacing = 2;
            app.GridLayout5.Padding = [32 0 32 0];
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.BackgroundColor = [1 1 1];

            % Create DAANALIZZARELabel
            app.DAANALIZZARELabel = uilabel(app.GridLayout5);
            app.DAANALIZZARELabel.BackgroundColor = [0.6863 0.8353 1];
            app.DAANALIZZARELabel.HorizontalAlignment = 'center';
            app.DAANALIZZARELabel.FontWeight = 'bold';
            app.DAANALIZZARELabel.Layout.Row = 1;
            app.DAANALIZZARELabel.Layout.Column = 2;
            app.DAANALIZZARELabel.Text = 'DA ANALIZZARE';

            % Create MACCHINARIOLabel_3
            app.MACCHINARIOLabel_3 = uilabel(app.GridLayout5);
            app.MACCHINARIOLabel_3.BackgroundColor = [0.6863 0.8353 1];
            app.MACCHINARIOLabel_3.HorizontalAlignment = 'center';
            app.MACCHINARIOLabel_3.FontWeight = 'bold';
            app.MACCHINARIOLabel_3.Layout.Row = 1;
            app.MACCHINARIOLabel_3.Layout.Column = 1;
            app.MACCHINARIOLabel_3.Text = 'MACCHINARIO';

            % Create TransizioniTab
            app.TransizioniTab = uitab(app.TabGroup);
            app.TransizioniTab.Title = 'Transizioni';
            app.TransizioniTab.BackgroundColor = [1 1 1];

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.TransizioniTab);
            app.GridLayout6.ColumnWidth = {'1x'};
            app.GridLayout6.RowHeight = {50, '1x'};
            app.GridLayout6.RowSpacing = 0;
            app.GridLayout6.Padding = [0 0 0 0];

            % Create GrigliaTransizioni
            app.GrigliaTransizioni = uigridlayout(app.GridLayout6);
            app.GrigliaTransizioni.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GrigliaTransizioni.RowHeight = {};
            app.GrigliaTransizioni.ColumnSpacing = 2;
            app.GrigliaTransizioni.RowSpacing = 2;
            app.GrigliaTransizioni.Padding = [10 10 10 2];
            app.GrigliaTransizioni.Layout.Row = 2;
            app.GrigliaTransizioni.Layout.Column = 1;
            app.GrigliaTransizioni.Scrollable = 'on';
            app.GrigliaTransizioni.BackgroundColor = [1 1 1];

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout6);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {50};
            app.GridLayout7.ColumnSpacing = 2;
            app.GridLayout7.Padding = [10 0 10 0];
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 1;
            app.GridLayout7.BackgroundColor = [1 1 1];

            % Create TRANSIZIONELabel
            app.TRANSIZIONELabel = uilabel(app.GridLayout7);
            app.TRANSIZIONELabel.BackgroundColor = [0.6863 0.8353 1];
            app.TRANSIZIONELabel.HorizontalAlignment = 'center';
            app.TRANSIZIONELabel.FontWeight = 'bold';
            app.TRANSIZIONELabel.Layout.Row = 1;
            app.TRANSIZIONELabel.Layout.Column = 1;
            app.TRANSIZIONELabel.Text = 'TRANSIZIONE';

            % Create TIPOLabel
            app.TIPOLabel = uilabel(app.GridLayout7);
            app.TIPOLabel.BackgroundColor = [0.6863 0.8353 1];
            app.TIPOLabel.HorizontalAlignment = 'center';
            app.TIPOLabel.FontWeight = 'bold';
            app.TIPOLabel.Layout.Row = 1;
            app.TIPOLabel.Layout.Column = 2;
            app.TIPOLabel.Text = 'TIPO';

            % Create PROBABILITLabel
            app.PROBABILITLabel = uilabel(app.GridLayout7);
            app.PROBABILITLabel.BackgroundColor = [0.6863 0.8353 1];
            app.PROBABILITLabel.HorizontalAlignment = 'center';
            app.PROBABILITLabel.FontWeight = 'bold';
            app.PROBABILITLabel.Layout.Row = 1;
            app.PROBABILITLabel.Layout.Column = 3;
            app.PROBABILITLabel.Text = 'PROBABILITÀ';

            % Create RATELabel
            app.RATELabel = uilabel(app.GridLayout7);
            app.RATELabel.BackgroundColor = [0.6863 0.8353 1];
            app.RATELabel.HorizontalAlignment = 'center';
            app.RATELabel.FontWeight = 'bold';
            app.RATELabel.Layout.Row = 1;
            app.RATELabel.Layout.Column = 4;
            app.RATELabel.Text = 'RATE';

            % Create MACCHINARIOLabel_4
            app.MACCHINARIOLabel_4 = uilabel(app.GridLayout7);
            app.MACCHINARIOLabel_4.BackgroundColor = [0.6902 0.8392 1];
            app.MACCHINARIOLabel_4.HorizontalAlignment = 'center';
            app.MACCHINARIOLabel_4.FontWeight = 'bold';
            app.MACCHINARIOLabel_4.Layout.Row = 1;
            app.MACCHINARIOLabel_4.Layout.Column = 5;
            app.MACCHINARIOLabel_4.Text = 'MACCHINARIO';

            % Create PostiTab
            app.PostiTab = uitab(app.TabGroup);
            app.PostiTab.Title = 'Posti';
            app.PostiTab.BackgroundColor = [1 1 1];

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.PostiTab);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {50, '1x'};
            app.GridLayout8.RowSpacing = 0;
            app.GridLayout8.Padding = [0 0 0 0];

            % Create GrigliaPosti
            app.GrigliaPosti = uigridlayout(app.GridLayout8);
            app.GrigliaPosti.RowHeight = {};
            app.GrigliaPosti.ColumnSpacing = 2;
            app.GrigliaPosti.RowSpacing = 2;
            app.GrigliaPosti.Padding = [10 10 10 2];
            app.GrigliaPosti.Layout.Row = 2;
            app.GrigliaPosti.Layout.Column = 1;
            app.GrigliaPosti.Scrollable = 'on';
            app.GrigliaPosti.BackgroundColor = [1 1 1];

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout8);
            app.GridLayout9.RowHeight = {50};
            app.GridLayout9.ColumnSpacing = 2;
            app.GridLayout9.Padding = [10 0 10 0];
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 1;
            app.GridLayout9.BackgroundColor = [1 1 1];

            % Create POSTOLabel
            app.POSTOLabel = uilabel(app.GridLayout9);
            app.POSTOLabel.BackgroundColor = [0.6863 0.8353 1];
            app.POSTOLabel.HorizontalAlignment = 'center';
            app.POSTOLabel.FontWeight = 'bold';
            app.POSTOLabel.Layout.Row = 1;
            app.POSTOLabel.Layout.Column = 1;
            app.POSTOLabel.Text = 'POSTO';

            % Create MACCHINARIOLabel_5
            app.MACCHINARIOLabel_5 = uilabel(app.GridLayout9);
            app.MACCHINARIOLabel_5.BackgroundColor = [0.6863 0.8353 1];
            app.MACCHINARIOLabel_5.HorizontalAlignment = 'center';
            app.MACCHINARIOLabel_5.FontWeight = 'bold';
            app.MACCHINARIOLabel_5.Layout.Row = 1;
            app.MACCHINARIOLabel_5.Layout.Column = 2;
            app.MACCHINARIOLabel_5.Text = 'MACCHINARIO';

            % Create SALVAButton
            app.SALVAButton = uibutton(app.GridLayout2, 'push');
            app.SALVAButton.ButtonPushedFcn = createCallbackFcn(app, @SALVAButtonPushed, true);
            app.SALVAButton.BackgroundColor = [0.6902 0.8392 1];
            app.SALVAButton.Layout.Row = 2;
            app.SALVAButton.Layout.Column = 1;
            app.SALVAButton.Text = 'SALVA';

            % Show the figure after all components are created
            app.Figura.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProbERatesEMacchinari(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Figura)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Figura)
        end
    end
end