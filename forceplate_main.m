classdef forceplate_main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ForceplateProcessingtoolUIFigure  matlab.ui.Figure
        Menu                        matlab.ui.container.Menu
        LoadfileMenu                matlab.ui.container.Menu
        UITable                     matlab.ui.control.Table
        CalculatepeaksButton        matlab.ui.control.Button
        TabGroup                    matlab.ui.container.TabGroup
        Forceplates1and2Tab         matlab.ui.container.Tab
        UIAxes                      matlab.ui.control.UIAxes
        UIAxesCoP1                  matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxesCoP2                  matlab.ui.control.UIAxes
        SmoothAButton               matlab.ui.control.Button
        ResetdataAButton            matlab.ui.control.Button
        SmoothBButton               matlab.ui.control.Button
        ResetdataBButton            matlab.ui.control.Button
        SliderLabel                 matlab.ui.control.Label
        Slider                      matlab.ui.control.Slider
        ColumnselectADropDownLabel  matlab.ui.control.Label
        ColumnselectADropDown       matlab.ui.control.DropDown
        ColumnselectBDropDownLabel  matlab.ui.control.Label
        ColumnselectBDropDown       matlab.ui.control.DropDown
        SummedForceplatesTab        matlab.ui.container.Tab
        UIAxes3                     matlab.ui.control.UIAxes
        UIAxesCoP3                  matlab.ui.control.UIAxes
        DataselectDropDownLabel     matlab.ui.control.Label
        DataselectDropDown          matlab.ui.control.DropDown
    end

   

    % Callbacks that handle component events
    methods (Access = private)

        % Menu selected function: LoadfileMenu
        function LoadfileMenuSelected(app, event)
            global signals WIDTH_FP LENGTH_FP FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_A_TOTAL FP_B_TOTAL FP_TOTAL_ALL FP_TOTAL_time CoP_A_X CoP_A_Y CoP_B_X CoP_B_Y;
            [filename,path] = uigetfile('*.txt');  
            filepath = strcat(path,filename);     
            fID = fopen(filepath);
            datacell = textscan(fID,'%f%f%f%f%f%f%f%f%f%f%f%f', 'HeaderLines', 3, 'CollectOutput', 1);
            fclose(fID);
            signals = datacell{1};
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
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM");
            
            % Plot FP2 graph
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM");
            
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
            
            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Value changed function: ColumnselectADropDown
        function ColumnselectADropDownValueChanged(app, event)
            global FP_A_time FP_A_0 FP_A_1 FP_A_2 FP_A_3 FP_A_TOTAL;
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
                    legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM");
                otherwise
            end
            
        end

        % Value changed function: ColumnselectBDropDown
        function ColumnselectBDropDownValueChanged(app, event)
            global FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL;
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
                    legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM");
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
            
            [FP_A_TOTAL_PEAKS, FP_A_TOTAL_PK_LOCS] = findpeaks(FP_A_TOTAL);
            invert_A_TOTAL = -FP_A_TOTAL;
            [FP_A_TOTAL_VALLEYS, FP_A_TOTAL_VL_LOCS] = findpeaks(invert_A_TOTAL);
            FP_A_TOTAL_VALLEYS = -FP_A_TOTAL_VALLEYS;
            FP_A_TOTAL_PK_LOCS = FP_A_TOTAL_PK_LOCS + FP_A_time(1,1);
            FP_A_TOTAL_VL_LOCS = FP_A_TOTAL_VL_LOCS + FP_A_time(1,1);
            plot(app.UIAxes,FP_A_TOTAL_PK_LOCS, FP_A_TOTAL_PEAKS, "Marker",".", "LineStyle","none");
            plot(app.UIAxes,FP_A_TOTAL_VL_LOCS, FP_A_TOTAL_VALLEYS, "Marker",".", "LineStyle","none");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM", "FP A Peaks", "FP A Valleys");
            
            
            [FP_B_TOTAL_PEAKS, FP_B_TOTAL_PK_LOCS] = findpeaks(FP_B_TOTAL);
            invert_B_TOTAL = -FP_B_TOTAL;
            [FP_B_TOTAL_VALLEYS, FP_B_TOTAL_VL_LOCS] = findpeaks(invert_B_TOTAL);
            FP_B_TOTAL_VALLEYS = -FP_B_TOTAL_VALLEYS;
            FP_B_TOTAL_PK_LOCS = FP_B_TOTAL_PK_LOCS + FP_B_time(1,1);
            FP_B_TOTAL_VL_LOCS = FP_B_TOTAL_VL_LOCS + FP_B_time(1,1);
            plot(app.UIAxes2,FP_B_TOTAL_PK_LOCS, FP_B_TOTAL_PEAKS, "Marker",".", "LineStyle","none");
            plot(app.UIAxes2,FP_B_TOTAL_VL_LOCS, FP_B_TOTAL_VALLEYS, "Marker",".", "LineStyle","none");
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
            FP_A_TOTAL = FP_A_0 + FP_A_1 + FP_A_2 + FP_A_3;

            CoP_A_X = (WIDTH_FP/2).*((FP_A_1 + FP_A_2 - FP_A_1 - FP_A_3)./FP_A_TOTAL);
            CoP_A_Y = (LENGTH_FP/2).*((FP_A_0 + FP_A_1 - FP_A_2 - FP_A_3)./FP_A_TOTAL);

            hold(app.UIAxes, "off");
            plot(app.UIAxes,FP_A_time, FP_A_0);
            hold(app.UIAxes, "on");
            plot(app.UIAxes,FP_A_time, FP_A_1);
            plot(app.UIAxes,FP_A_time, FP_A_2);
            plot(app.UIAxes,FP_A_time, FP_A_3);
            plot(app.UIAxes,FP_A_time, FP_A_TOTAL);
            xlabel(app.UIAxes, "time[datapoints]");
            ylabel(app.UIAxes, "weight [kgf]");
            legend(app.UIAxes,"FP_A_0", "FP_A_1", "FP_A_2", "FP_A_3", "FP A SUM");
            
            plot(app.UIAxesCoP1,CoP_A_X, CoP_A_Y);
            xlabel(app.UIAxesCoP1, "X[mm]");
            ylabel(app.UIAxesCoP1, "Y[mm]"); 

            DataselectDropDownValueChanged(app);
            CalculatepeaksButtonPushed(app);
        end

        % Button pushed function: ResetdataBButton
        function ResetdataBButtonPushed(app, event)
            global FP_B_time FP_B_0 FP_B_1 FP_B_2 FP_B_3 FP_B_TOTAL CoP_B_X CoP_B_Y signals WIDTH_FP LENGTH_FP;
            
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
            FP_B_TOTAL = FP_B_0 + FP_B_1 + FP_B_2 + FP_B_3;
            CoP_B_X = (WIDTH_FP/2).*((FP_B_1 + FP_B_2 - FP_B_1 - FP_B_3)./FP_B_TOTAL);
            CoP_B_Y = (LENGTH_FP/2).*((FP_B_0 + FP_B_1 - FP_B_2 - FP_B_3)./FP_B_TOTAL); 
                        
            hold(app.UIAxes2, "off");
            plot(app.UIAxes2,FP_B_time, FP_B_0);
            hold(app.UIAxes2, "on");
            plot(app.UIAxes2,FP_B_time, FP_B_1);
            plot(app.UIAxes2,FP_B_time, FP_B_2);
            plot(app.UIAxes2,FP_B_time, FP_B_3);
            plot(app.UIAxes2,FP_B_time, FP_B_TOTAL);
            xlabel(app.UIAxes2, "time[datapoints]");
            ylabel(app.UIAxes2, "weight [kgf]");
            legend(app.UIAxes2,"FP_B_0", "FP_B_1", "FP_B_2", "FP_B_3", "FP B SUM");
            
            plot(app.UIAxesCoP2,CoP_B_X, CoP_B_Y);
            xlabel(app.UIAxesCoP2, "X[mm]");
            ylabel(app.UIAxesCoP2, "Y[mm]");
            
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
            app.SmoothAButton.Position = [276 456 100 22];
            app.SmoothAButton.Text = 'Smooth A';

            % Create ResetdataAButton
            app.ResetdataAButton = uibutton(app.Forceplates1and2Tab, 'push');
            app.ResetdataAButton.ButtonPushedFcn = createCallbackFcn(app, @ResetdataAButtonPushed, true);
            app.ResetdataAButton.Position = [133 419 100 22];
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

            % Create SliderLabel
            app.SliderLabel = uilabel(app.Forceplates1and2Tab);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.Position = [442 456 36 22];
            app.SliderLabel.Text = 'Slider';

            % Create Slider
            app.Slider = uislider(app.Forceplates1and2Tab);
            app.Slider.MajorTicks = [0 200 400 600 800 1000 1200 1400];
            app.Slider.Position = [487 465 162 3];

            % Create ColumnselectADropDownLabel
            app.ColumnselectADropDownLabel = uilabel(app.Forceplates1and2Tab);
            app.ColumnselectADropDownLabel.HorizontalAlignment = 'right';
            app.ColumnselectADropDownLabel.Position = [25 456 93 22];
            app.ColumnselectADropDownLabel.Text = 'Column select A';

            % Create ColumnselectADropDown
            app.ColumnselectADropDown = uidropdown(app.Forceplates1and2Tab);
            app.ColumnselectADropDown.Items = {'1', '2', '3', '4', '1-4', 'SUM', 'ALL'};
            app.ColumnselectADropDown.ValueChangedFcn = createCallbackFcn(app, @ColumnselectADropDownValueChanged, true);
            app.ColumnselectADropDown.Position = [133 456 100 22];
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