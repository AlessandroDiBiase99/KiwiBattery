classdef appmenu < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        SelezionatuttoCheckBox     matlab.ui.control.CheckBox
        VisualizzaGrafoCheckBox    matlab.ui.control.CheckBox
        CalcolaGrafoCheckBox       matlab.ui.control.CheckBox
        ModificaParametriCheckBox  matlab.ui.control.CheckBox
        OKButton                   matlab.ui.control.Button
        CosavuoifareLabel          matlab.ui.control.Label
    end



    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            if exist("menuapp.mat","file")
                file=load("menuapp.mat","checkbox");
                app.ModificaParametriCheckBox.Value=file.checkbox(1);
                app.CalcolaGrafoCheckBox.Value=file.checkbox(2);
                app.VisualizzaGrafoCheckBox.Value=file.checkbox(3);
                app.SelezionatuttoCheckBox.Value=file.checkbox(4);
            else
                app.ModificaParametriCheckBox.Value=0;
                app.CalcolaGrafoCheckBox.Value=0;
                app.VisualizzaGrafoCheckBox.Value=0;
                app.SelezionatuttoCheckBox.Value=0;
            end
        end

        % Callback function: OKButton, UIFigure
        function ChiusuraApp(app, event)
            checkbox(1)=app.ModificaParametriCheckBox.Value;
            checkbox(2)=app.CalcolaGrafoCheckBox.Value;
            checkbox(3)=app.VisualizzaGrafoCheckBox.Value;
            checkbox(4)=app.SelezionatuttoCheckBox.Value;
            save("menuapp.mat","checkbox");
            delete(app)
        end

        % Value changed function: CalcolaGrafoCheckBox
        function CalcolaGrafoCheckBoxValueChanged(app, event)
            calcolagrafo = app.CalcolaGrafoCheckBox.Value;
            if calcolagrafo==1
                app.VisualizzaGrafoCheckBox.Enable='on';
            else
                app.VisualizzaGrafoCheckBox.Enable='off';
                app.VisualizzaGrafoCheckBox.Value=0;
            end
        end

        % Value changed function: SelezionatuttoCheckBox
        function SelezionatuttoCheckBoxValueChanged(app, event)
            selezionatutto = app.SelezionatuttoCheckBox.Value;
            if selezionatutto==1
                app.ModificaParametriCheckBox.Value=1;
                app.CalcolaGrafoCheckBox.Value=1;
                app.VisualizzaGrafoCheckBox.Value=1;
                app.ModificaParametriCheckBox.Enable='off';
                app.CalcolaGrafoCheckBox.Enable='off';
                app.VisualizzaGrafoCheckBox.Enable='off';
            else
                app.ModificaParametriCheckBox.Value=0;
                app.CalcolaGrafoCheckBox.Value=0;
                app.VisualizzaGrafoCheckBox.Value=0;
                app.ModificaParametriCheckBox.Enable='on';
                app.CalcolaGrafoCheckBox.Enable='on';
                app.VisualizzaGrafoCheckBox.Enable='off';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 548 426];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @ChiusuraApp, true);

            % Create CosavuoifareLabel
            app.CosavuoifareLabel = uilabel(app.UIFigure);
            app.CosavuoifareLabel.HorizontalAlignment = 'center';
            app.CosavuoifareLabel.FontSize = 24;
            app.CosavuoifareLabel.FontWeight = 'bold';
            app.CosavuoifareLabel.Position = [19 346 512 48];
            app.CosavuoifareLabel.Text = 'Cosa vuoi fare?';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @ChiusuraApp, true);
            app.OKButton.Position = [218 26 138 40];
            app.OKButton.Text = 'OK';

            % Create ModificaParametriCheckBox
            app.ModificaParametriCheckBox = uicheckbox(app.UIFigure);
            app.ModificaParametriCheckBox.Text = '   Modificare i parametri della rete';
            app.ModificaParametriCheckBox.FontSize = 18;
            app.ModificaParametriCheckBox.Position = [128 201 295 26];

            % Create CalcolaGrafoCheckBox
            app.CalcolaGrafoCheckBox = uicheckbox(app.UIFigure);
            app.CalcolaGrafoCheckBox.ValueChangedFcn = createCallbackFcn(app, @CalcolaGrafoCheckBoxValueChanged, true);
            app.CalcolaGrafoCheckBox.Text = '   Calcolare il grafo di raggiungibilità';
            app.CalcolaGrafoCheckBox.FontSize = 18;
            app.CalcolaGrafoCheckBox.Position = [129 155 314 26];

            % Create VisualizzaGrafoCheckBox
            app.VisualizzaGrafoCheckBox = uicheckbox(app.UIFigure);
            app.VisualizzaGrafoCheckBox.Enable = 'off';
            app.VisualizzaGrafoCheckBox.Text = ' Visualizzare il grafo di raggiungibilità';
            app.VisualizzaGrafoCheckBox.FontSize = 14;
            app.VisualizzaGrafoCheckBox.Position = [141 111 332 25];

            % Create SelezionatuttoCheckBox
            app.SelezionatuttoCheckBox = uicheckbox(app.UIFigure);
            app.SelezionatuttoCheckBox.ValueChangedFcn = createCallbackFcn(app, @SelezionatuttoCheckBoxValueChanged, true);
            app.SelezionatuttoCheckBox.Text = '   Seleziona tutto';
            app.SelezionatuttoCheckBox.FontSize = 18;
            app.SelezionatuttoCheckBox.FontWeight = 'bold';
            app.SelezionatuttoCheckBox.Position = [193 269 166 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = appmenu

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end