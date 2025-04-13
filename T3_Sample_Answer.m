% Sample Answer
% Module: BE2BMK
% Year: 2021/22
% Assessment: T03 Model Answer

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
opts = detectImportOptions ('Pelvis_Trajectories.csv','NumHeaderLines',4);
traj=readmatrix('Pelvis_Trajectories.csv',opts);

%% Set Constants - Taken from Breif
% Find Number of Frames
[f_max,~]=size(traj);

% Sampling frequencey is 100Hz
Freq=100;
t=(1:f_max)/Freq;

% Set Anthropomentric Parametres in m for Davis Hip Model
L_LL=0.990;
R_LL=0.985;
Leg_L=(L_LL+R_LL)/2;

% Set Marker Radius
R_mark=0.012;

%% Davis Hip Model

% Isolate Appropriate Markers
% ':' will call all rows in the specified collums
% '1:3' will call collums 1 to 3 in a specified rows
LASI=traj(:,1:3);
RASI=traj(:,4:6);
LPSI=traj(:,7:9);
RPSI=traj(:,10:12);

% Find Inter ASIS Distance
% 2 inside sum() function applies function to all rows in matrix
pelvic_w=LASI-RASI;
ASIS_Dist=sqrt(sum(pelvic_w.^2,2));

% Average value of entire trajectory for more acuracy
% /1000 to convert to m for Davis Hip model
ASIS_Dist=mean(ASIS_Dist)/1000;

% Anterior/Posterior leght of pelvis segment
X_dist=0.1288*Leg_L-0.04856;
C=Leg_L*0.115-0.0153;

% Values for Beta 18 & Theta 28.4 from Davis et al. 1991 study"
B=deg2rad(18);
T=deg2rad(28.4);

% Value in Pelvis local co-ord system
% *1000 to convert to mm to match data set
LHJC_L=[(C*sin(T)-0.5*ASIS_Dist);((-X_dist-R_mark)*cos(B)+(C*cos(T)*sin(B)));((-X_dist-R_mark)*sin(B)-(C*cos(T)*cos(B)))]*1000;
RHJC_L=[-(C*sin(T)-0.5*ASIS_Dist);((-X_dist-R_mark)*cos(B)+(C*cos(T)*sin(B)));((-X_dist-R_mark)*sin(B)-(C*cos(T)*cos(B)))]*1000;

% ************************************************************************
% ** NOTE3: it is possible to work fully in mm for this. If you opt for **
% ** this method, you will need to edit the equations for X_dist and C  **
% ** and convert the constants to mm instead of m.                      **
% ************************************************************************

% Form Translation from Pelvis Local co-ord system to Global co-ord system
pelvis_org=(RASI+LASI)/2;

% Form Rotation Matrix from Pelvis Local co-ord system to Global co-ord system
% Form j vector towards the Left Hand Side
% .' indicates a transpose
% 2 inside sum() function indcates function is applied across all collums
L1=RASI.'-pelvis_org.';
i=L1./sqrt(sum(L1.^2,1));

% Form 2nd Definging Line in the Anterior Direction
L2=pelvis_org.'-RPSI.';
L2=L2./sqrt(sum(L2.^2,1));

% Form k vector vertically
% 1 inside cross() function applies function to all collums in the matrix
k=cross(i,L2,1);
    
% Form j vector in the Anterior Direction
j=cross(k,i,1);

% ************************************************************************
% ** NOTE4: You need to form a rotation matrix for each frame of data.  **
% ** The loop below allows a translation vector and rotation matrix to  **
% ** be formed for each frame and stores them in as 3 dimensional arrays**
% ************************************************************************

for f=1:f_max
    % Form Rotation Matrix
    % Dimension 1 and 2 reference the 3x3 Rotation Matrix
    % Dimension 3 references the frame of the data set
    GRL(1:3,1:3,f)=[i(1:3,f),j(1:3,f),k(1:3,f)];
    
    % Transformation from Local co-ord system to Global co-ord system
    LHJC(1:3,f)=GRL(1:3,1:3,f)*LHJC_L+pelvis_org(f,1:3).';
    RHJC(1:3,f)=GRL(1:3,1:3,f)*RHJC_L+pelvis_org(f,1:3).';
end

%% Isolating marker 2D trajectories
LHJC=LHJC.';
RHJC=RHJC.';

%% Plot Segment in 3D

% Isolate, Y and Z coordinates for plotting
X=[LASI(:,1),RASI(:,1),LPSI(:,1),RPSI(:,1),LHJC(:,1),RHJC(:,1)];
Y=[LASI(:,2),RASI(:,2),LPSI(:,2),RPSI(:,2),LHJC(:,2),RHJC(:,2)];
Z=[LASI(:,3),RASI(:,3),LPSI(:,3),RPSI(:,3),LHJC(:,3),RHJC(:,3)];

% Plot as a 3D scatter
% Loop allows the figure to cycle through each frame
figure;
for f=1:f_max
scatter3(X(f,1:6),Y(f,1:6),Z(f,1:6))

% Specifies how long each frame is displayed for
% Using 1/Freq will run the animation in real time.
% Change "1" to another number to increase/decrease the animation speed
pause(1/Freq)

end