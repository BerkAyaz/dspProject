classdef forceplate_main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ForceplateProcessingtoolUIFigure  matlab.ui.Figure
        Menu                        matlab.ui.container.Menu
        LoadfileMenu                matlab.ui.container.Menu
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxes3                     matlab.ui.control.UIAxes
        UIAxes3_2                   matlab.ui.control.UIAxes
        UITable                     matlab.ui.control.Table
        ColumnselectADropDownLabel  matlab.ui.control.Label
        ColumnselectADropDown       matlab.ui.control.DropDown
        ColumnselectBDropDownLabel  matlab.ui.control.Label
        ColumnselectBDropDown       matlab.ui.control.DropDown
        DataselectDropDownLabel     matlab.ui.control.Label
        DataselectDropDown          matlab.ui.control.DropDown
        CalculatepeaksButton        matlab.ui.control.Button
        SmoothAButton               matlab.ui.control.Button
        SmoothBButton               matlab.ui.control.Button
        ResetdataAButton            matlab.ui.control.Button
        ResetdataBButton            matlab.ui.control.Button
        TresholdASliderLabel        matlab.ui.control.Label
        TresholdASlider             matlab.ui.control.Slider
        TresholdBSliderLabel        matlab.ui.control.Label
        TresholdBSlider             matlab.ui.control.Slider
        TresholdALabel              matlab.ui.control.Label
        TresholdASlider_2           matlab.ui.control.Slider
        TresholdBSlider_2Label      matlab.ui.control.Label
        TresholdBSlider_2           matlab.ui.control.Slider
    end

    methods (Access = private)
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: LoadfileMenu
        function LoadfileMenuSelected(app, event)
            global signals WIDTH_FP LENGTH_FP FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y;
            %%%%%%BERK%%%%%%%%%%%%
            global Baseline1 constTresholdA constTresholdB tresholdA tresholdB numRows;
            global Baseline2 tresholdA2 tresholdB2 constTresholdB2 constTresholdA2 numRows2;
            %%%%%%%%%%%%%%%%%%%%%%%
            filename = uigetfile('*.txt');
            fID = fopen(filename)
            datacell = textscan(fID,'%f%f%f%f%f%f%f%f%f%f%f%f', 'HeaderLines', 3, 'CollectOutput', 1);
            fclose(fID);
            signals= datacell{1};
            signals(:,12);
            C = 406.831;
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
            
            %%%%%%%%%%%%%BERK%%%%%%%%%%%
            FPA_TOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            offsetA = min(FPA_TOTAL);
            FP_A_TOTAL = FPA_TOTAL - offsetA;
            %%%%%%%%%%%%%%%%%%%%%%%
            
            FP_B_time = signals(:,7);
            FP_B_0 = signals(:,9)*C/(FP_B_Vfs0*(2^nbits - 1));
            FP_B_1 = signals(:,10)*C/(FP_B_Vfs1*(2^nbits - 1));
            FP_B_2 = signals(:,11)*C/(FP_B_Vfs2*(2^nbits - 1));
            FP_B_3 = signals(:,12)*C/(FP_B_Vfs3*(2^nbits - 1));
            
            %%%%%%%%%%%%%%%%%BERK%%%%%%%%%%%%%%
            FPB_TOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            offsetB = min(FPB_TOTAL)
            FP_B_TOTAL = FPB_TOTAL - offsetB;
            
            [numRows,numCols] = size(FP_A_time);
            baselineConst1 = polyfit(FP_A_time,FP_A_TOTAL,0);
            Baseline1 = zeros(1, numRows) + baselineConst1;
            
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL); 
            hold(app.UIAxes, "off");
            plot(app.UIAxes,FP_A_time, FP_A_0);
            hold(app.UIAxes, "on");
            plot(app.UIAxes,FP_A_time, FP_A_1);
            plot(app.UIAxes,FP_A_time, FP_A_2);
            plot(app.UIAxes,FP_A_time, FP_A_3);
            plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
            %%%%%%%%%BERK%%%%%%%%%%%%
            plot(app.UIAxes,FP_A_time, tresholdA);
            plot(app.UIAxes,FP_A_time, tresholdB);
            plot(app.UIAxes,FP_A_time, Baseline1);
            %%%%%%%%%%%%%%%%%%%%%%
            
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B");  %Berk: laatste twee parameters toegevoegd
            
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            %%%%%%BERK%%%%%%%%
            plot(app.UIAxes2,FP_B_time, Baseline2);
            plot(app.UIAxes2,FP_B_time, tresholdA2);
            plot(app.UIAxes2,FP_B_time, tresholdB2);
            %%%%%%%%%%%%%%%%%%%

            
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B"); %Berk: laatste twee parameters toegevoegd
            
            hold(app.UIAxes3, "off");
            plot(app.UIAxes3,CoP_A_X, CoP_A_Y);
            xlabel(app.UIAxes3, "X[mm]");
            ylabel(app.UIAxes3, "Y[mm]"); 
           
            hold(app.UIAxes3_2, "off");
            plot(app.UIAxes3_2,CoP_B_X, CoP_B_Y);
            xlabel(app.UIAxes3_2, "X[mm]");
            ylabel(app.UIAxes3_2, "Y[mm]");
            
            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Value changed function: ColumnselectADropDown
        function ColumnselectADropDownValueChanged(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL;
            global Baseline1 tresholdA tresholdB;      %BERK
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
                    %%%%%%BERK%%%%%%%
                    plot(app.UIAxes,FP_A_time, tresholdA);
                    plot(app.UIAxes,FP_A_time, tresholdB);
                    plot(app.UIAxes,FP_A_time, Baseline1);
                    %%%%%%%%%%%%%%%%%%
                    
                    legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B"); %Berk: laatste twee parameters toegevoegd
                    %%%%%%%%%%BERK%%%%%%%%%%
                case 'Baseline'
                    hold(app.UIAxes, "off");
                    plot(app.UIAxes,FP_A_time, Baseline);
                    legend(app.UIAxes,"Baseline");
                otherwise
                    %%%%%%%%%%%%%%%%%%%%%%%
            end
            
        end

        % Value changed function: ColumnselectBDropDown
        function ColumnselectBDropDownValueChanged(app, event)
            global FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL;
            global Baseline2 tresholdA2 tresholdB2;     %Berk

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
                    %%%%%%%%BERK%%%%%%%%%%%%%%
                    plot(app.UIAxes2,FP_B_time, Baseline2);
                    plot(app.UIAxes2,FP_B_time, tresholdA2);
                    plot(app.UIAxes2,FP_B_time, tresholdB2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B"); %Berk: laatste twee parameters toegevoegd
                    %%%%%%%%%%BERK%%%%%%%%%%
                case 'Baseline'
                    hold(app.UIAxes2, "off");
                    plot(app.UIAxes2,FP_B_time, Baseline2);
                    legend(app.UIAxes2,"Baseline");
                    %%%%%%%%%%%%%%%%%%%%%%%
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
            global FP_A_TOTAL_PEAKS FP_A_TOTAL_PK_LOCS FP_A_TOTAL_VALLEYS FP_A_TOTAL_VL_LOCS;
            global FP_B_TOTAL_PEAKS FP_B_TOTAL_PK_LOCS FP_B_TOTAL_VALLEYS FP_B_TOTAL_VL_LOCS;
            
            [FP_A_TOTAL_PEAKS, FP_A_TOTAL_PK_LOCS] = findpeaks(FP_A_TOTAL, 'MinPeakWidth', 50);     %Bas
            invert_A_TOTAL = -FP_A_TOTAL;
            [FP_A_TOTAL_VALLEYS, FP_A_TOTAL_VL_LOCS] = findpeaks(invert_A_TOTAL, 'MinPeakWidth', 50);   %Bas
            FP_A_TOTAL_VALLEYS = -FP_A_TOTAL_VALLEYS;
            FP_A_TOTAL_PK_LOCS = FP_A_TOTAL_PK_LOCS + FP_A_time(1,1);
            FP_A_TOTAL_VL_LOCS = FP_A_TOTAL_VL_LOCS + FP_A_time(1,1);
            plot(app.UIAxes,FP_A_TOTAL_PK_LOCS, FP_A_TOTAL_PEAKS, "Marker",".", "LineStyle","none");
            plot(app.UIAxes,FP_A_TOTAL_VL_LOCS, FP_A_TOTAL_VALLEYS, "Marker",".", "LineStyle","none");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "Treshold A", "Treshold B");  %BERK
            
            
            [FP_B_TOTAL_PEAKS, FP_B_TOTAL_PK_LOCS] = findpeaks(FP_B_TOTAL, 'MinPeakWidth', 50); %Bas
            invert_B_TOTAL = -FP_B_TOTAL;
            [FP_B_TOTAL_VALLEYS, FP_B_TOTAL_VL_LOCS] = findpeaks(invert_B_TOTAL, 'MinPeakWidth', 50); %Bas
            FP_B_TOTAL_VALLEYS = -FP_B_TOTAL_VALLEYS;
            FP_B_TOTAL_PK_LOCS = FP_B_TOTAL_PK_LOCS + FP_B_time(1,1);
            FP_B_TOTAL_VL_LOCS = FP_B_TOTAL_VL_LOCS + FP_B_time(1,1);
            plot(app.UIAxes2,FP_B_TOTAL_PK_LOCS, FP_B_TOTAL_PEAKS, "Marker",".", "LineStyle","none");
            plot(app.UIAxes2,FP_B_TOTAL_VL_LOCS, FP_B_TOTAL_VALLEYS, "Marker",".", "LineStyle","none");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "Treshold A", "Treshold B"); %BERK
        end

        % Button pushed function: SmoothAButton
        function SmoothAButtonPushed(app, event)
            global FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y WIDTH_FP LENGTH_FP
            FP_A_TOTAL = smoothdata(FP_A_TOTAL);
            ColumnselectADropDownValueChanged(app);
            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);
            plot(app.UIAxes3,CoP_A_X, CoP_A_Y);
        end

        % Button pushed function: SmoothBButton
        function SmoothBButtonPushed(app, event)
            global FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y WIDTH_FP LENGTH_FP
            FP_B_TOTAL = smoothdata(FP_B_TOTAL);
            ColumnselectBDropDownValueChanged(app);
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL);
            plot(app.UIAxes3_2,CoP_B_X, CoP_B_Y);
        end

        % Button pushed function: ResetdataAButton
        function ResetdataAButtonPushed(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL CoP_A_X CoP_A_Y signals WIDTH_FP LENGTH_FP;
            global tresholdA tresholdB Baseline1 %BERK
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
            %%%%%%%%%%%%%BERK%%%%%%%%%%%%%%%%%%%
            FPATOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;
            offsetA = min(FPATOTAL);
            FP_A_TOTAL = FPATOTAL - offsetA;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);

            hold(app.UIAxes, "off");
            plot(app.UIAxes,FP_A_time, FP_A_0);
            hold(app.UIAxes, "on");
            plot(app.UIAxes,FP_A_time, FP_A_1);
            plot(app.UIAxes,FP_A_time, FP_A_2);
            plot(app.UIAxes,FP_A_time, FP_A_3);
            plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
            %%%%%%%%%%BERK%%%%%%%%%%%%%
            plot(app.UIAxes,FP_A_time, tresholdA);
            plot(app.UIAxes,FP_A_time, tresholdB);
            plot(app.UIAxes,FP_A_time, Baseline1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "tresholdA", "tresholdB"); %BERK
            
            plot(app.UIAxes3,CoP_A_X, CoP_A_Y);
            xlabel(app.UIAxes3, "X[mm]");
            ylabel(app.UIAxes3, "Y[mm]"); 

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
            %%%%%%%%%%BERK%%%%%%%%%%%%
            FPBTOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            offsetB = min(FPBTOTAL);
            FP_B_TOTAL = FPBTOTAL - offsetB;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL); 
                        
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            %%%%%%%%%%BERK%%%%%%%%%%
            plot(app.UIAxes2,FP_B_time, tresholdA2);
            plot(app.UIAxes2,FP_B_time, tresholdB2);
            plot(app.UIAxes2,FP_B_time, Baseline2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM", "tresholdA", "tresholdB"); %BERK);
            
            plot(app.UIAxes3_2,CoP_B_X, CoP_B_Y);
            xlabel(app.UIAxes3_2, "X[mm]");
            ylabel(app.UIAxes3_2, "Y[mm]");
            
            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Callback function
        function SliderValueChanging(app, event)
            
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
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ForceplateProcessingtoolUIFigure and hide until all components are created
            app.ForceplateProcessingtoolUIFigure = uifigure('Visible', 'off');
            app.ForceplateProcessingtoolUIFigure.Position = [100 100 1405 840];
            app.ForceplateProcessingtoolUIFigure.Name = 'Forceplate Processing tool';

            % Create Menu
            app.Menu = uimenu(app.ForceplateProcessingtoolUIFigure);
            app.Menu.Text = 'Menu';

            % Create LoadfileMenu
            app.LoadfileMenu = uimenu(app.Menu);
            app.LoadfileMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadfileMenuSelected, true);
            app.LoadfileMenu.Text = 'Load file';

            % Create UIAxes
            app.UIAxes = uiaxes(app.ForceplateProcessingtoolUIFigure);
            title(app.UIAxes, 'Forces FP1')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [1 504 738 337];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.ForceplateProcessingtoolUIFigure);
            title(app.UIAxes2, 'Forces FP2')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [1 86 738 337];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.ForceplateProcessingtoolUIFigure);
            title(app.UIAxes3, 'CoP FP1')
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.Position = [738 500 342 341];

            % Create UIAxes3_2
            app.UIAxes3_2 = uiaxes(app.ForceplateProcessingtoolUIFigure);
            title(app.UIAxes3_2, 'CoP FP2')
            xlabel(app.UIAxes3_2, 'X')
            ylabel(app.UIAxes3_2, 'Y')
            app.UIAxes3_2.Position = [738 86 342 341];

            % Create UITable
            app.UITable = uitable(app.ForceplateProcessingtoolUIFigure);
            app.UITable.ColumnName = {'t[s]'; 'F'};
            app.UITable.RowName = {};
            app.UITable.Position = [1141 123 212 629];

            % Create ColumnselectADropDownLabel
            app.ColumnselectADropDownLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.ColumnselectADropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectADropDownLabel.Position = [43 460 93 22];
            app.ColumnselectADropDownLabel.Text = 'Column select A';

            % Create ColumnselectADropDown
            app.ColumnselectADropDown = uidropdown(app.ForceplateProcessingtoolUIFigure);
            app.ColumnselectADropDown.Items = {'1', '2', '3', '4', '1-4', 'SUM', 'ALL'};
            app.ColumnselectADropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectADropDownValueChanged, true);
            app.ColumnselectADropDown.Position = [151 460 100 22];
            app.ColumnselectADropDown.Value = 'ALL';

            % Create ColumnselectBDropDownLabel
            app.ColumnselectBDropDownLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.ColumnselectBDropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectBDropDownLabel.Position = [43 58 93 22];
            app.ColumnselectBDropDownLabel.Text = 'Column select B';

            % Create ColumnselectBDropDown
            app.ColumnselectBDropDown = uidropdown(app.ForceplateProcessingtoolUIFigure);
            app.ColumnselectBDropDown.Items = {'1', '2', '3', '4', '1-4', 'SUM', 'ALL'};
            app.ColumnselectBDropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectBDropDownValueChanged, true);
            app.ColumnselectBDropDown.Position = [151 58 100 22];
            app.ColumnselectBDropDown.Value = 'ALL';

            % Create DataselectDropDownLabel
            app.DataselectDropDownLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDownLabel.HorizontalAlignment = 'right';
            app.DataselectDropDownLabel.Position = [1170 794 66 22];
            app.DataselectDropDownLabel.Text = 'Data select';

            % Create DataselectDropDown
            app.DataselectDropDown = uidropdown(app.ForceplateProcessingtoolUIFigure);
            app.DataselectDropDown.Items = {'A0', 'A1', 'A2', 'A3', 'A_SUM', 'A_PEAKS', 'A_VALLEYS', 'B0', 'B1', 'B2', 'B3', 'B_SUM', 'B_PEAKS', 'B_VALLEYS'};
            app.DataselectDropDown.ValueChangedFcn = createCallbackFcn(app, @DataselectDropDownValueChanged, true);
            app.DataselectDropDown.Position = [1251 794 100 22];
            app.DataselectDropDown.Value = 'A0';

            % Create CalculatepeaksButton
            app.CalculatepeaksButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.CalculatepeaksButton.ButtonPushedFcn = createCallbackFcn(app, @CalculatepeaksButtonPushed, true);
            app.CalculatepeaksButton.Position = [1174 761 178 22];
            app.CalculatepeaksButton.Text = 'Calculate peaks';

            % Create SmoothAButton
            app.SmoothAButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.SmoothAButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothAButtonPushed, true);
            app.SmoothAButton.Position = [294 460 100 22];
            app.SmoothAButton.Text = 'Smooth A';

            % Create SmoothBButton
            app.SmoothBButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.SmoothBButton.ButtonPushedFcn = createCallbackFcn(app, @SmoothBButtonPushed, true);
            app.SmoothBButton.Position = [294 58 100 22];
            app.SmoothBButton.Text = 'Smooth B';

            % Create ResetdataAButton
            app.ResetdataAButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.ResetdataAButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataAButtonPushed, true);
            app.ResetdataAButton.Position = [151 434 100 22];
            app.ResetdataAButton.Text = 'Reset data A';

            % Create ResetdataBButton
            app.ResetdataBButton = uibutton(app.ForceplateProcessingtoolUIFigure, 'push');
            app.ResetdataBButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataBButtonPushed, true);
            app.ResetdataBButton.Position = [151 30 100 22];
            app.ResetdataBButton.Text = 'Reset data B';

            % Create TresholdASliderLabel
            app.TresholdASliderLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.TresholdASliderLabel.HorizontalAlignment = 'right';
            app.TresholdASliderLabel.Position = [473 471 63 22];
            app.TresholdASliderLabel.Text = 'Treshold A';

            % Create TresholdASlider
            app.TresholdASlider = uislider(app.ForceplateProcessingtoolUIFigure);
            app.TresholdASlider.Limits = [0 300];
            app.TresholdASlider.MajorTicks = [0 50 100 150 200 250 300];
            app.TresholdASlider.ValueChangedFcn = createCallbackFcn(app, @TresholdASliderValueChanged, true);
            app.TresholdASlider.Position = [547 490 162 3];
            app.TresholdASlider.Value = 150;

            % Create TresholdBSliderLabel
            app.TresholdBSliderLabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.TresholdBSliderLabel.HorizontalAlignment = 'right';
            app.TresholdBSliderLabel.Position = [473 434 63 22];
            app.TresholdBSliderLabel.Text = 'Treshold B';

            % Create TresholdBSlider
            app.TresholdBSlider = uislider(app.ForceplateProcessingtoolUIFigure);
            app.TresholdBSlider.Limits = [0 300];
            app.TresholdBSlider.ValueChangedFcn = createCallbackFcn(app, @TresholdBSliderValueChanged, true);
            app.TresholdBSlider.Position = [547 448 162 3];
            app.TresholdBSlider.Value = 20;

            % Create TresholdALabel
            app.TresholdALabel = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.TresholdALabel.HorizontalAlignment = 'right';
            app.TresholdALabel.Position = [492 72 63 22];
            app.TresholdALabel.Text = 'Treshold A';

            % Create TresholdASlider_2
            app.TresholdASlider_2 = uislider(app.ForceplateProcessingtoolUIFigure);
            app.TresholdASlider_2.Limits = [0 300];
            app.TresholdASlider_2.ValueChangedFcn = createCallbackFcn(app, @TresholdASlider_2ValueChanged, true);
            app.TresholdASlider_2.Position = [576 81 150 3];
            app.TresholdASlider_2.Value = 150;

            % Create TresholdBSlider_2Label
            app.TresholdBSlider_2Label = uilabel(app.ForceplateProcessingtoolUIFigure);
            app.TresholdBSlider_2Label.HorizontalAlignment = 'right';
            app.TresholdBSlider_2Label.Position = [493 30 63 22];
            app.TresholdBSlider_2Label.Text = 'Treshold B';

            % Create TresholdBSlider_2
            app.TresholdBSlider_2 = uislider(app.ForceplateProcessingtoolUIFigure);
            app.TresholdBSlider_2.Limits = [0 300];
            app.TresholdBSlider_2.ValueChangedFcn = createCallbackFcn(app, @TresholdBSlider_2ValueChanged, true);
            app.TresholdBSlider_2.Position = [577 39 150 3];
            app.TresholdBSlider_2.Value = 20;

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