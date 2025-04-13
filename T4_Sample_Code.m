% Sample Answer
% Module: BE2BMK
% Year: 2024/25
% Assessment: T04 2D Joint Angles
% Assessor: Dr L Brayne

% ************************************************************************
% ** NOTE1: If you use sections of this code in your project, you must  **
% ** acknowledge it correctly. Failure to do so may result in an        **
% ** academic a plagiarism case with the University.                     **
% ************************************************************************

% ************************************************************************
% ** NOTE2: This code is written to process the full trajectory file.   **
% ************************************************************************

close all
clear

% Import data from supplied .zip file
opts = detectImportOptions ('Lower_Limb_Trajectories.csv','NumHeaderLines',4);
traj=readmatrix('Lower_Limb_Trajectories.csv',opts);
%% Set Constants - Taken from Brief
% Find Number of Frames
[f_max,~]=size(traj);

% Sampling frequency is 240Hz
Freq=240;
time_step=1/Freq;

% Define time series for angle and velocity plots
t=(1:f_max)*time_step;


%% Isolating marker 3D trajectories
LHIP=traj(:,1:3);
RHIP=traj(:,4:6);
LSHO=traj(:,7:9);
RSHO=traj(:,10:12);
LKNE=traj(:,13:15);
RKNE=traj(:,16:18);
LANK=traj(:,19:21);
RANK=traj(:,22:24);
LMTP=traj(:,25:27);
RMTP=traj(:,28:30);

%% Calculation of Segment Angles
for f=1:f_max

    % Note that column 2 represents Y coordinate and column 3 represent Z coordinate
    torso_ang(f)=rad2deg(atan2((RSHO(f,3)-RHIP(f,3)),(RSHO(f,2)-RHIP(f,2))));
    
    thigh_ang(f)=rad2deg(atan2((RHIP(f,3)-RKNE(f,3)),(RHIP(f,2)-RKNE(f,2))));
    
    shank_ang(f)=rad2deg(atan2((RKNE(f,3)-RANK(f,3)),(RKNE(f,2)-RANK(f,2))));
    
    % *********************************************************************
    % ** NOTE3: This  set is missing a heel marker so the ankle has been **
    % ** so the ankle has been used to calculate the foot angle instead. **
    % *********************************************************************
    
    foot_ang(f)=rad2deg(atan2(RANK(f,3)-RMTP(f,3),RANK(f,2)-RMTP(f,2)));
    
    
    %% Calculation of Joint Angles  
    hip_ang(f)=torso_ang(f)-thigh_ang(f);
    
    knee_ang(f)=(thigh_ang(f)-shank_ang(f));
  
    % *********************************************************************
    % ** NOTE4: The neutral point for the ankle is at 90deg so 90 has   **
    % ** has been subtracted to account for this.                        **
    % *********************************************************************
    
    ankle_ang(f)=shank_ang(f)-foot_ang(f)-90;
          
    
end

%% Plot Angles
f1=figure('Name', 'Joint Angles');
f1.Position = [0 50 450 900]; 


subplot(3,1,1)
plot(t,hip_ang)
title('Hip Angle');
xlabel('time (s)') ;
ylabel('\theta_H (deg)') ;

subplot(3,1,2)
plot(t,knee_ang)
title('Knee Angle');
xlabel('time (s)') ;
ylabel('\theta_K (deg)') ;

subplot(3,1,3)
plot(t,ankle_ang)
title('Ankle Angle');
xlabel('time (s)') ;
ylabel('\theta_A (deg)') ;




%% Calculation of Joint Angular Velocity - Numerical Differenciation
for f=1:f_max-1
    
    % Review notes on 
    hip_vel(f)=deg2rad(hip_ang(f+1)-hip_ang(f))/time_step;
    
    knee_vel(f)=deg2rad(knee_ang(f+1)-knee_ang(f))/time_step;
    
    ankle_vel(f)=deg2rad(ankle_ang(f+1)-ankle_ang(f))/time_step;

end

%% Plot Angular Velocities
f2=figure('Name', 'Joint Anglular Velocities');
f2.Position = [450 50 450 900];

subplot(3,1,1)
plot(t(1:end-1),hip_vel)
title('Hip Angular Velocity');
xlabel('time (s)') ;
ylabel('\omega_H (deg)') ;

subplot(3,1,2)
plot(t(1:end-1),knee_vel)
title('Knee Angular Velocity');
xlabel('time (s)') ;
ylabel('\omega_K (deg)') ;

subplot(3,1,3)
plot(t(1:end-1),ankle_vel)
title('Ankle Angular Velocity');
xlabel('time (s)') ;
ylabel('\omega_A (deg)') ;

%% Plot Segment in 3D

% Isolate, Y and Z coordinates for plotting
X=[LSHO(:,1),RSHO(:,1),LHIP(:,1),RHIP(:,1),LKNE(:,1),RKNE(:,1),LANK(:,1),RANK(:,1),LMTP(:,1),RMTP(:,1)];
Y=[LSHO(:,2),RSHO(:,2),LHIP(:,2),RHIP(:,2),LKNE(:,2),RKNE(:,2),LANK(:,2),RANK(:,2),LMTP(:,2),RMTP(:,2)];
Z=[LSHO(:,3),RSHO(:,3),LHIP(:,3),RHIP(:,3),LKNE(:,3),RKNE(:,3),LANK(:,3),RANK(:,3),LMTP(:,3),RMTP(:,3)];

% Plot as a 3D scatter
% Loop allows the figure to cycle through each frame
f3=figure('Name', 'Animated');
f3.Position = [900 50 600 900];

for f=1:f_max
       f3=scatter3(X(f,:),Y(f,:),Z(f,:));

% Specifies how long each frame is displayed for
% Using 1/Freq will run the animation in real time.
% Change "1" to another number to increase/decrease the animation speed
  
	pause(1/Freq);
	Animation(f)=getframe;

end



