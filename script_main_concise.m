%% Rat Data BOLD EPHYS
tic
clear

%% Automate FilePath
if path_gtech > 0
    FilePath = '/home/hyunkoo/keilholz-lab/';
else
    FilePath = '/keilholz-lab/';
end

addpath(genpath(strcat(FilePath,'Hyunkoo/Research/GlobalCode/')));

addpath(genpath(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Code/')));

%% Create Project Name
Set.Type = 1;
typelist = {'Individual_NewHigherFreq_Thresh_v20'};

Set.Rat = [1:10]; %[1:10]; %[1:10]; %[1:10]; %[1:10]; %[1:10]; %[1,4,8,9];% [1:10]; %[1:2];

%% Create Readme for Project
fid = fopen(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Results/readme.txt'),'wt');
fprintf(fid, 'The following projects in order they were created \n');
fclose(fid);

%% Set Parameters for Project
Set.Simulation = 0;
Set.ParseData = 0;
Set.Initialize_New = 1;
Set.Initialize_Old = 0;
Set.ScanFirst = 0;
Set.Process = 1;
Set.Combine = 1;
Set.Figures_Correlation = 1;
Set.Save = 1;
Set.Figures_Anesthesia = 1;
Set.Anesthesia_Analysis = 1;
Set.Table = 0;
AnalyzeTime = 2;
Set.Figures_Result_HF = 1;
Set.Figures_ResultImages = 1;
Set.Figures_Result = 1;
Set.HypothesisTest = 1;
Set.Combine_Extra = 0; %Doesn't work for Rat 4 because has both Iso and Med
Set.Figures_Combine_Analysis = 0;
Set.test = 0;


%% Set Directory
Directory_RawData = strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/RawData/');
RatAllInfo_Init = struct('directory_rawdata',{strcat(Directory_RawData,'wp100611.2B1/'), strcat(Directory_RawData,'wp100625.2P1/'), strcat(Directory_RawData,'wp100911.451/'), strcat(Directory_RawData,'wp100912.461/'), strcat(Directory_RawData,'wp100923.4h1/'), strcat(Directory_RawData,'wp100924.4i1/'), strcat(Directory_RawData,'wp101001.4p1/'), strcat(Directory_RawData,'wp101002.4q1/'), strcat(Directory_RawData,'wp101007.4v1/'), strcat(Directory_RawData,'wp101008.4w1/'), strcat(Directory_RawData,'wp100611.2B1/')}, ...
    'directory_matdata_parent', strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/MatData/'), ...
    'directory_results_parent', strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Results/', typelist{Set.Type},'/'), ...
    'directory_analysis_parent', strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/'), ...
    'directory_analysis_combine', strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/Combined/'), ...
    'directory_analysis_all_parent',  strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/'), ...
    'num_subjects', 1, ...
    'frequency', {typelist{Set.Type}}, ...
    'ratNum', {1,2,3,4,5,6,7,8,9,10,11}, ...
    'scanlist', {[1:2,6:7],[1:8],[1:2],[1:3,11:15],[6:12],[5,8:9], [4:6,8,11],[1:4,6] ,[2:15], [3,5,7:9,11:12], [1]});

% Rat1 Scan 10 Problem with BOLD and EPHys not co-registered
% Rat7 All scans have no dc .mat files [4:18]
% Rat8 All scans have no dc .mat files [5:10]
% Rat9 Scans 6 missing dc .mat file Missing more than half
% Rat10 Scans Original [4:5,7:17]
% Rat10 Scan 8, 10 No results

%% Create Simulation
if Set.Simulation == 1;
    create_Simulation(RatAllInfo_Init, FilePath, 0);
end

%% Separate .mat file Raw Data
if Set.ParseData == 1;
    for RatNum = Set.Rat
        ratName = strcat('rat_data_',num2str(RatNum),'.mat');
        temp = load(strcat('/keilholz-lab/LabArchive/Garth/datafiles/datafiles/Wenju_first_10/Orig/',ratName));
        totalscan = size(temp.rat_data.data.ephys,1);
        for scanIndx = 1:totalscan
            rat_data.data.bold = {temp.rat_data.data.bold{scanIndx}};
            rat_data.data.ephys = {temp.rat_data.data.ephys{scanIndx}};
            rat_data.parameters.bold_tr = temp.rat_data.parameters.bold_tr(scanIndx);
            rat_data.parameters.scan_start = temp.rat_data.parameters.scan_start(scanIndx);
            rat_data.parameters.ephys_sampling_rate = temp.rat_data.parameters.ephys_sampling_rate(scanIndx);
            rat_data.parameters.anesthesia_start = temp.rat_data.parameters.anesthesia_start(scanIndx);
            rat_data.parameters.anesthesia_end = temp.rat_data.parameters.anesthesia_end(scanIndx);
            rat_data.parameters.spo2_start = temp.rat_data.parameters.spo2_start(scanIndx);
            rat_data.parameters.spo2_end = temp.rat_data.parameters.spo2_end(scanIndx);
            rat_data.parameters.heartrate_start = temp.rat_data.parameters.heartrate_start(scanIndx);
            rat_data.parameters.heartrate_end = temp.rat_data.parameters.heartrate_end(scanIndx);
            rat_data.parameters.breathrate_start = temp.rat_data.parameters.breathrate_start(scanIndx);
            rat_data.parameters.breathrate_end = temp.rat_data.parameters.breathrate_end(scanIndx);
            rat_data.parameters.temperature_start = temp.rat_data.parameters.temperature_start(scanIndx);
            rat_data.parameters.temperature_end = temp.rat_data.parameters.temperature_end(scanIndx);
            rat_data.data.roi = {temp.rat_data.data.roi{scanIndx}};
            if isfield(temp.rat_data.indices,'isoflurane') && ~isfield(temp.rat_data.indices,'medetomedine')
                rat_data.anesthesia = 'isoflurane';
            elseif ~isfield(temp.rat_data.indices,'isoflurane') && isfield(temp.rat_data.indices,'medetomedine')
                rat_data.anesthesia = 'medetomedine';
            elseif isfield(temp.rat_data.indices,'isoflurane') && isfield(temp.rat_data.indices,'medetomedine')
                if find(temp.rat_data.indices.isoflurane == scanIndx) > 0
                    rat_data.anesthesia = 'isoflurane';
                elseif find(temp.rat_data.indices.medetomedine == scanIndx) > 0
                    rat_data.anesthesia = 'medetomedine';
                end
            end
            
            save(strcat(RatAllInfo_Init(RatNum).directory_matdata_parent,'Rat',num2str(RatNum),'_scan',num2str(scanIndx)),'rat_data');
            clear rat_data;
        end
        fprintf(strcat('Rat',num2str(RatNum),'\n'))
    end
end
%% Rename Files

if Set.Initialize_New ==1
    for RatNum = Set.Rat; %[1:10]
        for ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            fprintf(strcat('Rat',num2str(RatNum),' ScanIndx',num2str(ScanIndx),'\n'))
            % Create Rat Datastructure
            if ScanIndx == 1
                RatAllInfo(RatNum) = script_InitializeNew(RatAllInfo_Init(RatNum), RatNum, ScanIndx);
            else
                RatAllInfo(RatNum) = script_InitializeNew(RatAllInfo(RatNum), RatNum, ScanIndx);
            end
        end
    end
    save(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'), 'RatAllInfo');
else
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process Data
if Set.Process == 1
    for RatNum = Set.Rat
        fprintf(strcat('Rat',num2str(RatNum),'\n'))
        parfor ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            
            % Set Parameters for Figures
            FigureParam.BOLD.TimeSec = 0.25:0.25:499.75;
            FigureParam.Show = 0;
            FigureParam.BOLD.TimeLabel = FigureParam.BOLD.TimeSec(1:5:250);
            FigureParam.BOLD.Selection = 1:5:250; %Choose 1st image, 5th image, etc to display
            FigureParam.BOLD.Row = 5;
            FigureParam.BOLD.Col = 10;
            FigureParam.Correlation.TimeLabel = -10:(0.25*5):10;
            % Preprocess
            [data_processed, Parameters, FigureParam, Skip] = script_Preprocess(RatAllInfo(RatNum), RatNum, ScanIndx, FigureParam, Set.Save, FilePath);
            if Skip == 0 % Continue if Ephys has appropriate number of data
                % Preprocess Higher Freq
                [data_processed_hf, data_processed] = script_Preprocess_HighFreq(data_processed, RatAllInfo(RatNum), RatNum, ScanIndx, Parameters, FigureParam, Set.Save, FilePath);
                % QPP Template
                [data_processed, Parameters, FigureParam] = script_QPPtemplate(data_processed, RatAllInfo(RatNum), RatNum, ScanIndx, Parameters, FigureParam, Set.Save);
                % Regression
                %[data_analysis, data_processed] = script_Regress(data_processed, RatAllInfo(RatNum), RatNum, ScanIndx, Parameters, Figure, Set.Save);
                [data_analysis, data_processed] = script_Regress_Alt(data_processed, RatAllInfo(RatNum), RatNum, ScanIndx, Parameters, FigureParam, Set.Save);
                % Correlation
                [data_analysis, data_processed, FigureParam] = script_Correlation(data_analysis,data_processed, data_processed_hf, RatAllInfo(RatNum), RatNum, ScanIndx, Parameters, FigureParam, Set.Save);
                fprintf(strcat('Finished Scan',num2str(ScanIndx),'\n'))
            else
                fprintf(strcat('Skpped Scan',num2str(ScanIndx),'\n'));
            end
            
        end
        %fid = fopen(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'readme.txt'),'wt');
        %fprintf(fid, strcat('Rat',num2str(RatAllInfo(RatNum).ratNum), ' scan ',num2str(RatAllInfo(RatNum).scan{ScanIndx}),'\n'));
        %fclose(fid);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Combine Results
if Set.Combine == 1
    count_iso = 1;
    count_med = 1;
    select_rat_iso = {};
    select_rat_med = {};
    for RatNum = Set.Rat
        for ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            
            load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
            check = exist(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results.mat'));
 
            %figure; imagesc(data_processed.QPP.betas)          
            
            if check > 0
                load(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results.mat'),'data_processed','data_analysis', 'Parameters');
                              
                data_analysis_combined.Time = data_analysis.Time;
                data_analysis_combined = ResultCombine(data_analysis, 'infraslow', data_analysis_combined, ScanIndx);
                data_analysis_combined = ResultCombine(data_analysis, 'theta', data_analysis_combined, ScanIndx);
                data_analysis_combined = ResultCombine(data_analysis, 'gamma', data_analysis_combined, ScanIndx);
                data_analysis_combined = ResultCombine(data_analysis, 'alpha', data_analysis_combined, ScanIndx);
                data_analysis_combined = ResultCombine(data_analysis, 'beta', data_analysis_combined, ScanIndx);
                data_analysis_combined = ResultCombine(data_analysis, 'delta', data_analysis_combined, ScanIndx);
                
                data_analysis_iso.Time = data_analysis.Time;
                data_analysis_med.Time = data_analysis.Time;
                if Parameters.anesthesia_index == 1 %&& betas_LeftROI > 6 && betas_RightROI > 6
                    data_analysis_iso = ResultCombine(data_analysis, 'infraslow', data_analysis_iso, count_iso);
                    data_analysis_iso = ResultCombine(data_analysis, 'delta', data_analysis_iso, count_iso);
                    data_analysis_iso = ResultCombine(data_analysis, 'theta', data_analysis_iso, count_iso);
                    data_analysis_iso = ResultCombine(data_analysis, 'gamma', data_analysis_iso, count_iso);
                    data_analysis_iso = ResultCombine(data_analysis, 'alpha', data_analysis_iso, count_iso);
                    data_analysis_iso = ResultCombine(data_analysis, 'beta', data_analysis_iso, count_iso);
                    select_rat_iso{count_iso} = strcat('Rat',num2str(RatNum),'ScanIndx',num2str(ScanIndx));
                    count_iso = count_iso + 1;                    
                elseif Parameters.anesthesia_index == 2 %&& betas_LeftROI > 10 && betas_RightROI > 10 
                    data_analysis_med = ResultCombine(data_analysis, 'infraslow', data_analysis_med, count_med);
                    data_analysis_med = ResultCombine(data_analysis, 'delta', data_analysis_med, count_med);
                    data_analysis_med = ResultCombine(data_analysis, 'theta', data_analysis_med, count_med);
                    data_analysis_med = ResultCombine(data_analysis, 'gamma', data_analysis_med, count_med);
                    data_analysis_med = ResultCombine(data_analysis, 'alpha', data_analysis_med, count_med);
                    data_analysis_med = ResultCombine(data_analysis, 'beta', data_analysis_med, count_med);
                    select_rat_med{count_med} = strcat('Rat',num2str(RatNum),'ScanIndx',num2str(ScanIndx));
                    count_med = count_med + 1;
                end
                
                
                display(strcat('Completed Combining results for Rat',num2str(RatAllInfo(RatNum).ratNum),'Scan',num2str(ScanIndx)));
            else
                fprintf(strcat('results does not exist for Scan', num2str(ScanIndx),'\n'))
            end
            
        end
        save(strcat(RatAllInfo(RatNum).directory_analysis_parent,'results_Combined.mat'),'data_analysis_combined')
        display(strcat('Saved Combining results for Rat',num2str(RatAllInfo(RatNum).ratNum)))
    end
    save(strcat(RatAllInfo(RatNum).directory_analysis_combine,'results_anesthesiaCombined.mat'),'data_analysis_iso', 'data_analysis_med')
    save(strcat(RatAllInfo(RatNum).directory_analysis_combine,'results_anesthesiaCombined_selected.mat'),'select_rat_iso','select_rat_med')
    display(strcat('Saved Combining Iso Med results'))
end

if Set.Figures_Anesthesia == 1
    RatNum = 1;
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
    script_SetFiguresAnesthesia(RatNum, FilePath, RatAllInfo);
end

if Set.Anesthesia_Analysis == 1
    RatNum = 1;
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
    script_SetAnesthesiaAnalysis(RatNum, FilePath, RatAllInfo);
end

if Set.HypothesisTest == 1
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
    %parfor RatNum = Set.Rat
    RatNum = 1;
    script_SetHypothesisTest(RatNum, FilePath, RatAllInfo);
    %end
end


if Set.Table == 1
    %% Plot Table
    for RatNum = Set.Rat
        load(strcat(RatAllInfo(RatNum).directory_analysis_all_parent,'RatAllInfo.mat'),'RatAllInfo');
        RatTable = script_Table(RatAllInfo, Set.Rat, AnalyzeTime);
    end
end


if Set.Figures_Correlation == 1
    %% Plot Figures
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
    parfor RatNum = Set.Rat
        script_SetFiguresCorrelation(RatNum, FilePath, RatAllInfo);
    end
end

if Set.Figures_ResultImages == 1
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'));
    for RatNum = Set.Rat
        parfor ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            script_SetFiguresResultsImages(RatNum, ScanIndx, FilePath, RatAllInfo);
        end
    end
end

if Set.Figures_Result == 1
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'));
    for RatNum = Set.Rat
        parfor ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            script_SetFiguresResults(RatNum, ScanIndx, FilePath, RatAllInfo);
        end
    end
end



if Set.Figures_Result_HF == 1
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'));
    for RatNum = Set.Rat
        parfor ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            script_SetFiguresResults_HF(RatNum, ScanIndx, FilePath, RatAllInfo);
        end
    end
end


if Set.Combine_Extra == 1
    for RatNum = Set.Rat
        load(strcat(RatAllInfo(RatNum).directory_analysis_parent,'results_Combined.mat'),'data_analysis_combined')
        for ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            ScanIndx
            load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
            check = exist(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results.mat'));
            if check > 0
                load(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results.mat'));
                load(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results_hf.mat'));
                
                
                data_analysis_combined.QPP.correlation(ScanIndx, :) = data_processed.QPP.correlation;
                
                [data_analysis_combined.QPP.template_LeftROI(ScanIndx, :), data_analysis_combined.QPP.template_RightROI(ScanIndx, :)] = func_ROI_Timeseries_Plot(squeeze(data_processed.QPP.template),Parameters.Electrode_ROI_Left,Parameters.Electrode_ROI_Right);
                data_analysis_combined.delta.ephys_filtered_LeftROI(ScanIndx, :) = data_processed_hf.delta_per(:,1);
                data_analysis_combined.theta.ephys_filtered_LeftROI(ScanIndx, :) = data_processed_hf.theta_per(:,1);
                data_analysis_combined.beta.ephys_filtered_LeftROI(ScanIndx, :) = data_processed_hf.beta_per(:,1);
                data_analysis_combined.alpha.ephys_filtered_LeftROI(ScanIndx, :) = data_processed_hf.alpha_per(:,1);
                data_analysis_combined.gamma.ephys_filtered_LeftROI(ScanIndx, :) = data_processed_hf.gamma_per(:,1);                               data_analysis_combined.theta.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.theta_per(:,2);
                data_analysis_combined.delta.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.delta_per(:,2);
                data_analysis_combined.theta.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.theta_per(:,2);
                data_analysis_combined.beta.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.beta_per(:,2);
                data_analysis_combined.alpha.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.alpha_per(:,2);
                data_analysis_combined.gamma.ephys_filtered_RightROI(ScanIndx, :) = data_processed_hf.gamma_per(:,2);
                
                [data_analysis_combined.bold.crop_LeftROI(ScanIndx, :), data_analysis_combined.bold.crop_RightROI(ScanIndx, :)] = func_ROI_Timeseries_Plot(squeeze(data_processed.bold.crop),Parameters.Electrode_ROI_Left,Parameters.Electrode_ROI_Right);
                [data_analysis_combined.bold.QPP_regressed_LeftROI(ScanIndx, :), data_analysis_combined.bold.QPP_regressed_RightROI(ScanIndx, :)] = func_ROI_Timeseries_Plot(squeeze(data_processed.bold.QPP_regressed),Parameters.Electrode_ROI_Left,Parameters.Electrode_ROI_Right);
                data_analysis_combined.infraslow.ephys_filtered_LeftROI(ScanIndx, :) = data_processed.ephys.crop(:,1);
                data_analysis_combined.infraslow.ephys_filtered_RightROI(ScanIndx, :) = data_processed.ephys.crop(:,2);
                
            end
        end
        save(strcat(RatAllInfo(RatNum).directory_analysis_parent,'results_Combined_Extra.mat'),'data_analysis_combined')
        display(strcat('Saved Combining results for Rat',num2str(RatAllInfo(RatNum).ratNum)))
        
    end
end



if Set.Figures_Combine_Analysis == 1
    load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/',  typelist{Set.Type},'/','RatAllInfo.mat'),'RatAllInfo');
    parfor RatNum = Set.Rat
        script_SetFiguresCombineAnalysis(RatNum, ScanIndx, FilePath, RatAllInfo);
    end
end




if Set.test == 1
    for RatNum = Set.Rat
        for ScanIndx = 1:length( RatAllInfo_Init(RatNum).scanlist)
            test = load(strcat(FilePath,'Hyunkoo/Research/Rat_BOLD_QPP/Analysis/', typelist{Set.Type},'/','RatAllInfo.mat'));
            RatAllInfo = test.RatAllInfo;
            test2 = load(strcat(RatAllInfo(RatNum).directory_results{ScanIndx},'results.mat'));
            
        end
    end
end

toc
