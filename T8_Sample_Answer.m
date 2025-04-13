% Sample Answer
% Module: BE2BMK
% Year: 2023/24
% Assessment: T08 Model Answer
% Assessor: Dr. Sokratis Komaris

% ************************************************************************
% ** NOTE1: If you use sections of this code in your project, you must  **
% ** acknowledgeit correctly. Failiure to do so may result in an        **
% ** academic a plagarism case with the University.                     **
% ************************************************************************

% ************************************************************************
% ** NOTE2: This code is written to process the full trajectory file.   **
% ************************************************************************

close all
clear

% Import data from supplied .zip file
opts = detectImportOptions ('Static_Trajectories.csv','NumHeaderLines',5);
traj=readmatrix('Static_Trajectories.csv',opts);

%Convert to m
traj=traj/1000;

% Import data from supplied .zip file
force=readmatrix('Static_Forces.csv',opts);

%% Isolate Data

% Identify all rows with subframe 0 from force data
ReSamp=find(force(:,2)==0);

% Isolate all subframe 0 rows from force data
FPC=force(ReSamp,21:23);
FP2=force(ReSamp,12:14);
COP2=force(ReSamp,18:20)/1000; % convert to m;
RTOE=traj(:,30:32);
RANK=traj(:,24:26);
RKNE=traj(:,15:17);

%% Set Constants
% Find Number of Frames
[f_max,~]=size(traj);

% Sampling frequencey is 100Hz for Trajectories
Freq=100;
t=(1:f_max)/Freq;

% Sampling frequencey is 1000Hz for Forces
Freq_f=1000;
t_f=(1:f_max)/Freq_f;


%% Segment Centre of Weight

% Bodyweight is estimated as the mean of Z componet of the combined force plates
BW=mean(force(:,23));

% Weight of foot calculated using Dempster Tables
W_f=-(0.145*BW);

% Weight of shank (leg) calculated using Dempster Tables
W_s=-(0.465*BW);

%% Postion of Segment of Mass

% Position of COM of the foot using Dempster Tables
COM_f=RANK+0.5*(RTOE-RANK);
COM_s=RKNE+0.433*(RANK-RKNE);

%% Reaction Forces & Moment for Ankle

% Convert from W to GRF
FP2=-FP2;

% Calulate F_ray, F_raz & M_ra See L)9a
F_ray=-FP2(:,2);
F_raz=W_f-FP2(:,3);
M_ra=W_f.*(RANK(:,2)-COM_f(:,2))-FP2(:,3).*(RANK(:,2)-COP2(:,2))+FP2(:,2).*(RANK(:,3)-COP2(:,3));

%% Reaction Forces & Moment for Knee

% Calulate F_rsy, F_rsz and M_rs See L)9a
F_rsy=F_ray;
F_rsz=W_s+F_raz;
M_rs=W_s.*(RKNE(:,2)-COM_s(:,2))-F_raz.*(RKNE(:,2)-RANK(:,2))+F_ray.*(RKNE(:,3)-RANK(:,3))+M_ra;




