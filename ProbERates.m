classdef ProbERates < matlab.apps.AppBase
    %PROBERATES_EXPORTED L'applicazione permette di gestire facilmente le
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
        Figura            matlab.ui.Figure
        Griglia           matlab.ui.container.GridLayout
        RATELabel         matlab.ui.control.Label
        PROBABILITLabel   matlab.ui.control.Label
        TRANSIZIONELabel  matlab.ui.control.Label
        TIPOLabel         matlab.ui.control.Label
    end

    
    properties (Access = private)
        Transizioni % Description

        Transizioni_nomi            matlab.ui.control.EditField
 
        Scelta_tipo                 matlab.ui.container.ButtonGroup
        Temporizzata                matlab.ui.control.RadioButton
        Immediata                   matlab.ui.control.RadioButton

        Transizioni_Prob            matlab.ui.control.NumericEditField

        Transizioni_Rate            matlab.ui.control.NumericEditField

        Salva                       matlab.ui.control.Button
    end
    
    methods (Access = private)
        
        function Salvataggio(app, ~)
            sistema.Transizioni=app.Transizioni;
            sistema.Probabilita=table();
            sistema.Rate=table();
            for i=1:(length(app.Griglia.Children)-5)/4
                nome=app.Griglia.Children(i*4+1).Value;
                sistema.maschera(i)=app.Griglia.Children(i*4+2).SelectedObject.Text=="Immediata";
                prob=app.Griglia.Children(i*4+3).Value;
                rate=app.Griglia.Children(i*4+4).Value;
                if prob>0
                    sistema.Probabilita(height(sistema.Probabilita)+1,:)=table(string(nome),prob);
                end
                if sistema.maschera(i)==0
                    sistema.Rate(height(sistema.Rate)+1,:)=table(string(nome),rate);
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
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, Transizioni)
            app.Transizioni=Transizioni;
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
            else
                Prob = table("",0,'VariableNames',["Transizione" "Probabilita"]);
                Rate = table("",0,'VariableNames',["Transizione" "Rate"]);
                Transizioni_maschera = app.Transizioni;
                maschera = ones(size(app.Transizioni));
            end

            for i=1:length(Transizioni)
                app.Griglia.RowHeight(i+1)={50};
                app.Transizioni_nomi = uieditfield(app.Griglia, 'text');
                app.Transizioni_nomi.Value = Transizioni(i);
                app.Transizioni_nomi.Editable = 'off';
                app.Transizioni_nomi.Layout.Row = i+1;
                app.Transizioni_nomi.Layout.Column = 1;

                % Create ButtonGroup
                app.Scelta_tipo = uibuttongroup(app.Griglia);
                app.Scelta_tipo.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            
                % Create ImmediataButton
                app.Immediata = uiradiobutton(app.Scelta_tipo);
                app.Immediata.Text = 'Immediata';
                app.Immediata.Position = [11 24 100 22];

                % Create TemporizzataButton
                app.Temporizzata = uiradiobutton(app.Scelta_tipo);
                app.Temporizzata.Text = 'Temporizzata';
                app.Temporizzata.Position = [11 2 100 22];
                
                app.Transizioni_Prob = uieditfield(app.Griglia, 'numeric');
                app.Transizioni_Prob.Layout.Row = i+1;
                app.Transizioni_Prob.Layout.Column = 3;
                if ismember(app.Transizioni(i),Prob.Transizione)
                    app.Transizioni_Prob.Value=Prob.Probabilita(Prob.Transizione==app.Transizioni(i));
                end

                app.Transizioni_Rate = uieditfield(app.Griglia, 'numeric');
                app.Transizioni_Rate.Layout.Row = i+1;
                app.Transizioni_Rate.Layout.Column = 4;
                if ismember(app.Transizioni(i),Rate.Transizione)
                    app.Transizioni_Rate.Value=Rate.Rate(Rate.Transizione==app.Transizioni(i));
                end
   
                if ismember(app.Transizioni(i),Transizioni_maschera)
                    app.Immediata.Value = logical(maschera(Transizioni_maschera==app.Transizioni(i)));
                else
                    app.Immediata.Value = true;
                end
                if app.Immediata.Value
                    app.Transizioni_Rate.Editable='off';
                    app.Scelta_tipo.BackgroundColor=[0 1 0 0.5];
                    app.Transizioni_Rate.BackgroundColor=[0.95 0.95 0.95];
                else
                    app.Transizioni_Rate.Editable='on';
                    app.Scelta_tipo.BackgroundColor=[1 0.5 0 0.5];
                    app.Transizioni_Rate.BackgroundColor=[1 1 1];
                end

            end
            app.Griglia.RowHeight(length(Transizioni)+2)={50};
            app.Salva = uibutton(app.Griglia,'push','Text','SALVA','BackgroundColor',[0.686, 0.835, 1]);
            app.Salva.Layout.Row=length(Transizioni)+2;
            app.Salva.Layout.Column=[1 4];
            app.Salva.ButtonPushedFcn = createCallbackFcn(app, @Salvataggio, true);

            app.Griglia.Scrollable='on';
        end

        % Callback function: not associated with a component
        function ButtonGroupSelectionChanged(app, event)
            for i=1:length(app.Griglia.Children)
                if app.Griglia.Children(i).Position(2)==event.Source.Position(2) && app.Griglia.Children(i).Position(1)==event.Source.Position(1)
                    break;
                end
            end
            for j=1:length(app.Griglia.Children)
                if app.Griglia.Children(j).Position(2)==event.Source.Position(2) && app.Griglia.Children(j).Position(1)==app.RATELabel.Position(1)
                    break;
                end
            end
            selectedButton = app.Griglia.Children(i).SelectedObject.Text;
            if selectedButton=="Immediata"
                app.Griglia.Children(j).Editable='off';
                app.Griglia.Children(i).BackgroundColor=[0 1 0 0.5];
                app.Griglia.Children(j).BackgroundColor=[0.95 0.95 0.95];
            elseif selectedButton=="Temporizzata"
                app.Griglia.Children(j).Editable='on';
                app.Griglia.Children(i).BackgroundColor=[1 0.5 0 0.5];
                app.Griglia.Children(j).BackgroundColor=[1 1 1];
            end
            fprintf("");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Figura and hide until all components are created
            app.Figura = uifigure('Visible', 'off');
            app.Figura.Position = [100 100 640 480];
            app.Figura.Name = 'MATLAB App';

            % Create Griglia
            app.Griglia = uigridlayout(app.Figura);
            app.Griglia.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.Griglia.RowHeight = {50};
            app.Griglia.ColumnSpacing = 2;
            app.Griglia.RowSpacing = 2;
            app.Griglia.BackgroundColor = [1 1 1];

            % Create TIPOLabel
            app.TIPOLabel = uilabel(app.Griglia);
            app.TIPOLabel.BackgroundColor = [0.6863 0.8353 1];
            app.TIPOLabel.HorizontalAlignment = 'center';
            app.TIPOLabel.FontWeight = 'bold';
            app.TIPOLabel.Layout.Row = 1;
            app.TIPOLabel.Layout.Column = 2;
            app.TIPOLabel.Text = 'TIPO';

            % Create TRANSIZIONELabel
            app.TRANSIZIONELabel = uilabel(app.Griglia);
            app.TRANSIZIONELabel.BackgroundColor = [0.6863 0.8353 1];
            app.TRANSIZIONELabel.HorizontalAlignment = 'center';
            app.TRANSIZIONELabel.FontWeight = 'bold';
            app.TRANSIZIONELabel.Layout.Row = 1;
            app.TRANSIZIONELabel.Layout.Column = 1;
            app.TRANSIZIONELabel.Text = 'TRANSIZIONE';

            % Create PROBABILITLabel
            app.PROBABILITLabel = uilabel(app.Griglia);
            app.PROBABILITLabel.BackgroundColor = [0.6863 0.8353 1];
            app.PROBABILITLabel.HorizontalAlignment = 'center';
            app.PROBABILITLabel.FontWeight = 'bold';
            app.PROBABILITLabel.Layout.Row = 1;
            app.PROBABILITLabel.Layout.Column = 3;
            app.PROBABILITLabel.Text = 'PROBABILITÀ';

            % Create RATELabel
            app.RATELabel = uilabel(app.Griglia);
            app.RATELabel.BackgroundColor = [0.6863 0.8353 1];
            app.RATELabel.HorizontalAlignment = 'center';
            app.RATELabel.FontWeight = 'bold';
            app.RATELabel.Layout.Row = 1;
            app.RATELabel.Layout.Column = 4;
            app.RATELabel.Text = 'RATE';

            % Show the figure after all components are created
            app.Figura.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ProbERates_exported(varargin)

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