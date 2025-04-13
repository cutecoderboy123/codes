% Sample Answer
% Module: BE2BMK
% Year: 2021/22
% Assessment: T06 Data Processing
% Assessor: Dr. Sokratis Komaris

% ************************************************************************
% ** NOTE1: If you use sections of this code in your project, you must  **
% ** acknowledgeit correctly. Failiure to do so may result in an        **
% ** academic a plagarism case with the University.                     **
% ************************************************************************

close all
clear

% Import data from supplied .zip file
opts = detectImportOptions ('Accel_Right_Ankle.txt','NumHeaderLines',1);
accel=readmatrix('Accel_Right_Ankle.txt',opts);

%% Set Constants - Taken from Breif
% Find Number of Frames
[f_max,~]=size(accel);

% Sampling frequencey is 50Hz
freq=50;
time_step=1/freq;
t=(1:f_max)*time_step;


%% Filtering
% 4th order butterworth fitler with cut-off of 12Hz
order=4;
cut_off=12;
omega=cut_off/(freq/2);

% a& b are filter coefficients for the filter funtion
[a,b]=butter(order,omega);

% data is your trajectory data
% [] is default value for zi
% dim is the dimension you want to filter along
% data is in columns, therfore set to first dimeninsion
dim=1;
f_accel=filter(a,b,accel,[],dim);

%% Plot Filtered v Unfiltered

% Plot X Component
figure;
plot(t,accel(:,2))
title('Filtered v Unfiltered');
xlabel('time (s)');
ylabel('Acc_x (m/s^2)');
hold on
plot(t,f_accel(:,2))
hold off
legend('Raw Data','Filtered');

% Plot Y Component
figure;
plot(t,accel(:,3))
title('Filtered v Unfiltered');
xlabel('time (s)');
ylabel('Acc_y (m/s^2)');
hold on
plot(t,f_accel(:,3))
hold off
legend('Raw Data','Filtered');

% Plot Z Component
figure;
plot(t,accel(:,4))
title('Filtered v Unfiltered');
xlabel('time (s)');
ylabel('Acc_z (m/s^2)');
hold on
plot(t,f_accel(:,4))
hold off
legend('Raw Data','Filtered');

%% Identify Gait Events
% Find peaks used to identify spikes in data
% MinPeakHeight of 0.6 selected to isolate main peak
% Y component identified as vertical therfore, 3 column used
% 2nd output used to identify which frame peak occurs in
[~,initial_contact]=findpeaks(f_accel(:,3),'MinPeakHeight',0.6);

%% Split data into strides and plot on single graph
% Calculating number of steps
% This sets the end point on the for loop
[no_steps,]=size(initial_contact);

% 1 taken away to give number of steps rather than number of initial contacts
no_steps=no_steps-1;

% For loop allows this code to run for data sets with varying numbers of steps
% This is good practice for biomechanics as data will often have varying lenghts

% Starting figure outside the for loop allows an unknonw number of plots to be
% placed on the same figure using the for loop
figure;
for s=1:no_steps
    % Cell variable used here to store doubles of differing lengths
    strides{1,s}(:,:)=f_accel(initial_contact(s):initial_contact(s+1),2:4);
    
    % Stride lenght allows the a time vector that has a matched lenght with
    % the acceleration data to be used for plotting
    [stride_lenght,~]=size(strides{1,s}(:,:));
    
    % converts time axis to % of gait cycle
    gait_percentage=t(1:stride_lenght)/(stride_lenght*time_step)*100;
    
    % Plot strides on single graph
    plot(gait_percentage, strides{1,s}(:,2))
    hold on
end
title('Strides');
xlabel('% of Gait Cycle');
ylabel('Acc_z (m/s^2)');

hold off


