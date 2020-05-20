classdef forceplate_main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ForceplateProcessingtoolUIFigure  matlab.ui.Figure
        Menu                            matlab.ui.container.Menu
        LoadfileMenu                    matlab.ui.container.Menu
        UITable                         matlab.ui.control.Table
        CalculatepeaksButton            matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        Forceplates1and2Tab             matlab.ui.container.Tab
        UIAxes                          matlab.ui.control.UIAxes
        UIAxesCoP1                      matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxesCoP2                      matlab.ui.control.UIAxes
        SmoothAButton                   matlab.ui.control.Button
        ResetdataAButton                matlab.ui.control.Button
        SmoothBButton                   matlab.ui.control.Button
        ResetdataBButton                matlab.ui.control.Button
        ColumnselectADropDownLabel      matlab.ui.control.Label
        ColumnselectADropDown           matlab.ui.control.DropDown
        ColumnselectBDropDownLabel      matlab.ui.control.Label
        ColumnselectBDropDown           matlab.ui.control.DropDown
        SummedForceplatesTab            matlab.ui.container.Tab
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxesCoP3                      matlab.ui.control.UIAxes
        SmoothTOTALButton               matlab.ui.control.Button
        ResetdataTOTALButton            matlab.ui.control.Button
        ColumnselectTOTALDropDownLabel  matlab.ui.control.Label
        ColumnselectTOTALDropDown       matlab.ui.control.DropDown
        DataselectDropDownLabel         matlab.ui.control.Label
        DataselectDropDown              matlab.ui.control.DropDown
        TresholdASliderLabel        matlab.ui.control.Label
        TresholdASlider             matlab.ui.control.Slider
        TresholdBSliderLabel        matlab.ui.control.Label
        TresholdBSlider             matlab.ui.control.Slider
        TresholdALabel              matlab.ui.control.Label
        TresholdASlider_2           matlab.ui.control.Slider
        TresholdBSlider_2Label      matlab.ui.control.Label
        TresholdBSlider_2           matlab.ui.control.Slider
    end

    %Hallo ik ben berk
    %hey ik ben bas
    methods (Access = private)
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: LoadfileMenu
        function LoadfileMenuSelected(app, event)
            global signals WIDTH_FP LENGTH_FP FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL FP_TOTAL_ALL FP_TOTAL_time CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y CoP_TOTAL_X CoP_TOTAL_Y;
            %%%%%%BERK%%%%%%%%%%%%
            global Baseline1 constTresholdA constTresholdB tresholdA tresholdB numRows;
            global Baseline2 tresholdA2 tresholdB2 constTresholdB2 constTresholdA2 numRows2;
            %%%%%%%%%%%%%%%%%%%%%%%
            [filename,path] = uigetfile('*.txt');
            figure(app.ForceplateProcessingtoolUIFigure);           % bring ui back to foreground
            % Improved loading from files with it's full filepath so it doesn't crash ocassionally
            filepath = strcat(path,filename);     
            fID = fopen(filepath);
            datacell = textscan(fID,'%f%f%f%f%f%f%f%f%f%f%f%f', 'HeaderLines', 3, 'CollectOutput', 1);
            fclose(fID);
            signals = datacell{1};
            signals(:,12);
            C = 406.831;
            g = 9.81;
            nbits = 16;
            WIDTH_FP = 450;
            LENGTH_FP = 450;
            FP_A_Vfs0 = 2.00058;
            FP_A_Vfs1 = 2.00046;
            FP_A_Vfs2 = 2.00067;
            FP_A_Vfs3 = 2.00086;
            FP_B_Vfs0 = 1.99959;
            FP_B_Vfs1 = 1.99998;
            FP_B_Vfs2 = 1.99995;
            FP_B_Vfs3 = 1.99992;
            FP_A_time = signals(:,1);
            FP_A_0 = signals(:,3)*C/(FP_A_Vfs0*(2^nbits - 1));
            FP_A_1 = signals(:,4)*C/(FP_A_Vfs1*(2^nbits - 1));
            FP_A_2 = signals(:,5)*C/(FP_A_Vfs2*(2^nbits - 1));
            FP_A_3 = signals(:,6)*C/(FP_A_Vfs3*(2^nbits - 1));
            
            FPA_TOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            offsetA = min(FPA_TOTAL);
            FP_A_TOTAL = FPA_TOTAL - offsetA;
            
            FP_B_time = signals(:,7);
            FP_B_0 = signals(:,9)*C/(FP_B_Vfs0*(2^nbits - 1));
            FP_B_1 = signals(:,10)*C/(FP_B_Vfs1*(2^nbits - 1));
            FP_B_2 = signals(:,11)*C/(FP_B_Vfs2*(2^nbits - 1));
            FP_B_3 = signals(:,12)*C/(FP_B_Vfs3*(2^nbits - 1));
            
            FPB_TOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            offsetB = min(FPB_TOTAL)
            FP_B_TOTAL = FPB_TOTAL - offsetB;
            
            [numRows,numCols] = size(FP_A_time);
            baselineConst1 = polyfit(FP_A_time,FP_A_TOTAL,0);
            Baseline1 = zeros(1, numRows) + baselineConst1;
            
            %jumpheight 1 calculation
            [FP_A_TOTAL_PEAKS, FP_A_TOTAL_PK_LOCS] = findpeaks(FP_A_TOTAL, 'MinPeakProminence', 4,'MinPeakDistance', 250);               % peak promincence to filter the peaks by height and width
            FP_A_TOTAL_CHGPTS = findchangepts(FP_A_TOTAL, 'MaxNumChanges', 2, 'Statistic', 'rms');                                      % find the changepts to find the flat part
            flightPoints1 = FP_A_TOTAL_CHGPTS + [10; -5];                                                                        % add vector to fix offset            
            flightTime1 = (flightPoints1(1) - flightPoints1(2))/1000;
            jumpHeight1 = g/2*(flightTime1/2)^2
            
            
%             %Right way to calculate max jumpheight https://www.sciencedirect.com/topics/engineering/force-plate
%             Fz1 = maximum force before takeoff;
%             Fbody1 = baselineConst1 * g;
%             function1 = Fz1 - FBody1
%             vel1 = integral(function1,time before takeoff when standing,
%             takeoff time aka time when maximum force before takeoff);
%             jumpHeight1 = (vel1 * vel1)/(2 * g);
            
            [numRows2,numCols2] = size(FP_B_time);
            baselineConst2 = polyfit(FP_B_time,FP_B_TOTAL,0);
            Baseline2 = zeros(1, numRows2) + baselineConst2;
            
            %Variable tresholds 1
            constTresholdA = app.TresholdASlider.Value;
            tresholdA = zeros(1, numRows) + constTresholdA;
            constTresholdB = app.TresholdBSlider.Value;
            tresholdB = zeros(1, numRows) + constTresholdB;
            
            %Variable tresholds 2
            constTresholdA2 = app.TresholdASlider_2.Value;
            tresholdA2 = zeros(1, numRows2) + constTresholdA2;
            constTresholdB2 = app.TresholdBSlider_2.Value;
            tresholdB2 = zeros(1, numRows2) + constTresholdB2;
            
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            CoP_TOTAL_X = CoP_A_X + CoP_B_X;
            CoP_TOTAL_Y = CoP_A_Y + CoP_B_Y;
            
            % Summing both forceplates
            FP_TOTAL_ALL = FP_A_TOTAL + FP_B_TOTAL;
            if FP_A_time(1) == 0
                FP_TOTAL_time = FP_A_time;
            elseif FP_B_time(1) == 0
                FP_TOTAL_time = FP_B_time;
            end
            
            % Plot FP1 graph
            hold(app.UIAxes, "off");
            plot(app.UIAxes,FP_A_time, FP_A_0);
            hold(app.UIAxes, "on");
            plot(app.UIAxes,FP_A_time, FP_A_1);
            plot(app.UIAxes,FP_A_time, FP_A_2);
            plot(app.UIAxes,FP_A_time, FP_A_3);
            plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
            plot(app.UIAxes,FP_A_time, tresholdA);
            plot(app.UIAxes,FP_A_time, tresholdB);
            plot(app.UIAxes,FP_A_time, Baseline1);
            
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B");
            
            % Plot FP2 graph
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            plot(app.UIAxes2,FP_B_time, Baseline2);
            plot(app.UIAxes2,FP_B_time, tresholdA2);
            plot(app.UIAxes2,FP_B_time, tresholdB2);
            
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B");
            
            % Plot summed FP's graph
            hold(app.UIAxes3, "off");
            plot(app.UIAxes3, FP_TOTAL_time, FP_A_TOTAL);
            hold(app.UIAxes3, "on");
            plot(app.UIAxes3, FP_TOTAL_time, FP_B_TOTAL);
            plot(app.UIAxes3, FP_TOTAL_time, FP_TOTAL_ALL);
            xlabel(app.UIAxes3, "time [datapoints]");
            ylabel(app.UIAxes3, "weight [kgf]");
            legend(app.UIAxes3,"FP_A TOTAL", "FP_B TOTAL", "FP TOTAL SUM");
            
            hold(app.UIAxesCoP1, "off");
            plot(app.UIAxesCoP1,CoP_A_X, CoP_A_Y);
            xlabel(app.UIAxesCoP1, "X[mm]");
            ylabel(app.UIAxesCoP1, "Y[mm]"); 
           
            hold(app.UIAxesCoP2, "off");
            plot(app.UIAxesCoP2,CoP_B_X, CoP_B_Y);
            xlabel(app.UIAxesCoP2, "X[mm]");
            ylabel(app.UIAxesCoP2, "Y[mm]");
            
            hold(app.UIAxesCoP3, "off");
            plot(app.UIAxesCoP3, CoP_TOTAL_X, CoP_TOTAL_Y);
            xlabel(app.UIAxesCoP2, "X[mm]");
            ylabel(app.UIAxesCoP2, "Y[mm]");
            
            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Value changed function: ColumnselectADropDown
        function ColumnselectADropDownValueChanged(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL;
            global Baseline1 tresholdA tresholdB;
            
            value = app.ColumnselectADropDown.Value;
            switch value
                case '1'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_0);
                    legend(app.UIAxes,"FP_A_0");
                case '2'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_1);
                    legend(app.UIAxes,"FP_A_1");
                case '3'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_2);
                    legend(app.UIAxes,"FP_A_2");
                case '4'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_3);
                    legend(app.UIAxes,"FP_A_3");
                case '1-4'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_0);
                    hold(app.UIAxes, "on");
                    plot(app.UIAxes,FP_A_time, FP_A_1);
                    plot(app.UIAxes,FP_A_time, FP_A_2);
                    plot(app.UIAxes,FP_A_time, FP_A_3);
                    legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3");
                case 'SUM'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
                    legend(app.UIAxes,"FP A SUM");
                case 'ALL'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, FP_A_0);
                    hold(app.UIAxes, "on");
                    plot(app.UIAxes,FP_A_time, FP_A_1);
                    plot(app.UIAxes,FP_A_time, FP_A_2);
                    plot(app.UIAxes,FP_A_time, FP_A_3);
                    plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
                    plot(app.UIAxes,FP_A_time, tresholdA);
                    plot(app.UIAxes,FP_A_time, tresholdB);
                    plot(app.UIAxes,FP_A_time, Baseline1);
                    
                    legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B");
                case 'Baseline'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, Baseline);
                    legend(app.UIAxes,"Baseline");
                otherwise
            end
            
        end

        % Value changed function: ColumnselectBDropDown
        function ColumnselectBDropDownValueChanged(app, event)
            global FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL;
            global Baseline2 tresholdA2 tresholdB2;

            value = app.ColumnselectBDropDown.Value;
            switch value
                case '1'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_0);
                    legend(app.UIAxes2,"FP_B_0");
                case '2'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_1);
                    legend(app.UIAxes2,"FP_B_1");
                case '3'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_2);
                    legend(app.UIAxes2,"FP_B_2");
                case '4'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_3);
                    legend(app.UIAxes2,"FP_B_3");
                case '1-4'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_0);
                    hold(app.UIAxes2, "on");
                    plot(app.UIAxes2,FP_B_time, FP_B_1);
                    plot(app.UIAxes2,FP_B_time, FP_B_2);
                    plot(app.UIAxes2,FP_B_time, FP_B_3);
                    legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3");
                case 'SUM'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
                    legend(app.UIAxes2,"FP A SUM");
                case 'ALL'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, FP_B_0);
                    hold(app.UIAxes2, "on");
                    plot(app.UIAxes2,FP_B_time, FP_B_1);
                    plot(app.UIAxes2,FP_B_time, FP_B_2);
                    plot(app.UIAxes2,FP_B_time, FP_B_3);
                    plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
                    plot(app.UIAxes2,FP_B_time, Baseline2);
                    plot(app.UIAxes2,FP_B_time, tresholdA2);
                    plot(app.UIAxes2,FP_B_time, tresholdB2);
                    legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B");
                case 'Baseline'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, Baseline2);
                    legend(app.UIAxes2,"Baseline");
                otherwise
            end
        end

        % Callback function
        function PeakValleyThresholdASliderValueChanged(app, event)
            
%             smoothed_for_peak_detect = smooth(FP_A_TOTAL);
%             smoothed_for_peak_detect = smooth(smoothed_for_peak_detect);
            
%             if(size(FP_A_TOTAL_PK_LOCS)>0)
%                 if (FP_A_TOTAL_PK_LOCS(1) > FP_A_TOTAL_VL_LOCS(1))
%                     %VALLEY BEFORE PEAK
%                     valley = FP_A_TOTAL_VALLEYS(1);
%                     for i = 1:size(FP_A_TOTAL_VL_LOCS)
%                         if(valley > FP_A_TOTAL_VALLEYS(i))
%                             valley = FP_A_TOTAL_VALLEYS(i);
%                         end
%                         
%                     end
%                 else
%                     %PEAK BEFORE VALLEY
%                 end
%             end
        end

        % Callback function
        function PeakValleyThresholdBSliderValueChanged(app, event)
          
            
        end

        % Value changed function: DataselectDropDown
        function DataselectDropDownValueChanged(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL 
            global CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y;
            global FP_A_TOTAL_PK_LOCS FP_A_TOTAL_PEAKS FP_A_TOTAL_VL_LOCS FP_A_TOTAL_VALLEYS FP_B_TOTAL_PK_LOCS FP_B_TOTAL_PEAKS FP_B_TOTAL_VL_LOCS FP_B_TOTAL_VALLEYS;
            value = app.DataselectDropDown.Value;
            switch value
                case 'A0'
                    app.UITable.Data = [FP_A_time FP_A_0];
                case 'A1'
                    app.UITable.Data = [FP_A_time FP_A_1];
                case 'A2'
                    app.UITable.Data = [FP_A_time FP_A_2];
                case 'A3'
                    app.UITable.Data = [FP_A_time FP_A_3];
                case 'A_SUM'
                    app.UITable.Data = [FP_A_time FP_A_TOTAL];
                case 'A_PEAKS'
                    app.UITable.Data = [FP_A_TOTAL_PK_LOCS FP_A_TOTAL_PEAKS];
                case 'A_VALLEYS'
                    app.UITable.Data = [FP_A_TOTAL_VL_LOCS FP_A_TOTAL_VALLEYS];
                case 'B0'
                    app.UITable.Data = [FP_B_time FP_B_0];
                case 'B1'
                    app.UITable.Data = [FP_B_time FP_B_1];
                case 'B2'
                    app.UITable.Data = [FP_B_time FP_B_2];
                case 'B3'
                    app.UITable.Data = [FP_B_time FP_B_3];
                case 'B_SUM'
                    app.UITable.Data = [FP_B_time FP_B_TOTAL];
                case 'B_PEAKS'
                    app.UITable.Data = [FP_B_TOTAL_PK_LOCS FP_B_TOTAL_PEAKS];
                case 'B_VALLEYS'
                    app.UITable.Data = [FP_B_TOTAL_VL_LOCS FP_B_TOTAL_VALLEYS];
            end
        end

        % Button pushed function: CalculatepeaksButton
        function CalculatepeaksButtonPushed(app, event)
            global FP_A_time FP_B_time;
            global FP_A_TOTAL FP_B_TOTAL;
            global FP_A_TOTAL_PEAKS FP_A_TOTAL_PK_LOCS FP_A_TOTAL_VALLEYS FP_A_TOTAL_VL_LOCS FP_A_TOTAL_CHGPTS FP_A_TOTAL_CHGPTS2;
            global FP_B_TOTAL_PEAKS FP_B_TOTAL_PK_LOCS FP_B_TOTAL_VALLEYS FP_B_TOTAL_VL_LOCS FP_B_TOTAL_CHGPTS FP_B_TOTAL_CHGPTS2;
            
            [FP_A_TOTAL_PEAKS, FP_A_TOTAL_PK_LOCS] = findpeaks(FP_A_TOTAL, 'MinPeakProminence', 4,'MinPeakDistance', 250);               % peak promincence to filter the peaks by height and width
            FP_A_TOTAL_CHGPTS = findchangepts(FP_A_TOTAL, 'MaxNumChanges', 2, 'Statistic', 'rms');                                      % find the changepts to find the flat part
            FP_A_TOTAL_CHGPTS2 = FP_A_TOTAL_CHGPTS + [10; -5];                                                                          % add vector to fix offset
            invert_A_TOTAL = -FP_A_TOTAL;
            [FP_A_TOTAL_VALLEYS, FP_A_TOTAL_VL_LOCS] = findpeaks(invert_A_TOTAL, 'MinPeakProminence', 4);
            FP_A_TOTAL_VALLEYS = -FP_A_TOTAL_VALLEYS;
            FP_A_TOTAL_PK_LOCS = FP_A_TOTAL_PK_LOCS + FP_A_time(1,1);
            FP_A_TOTAL_VL_LOCS = FP_A_TOTAL_VL_LOCS + FP_A_time(1,1);
            plot(app.UIAxes,FP_A_TOTAL_PK_LOCS, FP_A_TOTAL_PEAKS, "Marker",".", "LineStyle","none",'MarkerSize', 12);
            plot(app.UIAxes,FP_A_TOTAL_VL_LOCS, FP_A_TOTAL_VALLEYS, "Marker",".", "LineStyle","none",'MarkerSize', 12);
            plot(app.UIAxes,FP_A_time(FP_A_TOTAL_CHGPTS2), FP_A_TOTAL(FP_A_TOTAL_CHGPTS2), "Marker", ".", "Linestyle", "none", 'MarkerSize', 12);    % plot the changepts op de graph
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "FP A Peaks", "FP A Valleys");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B");  %BERK
            
            
            [FP_B_TOTAL_PEAKS, FP_B_TOTAL_PK_LOCS] = findpeaks(FP_B_TOTAL, 'MinPeakProminence', 4,'MinPeakDistance', 250);              % peak promincence to filter the peaks by height and width
            FP_B_TOTAL_CHGPTS = findchangepts(FP_B_TOTAL, 'MaxNumChanges', 2, 'Statistic', 'rms');                                      % find the changepts to find the flat part
            FP_B_TOTAL_CHGPTS2 = FP_B_TOTAL_CHGPTS + [10; -5];                                                                          % add vector to fix offset
            invert_B_TOTAL = -FP_B_TOTAL;
            [FP_B_TOTAL_VALLEYS, FP_B_TOTAL_VL_LOCS] = findpeaks(invert_B_TOTAL, 'MinPeakProminence', 4);
            FP_B_TOTAL_VALLEYS = -FP_B_TOTAL_VALLEYS;
            FP_B_TOTAL_PK_LOCS = FP_B_TOTAL_PK_LOCS + FP_B_time(1,1);
            FP_B_TOTAL_VL_LOCS = FP_B_TOTAL_VL_LOCS + FP_B_time(1,1);
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B"); %BERK
            plot(app.UIAxes2,FP_B_TOTAL_PK_LOCS, FP_B_TOTAL_PEAKS, "Marker",".", "LineStyle","none", 'MarkerSize', 12);
            plot(app.UIAxes2,FP_B_TOTAL_VL_LOCS, FP_B_TOTAL_VALLEYS, "Marker",".", "LineStyle","none", 'MarkerSize', 12);
            plot(app.UIAxes2,FP_B_time(FP_B_TOTAL_CHGPTS2), FP_B_TOTAL(FP_B_TOTAL_CHGPTS2), "Marker", ".", "Linestyle", "none", 'MarkerSize', 12);   % plot de changepts op de graph
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "FP B Peaks", "FP B Valleys");
        end

        % Button pushed function: SmoothAButton
        function SmoothAButtonPushed(app, event)
            global FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y WIDTH_FP LENGTH_FP
            FP_A_TOTAL = smoothdata(FP_A_TOTAL);
            ColumnselectADropDownValueChanged(app);
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            plot(app.UIAxesCoP1,CoP_A_X, CoP_A_Y);
        end

        % Button pushed function: SmoothBButton
        function SmoothBButtonPushed(app, event)
            global FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y WIDTH_FP LENGTH_FP
            FP_B_TOTAL = smoothdata(FP_B_TOTAL);
            ColumnselectBDropDownValueChanged(app);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            plot(app.UIAxesCoP2,CoP_B_X, CoP_B_Y);
        end

        % Button pushed function: ResetdataAButton
        function ResetdataAButtonPushed(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y signals WIDTH_FP LENGTH_FP;
            global tresholdA tresholdB Baseline1
            
            C = 406.831;
            nbits = 16;
            FP_A_Vfs0 = 2.00058;
            FP_A_Vfs1 = 2.00046;
            FP_A_Vfs2 = 2.00067;
            FP_A_Vfs3 = 2.00086;
            
            FP_A_time = signals(:,1);
            FP_A_0 = signals(:,3)*C/(FP_A_Vfs0*(2^nbits - 1));
            FP_A_1 = signals(:,4)*C/(FP_A_Vfs1*(2^nbits - 1));
            FP_A_2 = signals(:,5)*C/(FP_A_Vfs2*(2^nbits - 1));
            FP_A_3 = signals(:,6)*C/(FP_A_Vfs3*(2^nbits - 1));
            
            FPATOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            offsetA = min(FPATOTAL);
            FP_A_TOTAL = FPATOTAL - offsetA;

            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);

            hold(app.UIAxes, "off");
            plot(app.UIAxes,FP_A_time, FP_A_0);
            hold(app.UIAxes, "on");
            plot(app.UIAxes,FP_A_time, FP_A_1);
            plot(app.UIAxes,FP_A_time, FP_A_2);
            plot(app.UIAxes,FP_A_time, FP_A_3);
            plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
            plot(app.UIAxes,FP_A_time, tresholdA);
            plot(app.UIAxes,FP_A_time, tresholdB);
            plot(app.UIAxes,FP_A_time, Baseline1);
            
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "tresholdA", "tresholdB");
            
            plot(app.UIAxesCoP1,CoP_A_X, CoP_A_Y);
            xlabel(app.UIAxesCoP1, "X[mm]");
            ylabel(app.UIAxesCoP1, "Y[mm]"); 

            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Button pushed function: ResetdataBButton
        function ResetdataBButtonPushed(app, event)
            global FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y signals WIDTH_FP LENGTH_FP;
            global Baseline2 tresholdA2 tresholdB2
            
            C = 406.831;
            nbits = 16;
            FP_B_Vfs0 = 1.99959;
            FP_B_Vfs1 = 1.99998;
            FP_B_Vfs2 = 1.99995;
            FP_B_Vfs3 = 1.99992;
            
            FP_B_time = signals(:,7);
            FP_B_0 = signals(:,9)*C/(FP_B_Vfs0*(2^nbits - 1));
            FP_B_1 = signals(:,10)*C/(FP_B_Vfs1*(2^nbits - 1));
            FP_B_2 = signals(:,11)*C/(FP_B_Vfs2*(2^nbits - 1));
            FP_B_3 = signals(:,12)*C/(FP_B_Vfs3*(2^nbits - 1));
            
            FPBTOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            offsetB = min(FPBTOTAL);
            FP_B_TOTAL = FPBTOTAL - offsetB;
            
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL); 
                        
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            plot(app.UIAxes2,FP_B_time, tresholdA2);
            plot(app.UIAxes2,FP_B_time, tresholdB2);
            plot(app.UIAxes2,FP_B_time, Baseline2);
            
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "tresholdA", "tresholdB");
            
            plot(app.UIAxesCoP2,CoP_B_X, CoP_B_Y);
            xlabel(app.UIAxesCoP2, "X[mm]");
            ylabel(app.UIAxesCoP2, "Y[mm]");
            
            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Button pushed function: SmoothTOTALButton
        function SmoothTOTALButtonPushed(app, event)
            global FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y CoP_TOTAL_X CoP_TOTAL_Y WIDTH_FP LENGTH_FP FP_TOTAL_ALL
            FP_TOTAL_ALL = smoothdata(FP_TOTAL_ALL);
            FP_A_TOTAL = smoothdata(FP_A_TOTAL);
            FP_B_TOTAL = smoothdata(FP_B_TOTAL);
            ColumnselectTOTALDropDownValueChanged(app);
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            CoP_TOTAL_X = CoP_A_X + CoP_B_X;
            CoP_TOTAL_Y = CoP_A_Y + CoP_B_Y;
            plot(app.UIAxesCoP3,CoP_TOTAL_X, CoP_TOTAL_Y);
        end

        % Value changed function: ColumnselectTOTALDropDown
        function ColumnselectTOTALDropDownValueChanged(app, event)
            global FP_A_TOTAL FP_B_TOTAL FP_TOTAL_ALL FP_TOTAL_time;
            global Baseline3 tresholdtotalA tresholdtotalB;
            value = app.ColumnselectTOTALDropDown.Value;

            switch value
                case '1'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    legend(app.UIAxes3,"FP_A TOTAL");
                case '2'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    legend(app.UIAxes3,"FP_B TOTAL");
                case '1-2'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    hold(app.UIAxes3, "on");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    legend(app.UIAxes3,"FP_A", "FP_B");
                case 'SUM'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
                    legend(app.UIAxes3,"FP_B TOTAL");
                case 'ALL'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    hold(app.UIAxes3, "on");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
                    plot(app.UIAxes3,FP_TOTAL_time, tresholdtotalA);
                    plot(app.UIAxes3,FP_TOTAL_time, tresholdtotalB);
                    legend(app.UIAxes3,"FP_A", "FP_B", "FP TOTAL", "Treshold A", "Treshold B");
                otherwise
            end
        end

        % Button pushed function: ResetdataTOTALButton
        function ResetdataTOTALButtonPushed(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y FP_TOTAL_ALL CoP_TOTAL_X CoP_TOTAL_Y FP_TOTAL_time signals WIDTH_FP LENGTH_FP;
            global Baseline3 tresholdtotalA tresholdtotalB;
            
            C = 406.831;
            nbits = 16;
            
            FP_A_Vfs0 = 2.00058;
            FP_A_Vfs1 = 2.00046;
            FP_A_Vfs2 = 2.00067;
            FP_A_Vfs3 = 2.00086;
            
            FP_B_Vfs0 = 1.99959;
            FP_B_Vfs1 = 1.99998;
            FP_B_Vfs2 = 1.99995;
            FP_B_Vfs3 = 1.99992;
            
            FP_A_time = signals(:,1);
            FP_A_0 = signals(:,3)*C/(FP_A_Vfs0*(2^nbits - 1));
            FP_A_1 = signals(:,4)*C/(FP_A_Vfs1*(2^nbits - 1));
            FP_A_2 = signals(:,5)*C/(FP_A_Vfs2*(2^nbits - 1));
            FP_A_3 = signals(:,6)*C/(FP_A_Vfs3*(2^nbits - 1));
            FPA_TOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            offsetA = min(FPA_TOTAL);
            FP_A_TOTAL = FPA_TOTAL - offsetA;
            
            FP_TOTAL_ALL = FP_A_TOTAL + FP_B_TOTAL;
            
            FP_B_time = signals(:,7);
            FP_B_0 = signals(:,9)*C/(FP_B_Vfs0*(2^nbits - 1));
            FP_B_1 = signals(:,10)*C/(FP_B_Vfs1*(2^nbits - 1));
            FP_B_2 = signals(:,11)*C/(FP_B_Vfs2*(2^nbits - 1));
            FP_B_3 = signals(:,12)*C/(FP_B_Vfs3*(2^nbits - 1));
            FPBTOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            offsetB = min(FPBTOTAL);
            FP_B_TOTAL = FPBTOTAL - offsetB;
            
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            
            hold(app.UIAxes3, "off");
            plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
            hold(app.UIAxes3, "on");
            plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
            plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
            plot(app.UIAxes3,FP_TOTAL_time, tresholdtotalA);
            plot(app.UIAxes3,FP_TOTAL_time, tresholdtotalB);
            xlabel(app.UIAxes3, "time[datapoints]");
            ylabel(app.UIAxes3, "weight [kgf]");
            legend(app.UIAxes3,"FP_A", "FP_B", "FP TOTAL", "Treshold A", "Treshold B");
            
            plot(app.UIAxesCoP3,CoP_TOTAL_X, CoP_TOTAL_Y);
            xlabel(app.UIAxesCoP3, "X[mm]");
            ylabel(app.UIAxesCoP3, "Y[mm]"); 

            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Value changed function: TresholdASlider
        function TresholdASliderValueChanged(app, event)
            global tresholdA numRows;            
            slidervalue = event.Value;
            tresholdA = zeros(1, numRows) + slidervalue;
            
            ColumnselectADropDownValueChanged(app, event);
        end

        % Value changed function: TresholdBSlider
        function TresholdBSliderValueChanged(app, event)
            global tresholdB numRows;            
            slidervalue = event.Value;
            tresholdB = zeros(1, numRows) + slidervalue;
            
            ColumnselectADropDownValueChanged(app, event);
        end

        % Value changed function: TresholdASlider_2
        function TresholdASlider_2ValueChanged(app, event)
            global tresholdA2 numRows2;            
            slidervalue = event.Value;
            tresholdA2 = zeros(1, numRows2) + slidervalue;
            
            ColumnselectBDropDownValueChanged(app, event);
        end

        % Value changed function: TresholdBSlider_2
        function TresholdBSlider_2ValueChanged(app, event)
            global tresholdB2 numRows2;            
            slidervalue = event.Value;
            tresholdB2 = zeros(1, numRows2) + slidervalue;
            
            ColumnselectBDropDownValueChanged(app, event);
        end

        % Button pushed function: SmoothTOTALButton
        function SmoothTOTALButtonPushed(app, event)
            global FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y CoP_TOTAL_X CoP_TOTAL_Y WIDTH_FP LENGTH_FP FP_TOTAL_ALL
            FP_TOTAL_ALL = smoothdata(FP_TOTAL_ALL);
            FP_A_TOTAL = smoothdata(FP_A_TOTAL);
            FP_B_TOTAL = smoothdata(FP_B_TOTAL);
            ColumnselectTOTALDropDownValueChanged(app);
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            CoP_TOTAL_X = CoP_A_X + CoP_B_X;
            CoP_TOTAL_Y = CoP_A_Y + CoP_B_Y;
            plot(app.UIAxesCoP3,CoP_TOTAL_X, CoP_TOTAL_Y);
        end

        % Value changed function: ColumnselectTOTALDropDown
        function ColumnselectTOTALDropDownValueChanged(app, event)
            global FP_A_TOTAL FP_B_TOTAL FP_TOTAL_ALL FP_TOTAL_time;
            
            value = app.ColumnselectTOTALDropDown.Value;

            switch value
                case '1'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    legend(app.UIAxes3,"FP_A TOTAL");
                case '2'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    legend(app.UIAxes3,"FP_B TOTAL");
                case '1-2'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    hold(app.UIAxes3, "on");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    legend(app.UIAxes3,"FP_A", "FP_B");
                case 'SUM'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
                    legend(app.UIAxes3,"FP_B TOTAL");
                case 'ALL'
                    hold(app.UIAxes3, "off");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
                    hold(app.UIAxes3, "on");
                    plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
                    plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
                    legend(app.UIAxes3,"FP_A", "FP_B", "FP TOTAL");
                otherwise
            end
        end

        % Button pushed function: ResetdataTOTALButton
        function ResetdataTOTALButtonPushed(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y FP_TOTAL_ALL CoP_TOTAL_X CoP_TOTAL_Y FP_TOTAL_time signals WIDTH_FP LENGTH_FP;
            
            C = 406.831;
            nbits = 16;
            
            FP_A_Vfs0 = 2.00058;
            FP_A_Vfs1 = 2.00046;
            FP_A_Vfs2 = 2.00067;
            FP_A_Vfs3 = 2.00086;
            
            FP_B_Vfs0 = 1.99959;
            FP_B_Vfs1 = 1.99998;
            FP_B_Vfs2 = 1.99995;
            FP_B_Vfs3 = 1.99992;
            
            FP_A_time = signals(:,1);
            FP_A_0 = signals(:,3)*C/(FP_A_Vfs0*(2^nbits - 1));
            FP_A_1 = signals(:,4)*C/(FP_A_Vfs1*(2^nbits - 1));
            FP_A_2 = signals(:,5)*C/(FP_A_Vfs2*(2^nbits - 1));
            FP_A_3 = signals(:,6)*C/(FP_A_Vfs3*(2^nbits - 1));
            FP_A_TOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            
            FP_B_time = signals(:,7);
            FP_B_0 = signals(:,9)*C/(FP_B_Vfs0*(2^nbits - 1));
            FP_B_1 = signals(:,10)*C/(FP_B_Vfs1*(2^nbits - 1));
            FP_B_2 = signals(:,11)*C/(FP_B_Vfs2*(2^nbits - 1));
            FP_B_3 = signals(:,12)*C/(FP_B_Vfs3*(2^nbits - 1));
            FP_B_TOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            
            hold(app.UIAxes3, "off");
            plot(app.UIAxes3,FP_TOTAL_time, FP_A_TOTAL);
            hold(app.UIAxes3, "on");
            plot(app.UIAxes3,FP_TOTAL_time, FP_B_TOTAL);
            plot(app.UIAxes3,FP_TOTAL_time, FP_TOTAL_ALL);
            xlabel(app.UIAxes3, "time[datapoints]");
            ylabel(app.UIAxes3, "weight [kgf]");
            legend(app.UIAxes3,"FP_A", "FP_B", "FP TOTAL");
            
            plot(app.UIAxesCoP3,CoP_TOTAL_X, CoP_TOTAL_Y);
            xlabel(app.UIAxesCoP3, "X[mm]");
            ylabel(app.UIAxesCoP3, "Y[mm]"); 

            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ForceplateProcessingtoolUIFigure and hide until all components are created
            app.ForceplateProcessingtoolUIFigure = uifigure('Visible', 'off');
            app.ForceplateProcessingtoolUIFigure.Position = [100 100 1343 856];
            app.ForceplateProcessingtoolUIFigure.Name = 'Forceplate Processing tool';
            app.ForceplateProcessingtoolUIFigure.Scrollable = 'on';

            % Create Menu
            app.Menu = uimenu(app.ForceplateProcessingtoolUIFigure);
            app.Menu.Text = 'Menu';

            % Create LoadfileMenu
            app.LoadfileMenu = uimenu(app.Menu);
            app.LoadfileMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadfileMenuSelected, true);
            app.LoadfileMenu.Text = 'Load file';

            % Create UITable
            app.UITable = uitable(app.ForceplateProcessingtoolUIFigure);
            app.UITable.ColumnName = {'t[s]'; 'F'};
            app.UITable.RowName = {};
            app.UITable.Position = [1122 113 212 655];

            % Create CalculatepeaksButton
            app.CalculatepeaksButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.CalculatepeaksButton.ButtonPushedFcn = createCallbackFcn(app, @CalculatepeaksButtonPushed, true);
            app.CalculatepeaksButton.Position = [1139 777 178 22];
            app.CalculatepeaksButton.Text = 'Calculate peaks';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ForceplateProcessingtoolUIFigure);
            app.TabGroup.Position = [12 9 1098 848];

            % Create Forceplates1and2Tab
            app.Forceplates1and2Tab = uitab(app.TabGroup);
            app.Forceplates1and2Tab.Title = 'Forceplates 1 and 2';

            % Create UIAxes
            app.UIAxes = uiaxes(app.Forceplates1and2Tab);
            title(app.UIAxes, 'Forces FP1')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [1 477 738 337];

            % Create UIAxesCoP1
            app.UIAxesCoP1 = uiaxes(app.Forceplates1and2Tab);
            title(app.UIAxesCoP1, 'CoP FP1')
            xlabel(app.UIAxesCoP1, 'X')
            ylabel(app.UIAxesCoP1, 'Y')
            app.UIAxesCoP1.Position = [738 473 342 341];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.Forceplates1and2Tab);
            title(app.UIAxes2, 'Forces FP2')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [1 75 738 337];

            % Create UIAxesCoP2
            app.UIAxesCoP2 = uiaxes(app.Forceplates1and2Tab);
            title(app.UIAxesCoP2, 'CoP FP2')
            xlabel(app.UIAxesCoP2, 'X')
            ylabel(app.UIAxesCoP2, 'Y')
            app.UIAxesCoP2.Position = [738 71 342 341];

            % Create SmoothAButton
            app.SmoothAButton = uibutton(app.Forceplates1and2Tab, 'push');
            app.SmoothAButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothAButtonPushed, true);
            app.SmoothAButton.Position = [276 452 100 22];
            app.SmoothAButton.Text = 'Smooth A';

            % Create ResetdataAButton
            app.ResetdataAButton = uibutton(app.Forceplates1and2Tab, 'push');
            app.ResetdataAButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataAButtonPushed, true);
            app.ResetdataAButton.Position = [133 415 100 22];
            app.ResetdataAButton.Text = 'Reset data A';

            % Create SmoothBButton
            app.SmoothBButton = uibutton(app.Forceplates1and2Tab, 'push');
            app.SmoothBButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothBButtonPushed, true);
            app.SmoothBButton.Position = [276 50 100 22];
            app.SmoothBButton.Text = 'Smooth B';

            % Create ResetdataBButton
            app.ResetdataBButton = uibutton(app.Forceplates1and2Tab, 'push');
            app.ResetdataBButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataBButtonPushed, true);
            app.ResetdataBButton.Position = [133 15 100 22];
            app.ResetdataBButton.Text = 'Reset data B';

            % Create ColumnselectADropDownLabel
            app.ColumnselectADropDownLabel = uilabel(app.Forceplates1and2Tab);
            app.ColumnselectADropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectADropDownLabel.Position = [25 452 93 22];
            app.ColumnselectADropDownLabel.Text = 'Column select A';

            % Create ColumnselectADropDown
            app.ColumnselectADropDown = uidropdown(app.Forceplates1and2Tab);
            app.ColumnselectADropDown.Items = {'1', '2', '3', '4', '1-4', 'SUM', 'ALL'};
            app.ColumnselectADropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectADropDownValueChanged, true);
            app.ColumnselectADropDown.Position = [133 452 100 22];
            app.ColumnselectADropDown.Value = 'ALL';

            % Create ColumnselectBDropDownLabel
            app.ColumnselectBDropDownLabel = uilabel(app.Forceplates1and2Tab);
            app.ColumnselectBDropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectBDropDownLabel.Position = [25 50 93 22];
            app.ColumnselectBDropDownLabel.Text = 'Column select B';

            % Create ColumnselectBDropDown
            app.ColumnselectBDropDown = uidropdown(app.Forceplates1and2Tab);
            app.ColumnselectBDropDown.Items = {'1', '2', '3', '4', '1-4', 'SUM', 'ALL'};
            app.ColumnselectBDropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectBDropDownValueChanged, true);
            app.ColumnselectBDropDown.Position = [133 50 100 22];
            app.ColumnselectBDropDown.Value = 'ALL';

            % Create SummedForceplatesTab
            app.SummedForceplatesTab = uitab(app.TabGroup);
            app.SummedForceplatesTab.Title = 'Summed Forceplates';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.SummedForceplatesTab);
            title(app.UIAxes3, {'Summed Forces FP1+2'; ''})
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.Position = [1 477 738 337];

            % Create UIAxesCoP3
            app.UIAxesCoP3 = uiaxes(app.SummedForceplatesTab);
            title(app.UIAxesCoP3, 'CoP FP1+2')
            xlabel(app.UIAxesCoP3, 'X')
            ylabel(app.UIAxesCoP3, 'Y')
            app.UIAxesCoP3.Position = [738 474 342 341];

            % Create SmoothTOTALButton
            app.SmoothTOTALButton = uibutton(app.SummedForceplatesTab, 'push');
            app.SmoothTOTALButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothTOTALButtonPushed, true);
            app.SmoothTOTALButton.Position = [320 438 100 22];
            app.SmoothTOTALButton.Text = 'Smooth TOTAL';

            % Create ResetdataTOTALButton
            app.ResetdataTOTALButton = uibutton(app.SummedForceplatesTab, 'push');
            app.ResetdataTOTALButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataTOTALButtonPushed, true);
            app.ResetdataTOTALButton.Position = [175 401 114 22];
            app.ResetdataTOTALButton.Text = 'Reset data TOTAL';

            % Create ColumnselectTOTALDropDownLabel
            app.ColumnselectTOTALDropDownLabel = uilabel(app.SummedForceplatesTab);
            app.ColumnselectTOTALDropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectTOTALDropDownLabel.Position = [38 438 122 22];
            app.ColumnselectTOTALDropDownLabel.Text = 'Column select TOTAL';

            % Create ColumnselectTOTALDropDown
            app.ColumnselectTOTALDropDown = uidropdown(app.SummedForceplatesTab);
            app.ColumnselectTOTALDropDown.Items = {'1', '2', '1-2', 'SUM', 'ALL'};
            app.ColumnselectTOTALDropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectTOTALDropDownValueChanged, true);
            app.ColumnselectTOTALDropDown.Position = [175 438 114 22];
            app.ColumnselectTOTALDropDown.Value = 'ALL';

            % Create DataselectDropDownLabel
            app.DataselectDropDownLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDownLabel.HorizontalAlignment = 'right';
            app.DataselectDropDownLabel.Position = [1136 810 66 22];
            app.DataselectDropDownLabel.Text = 'Data select';

            % Create DataselectDropDown
            app.DataselectDropDown = uidropdown(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDown.Items = {'A0', 'A1', 'A2', 'A3', 'A_SUM', 'A_PEAKS', 'A_VALLEYS', 'B0', 'B1', 'B2', 'B3', 'B_SUM', 'B_PEAKS', 'B_VALLEYS'};
            app.DataselectDropDown.ValueChangedFcn = createCallbackFcn(app, @DataselectDropDownValueChanged, true);
            app.DataselectDropDown.Position = [1217 810 100 22];
            app.DataselectDropDown.Value = 'A0';
          
            % Create TresholdASliderLabel
            app.TresholdASliderLabel = uilabel(app.Forceplates1and2Tab);
            app.TresholdASliderLabel.HorizontalAlignment = 'right';
            app.TresholdASliderLabel.Position = [457 529 63 22];
            app.TresholdASliderLabel.Text = 'Treshold A';

            % Create TresholdASlider
            app.TresholdASlider = uislider(app.Forceplates1and2Tab);
            app.TresholdASlider.Limits = [0 300];
            app.TresholdASlider.MajorTicks = [0 50 100 150 200 250 300];
            app.TresholdASlider.ValueChangedFcn = createCallbackFcn(app, @TresholdASliderValueChanged, true);
            app.TresholdASlider.Position = [541 538 150 3];
            app.TresholdASlider.Value = 150;

            % Create TresholdBSliderLabel
            app.TresholdBSliderLabel = uilabel(app.Forceplates1and2Tab);
            app.TresholdBSliderLabel.HorizontalAlignment = 'right';
            app.TresholdBSliderLabel.Position = [460 471 63 22];
            app.TresholdBSliderLabel.Text = 'Treshold B';

            % Create TresholdBSlider
            app.TresholdBSlider = uislider(app.Forceplates1and2Tab);
            app.TresholdBSlider.Limits = [0 300];
            app.TresholdBSlider.ValueChangedFcn = createCallbackFcn(app, @TresholdBSliderValueChanged, true);
            app.TresholdBSlider.Position = [544 480 150 3];
            app.TresholdBSlider.Value = 20;

            % Create TresholdALabel
            app.TresholdALabel = uilabel(app.Forceplates1and2Tab);
            app.TresholdALabel.HorizontalAlignment = 'right';
            app.TresholdALabel.Position = [492 72 63 22];
            app.TresholdALabel.Text = 'Treshold A';

            % Create TresholdASlider_2
            app.TresholdASlider_2 = uislider(app.Forceplates1and2Tab);
            app.TresholdASlider_2.Limits = [0 300];
            app.TresholdASlider_2.ValueChangedFcn = createCallbackFcn(app, @TresholdASlider_2ValueChanged, true);
            app.TresholdASlider_2.Position = [541 84 150 3];
            app.TresholdASlider_2.Value = 150;

            % Create TresholdBSlider_2Label
            app.TresholdBSlider_2Label = uilabel(app.Forceplates1and2Tab);
            app.TresholdBSlider_2Label.HorizontalAlignment = 'right';
            app.TresholdBSlider_2Label.Position = [457 33 63 22];
            app.TresholdBSlider_2Label.Text = 'Treshold B';
            
            % Create TresholdBSlider_2
            app.TresholdBSlider_2 = uislider(app.Forceplates1and2Tab);
            app.TresholdBSlider_2.Limits = [0 300];
            app.TresholdBSlider_2.ValueChangedFcn = createCallbackFcn(app, @TresholdBSlider_2ValueChanged, true);
            app.TresholdBSlider_2.Position = [541 42 150 3];
            app.TresholdBSlider_2.Value = 20;

            % Create SummedForceplatesTab
            app.SummedForceplatesTab = uitab(app.TabGroup);
            app.SummedForceplatesTab.Title = 'Summed Forceplates';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.SummedForceplatesTab);
            title(app.UIAxes3, {'Summed Forces FP1+2'; ''})
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.Position = [1 517 738 337];

            % Create UIAxesCoP3
            app.UIAxesCoP3 = uiaxes(app.SummedForceplatesTab);
            title(app.UIAxesCoP3, 'CoP FP1+2')
            xlabel(app.UIAxesCoP3, 'X')
            ylabel(app.UIAxesCoP3, 'Y')
            app.UIAxesCoP3.Position = [738 520 342 341];

            % Create SmoothTOTALButton
            app.SmoothTOTALButton = uibutton(app.SummedForceplatesTab, 'push');
            app.SmoothTOTALButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothTOTALButtonPushed, true);
            app.SmoothTOTALButton.Position = [320 481 100 22];
            app.SmoothTOTALButton.Text = 'Smooth TOTAL';

            % Create ResetdataTOTALButton
            app.ResetdataTOTALButton = uibutton(app.SummedForceplatesTab, 'push');
            app.ResetdataTOTALButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataTOTALButtonPushed, true);
            app.ResetdataTOTALButton.Position = [175 444 114 22];
            app.ResetdataTOTALButton.Text = 'Reset data TOTAL';

            % Create ColumnselectTOTALDropDownLabel
            app.ColumnselectTOTALDropDownLabel = uilabel(app.SummedForceplatesTab);
            app.ColumnselectTOTALDropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectTOTALDropDownLabel.Position = [38 481 122 22];
            app.ColumnselectTOTALDropDownLabel.Text = 'Column select TOTAL';

            % Create ColumnselectTOTALDropDown
            app.ColumnselectTOTALDropDown = uidropdown(app.SummedForceplatesTab);
            app.ColumnselectTOTALDropDown.Items = {'1', '2', '1-2', 'SUM', 'ALL'};
            app.ColumnselectTOTALDropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectTOTALDropDownValueChanged, true);
            app.ColumnselectTOTALDropDown.Position = [175 481 114 22];
            app.ColumnselectTOTALDropDown.Value = 'ALL';

            % Create TresholdASlider_3Label
            app.TresholdASlider_3Label = uilabel(app.SummedForceplatesTab);
            app.TresholdASlider_3Label.HorizontalAlignment = 'right';
            app.TresholdASlider_3Label.Position = [457 486 63 22];
            app.TresholdASlider_3Label.Text = 'Treshold A';

            % Create TresholdASlider_3
            app.TresholdASlider_3 = uislider(app.SummedForceplatesTab);
            app.TresholdASlider_3.Limits = [0 300];
            app.TresholdASlider_3.ValueChangedFcn = createCallbackFcn(app, @TresholdASlider_3ValueChanged, true);
            app.TresholdASlider_3.Position = [541 495 150 3];
            app.TresholdASlider_3.Value = 150;

            % Create TresholdBSlider_3Label
            app.TresholdBSlider_3Label = uilabel(app.SummedForceplatesTab);
            app.TresholdBSlider_3Label.HorizontalAlignment = 'right';
            app.TresholdBSlider_3Label.Position = [463 423 63 22];
            app.TresholdBSlider_3Label.Text = 'Treshold B';

            % Create TresholdBSlider_3
            app.TresholdBSlider_3 = uislider(app.SummedForceplatesTab);
            app.TresholdBSlider_3.Limits = [0 300];
            app.TresholdBSlider_3.ValueChangedFcn = createCallbackFcn(app, @TresholdBSlider_3ValueChanged, true);
            app.TresholdBSlider_3.Position = [547 432 150 3];
            app.TresholdBSlider_3.Value = 20;

            % Create DataselectDropDownLabel
            app.DataselectDropDownLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDownLabel.HorizontalAlignment = 'right';
            app.DataselectDropDownLabel.Position = [1136 909 66 22];
            app.DataselectDropDownLabel.Text = 'Data select';

            % Create DataselectDropDown
            app.DataselectDropDown = uidropdown(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDown.Items = {'A0', 'A1', 'A2', 'A3', 'A_SUM', 'A_PEAKS', 'A_VALLEYS', 'B0', 'B1', 'B2', 'B3', 'B_SUM', 'B_PEAKS', 'B_VALLEYS'};
            app.DataselectDropDown.ValueChangedFcn = createCallbackFcn(app, @DataselectDropDownValueChanged, true);
            app.DataselectDropDown.Position = [1217 909 100 22];
            app.DataselectDropDown.Value = 'A0';

            % Show the figure after all components are created
            app.ForceplateProcessingtoolUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = forceplate_main

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ForceplateProcessingtoolUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ForceplateProcessingtoolUIFigure)
        end
    end
end