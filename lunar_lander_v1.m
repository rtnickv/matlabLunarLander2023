% Nick Vessa - MECE 117 - 10/24/23
% Final Project
% Lunar Lander

clear,clc;

% configure the figure window 
scrsize = get(0,'ScreenSize');
% create figure window
% set resolution to 720p :D
figPos = [30, 50, 1280, 720];
global fig1
fig1 = figure("Position", figPos, 'Color', [0,0,0], 'Toolbar', 'None');

% define axis limits - still need to change
xmax = 1280;
xmin = 0;
ymax = 720;
ymin = 0;

% set up axes
axis manual % Disable automatic axis scaling
axis equal % Set axis aspect ratio to 1
axis([xmin, xmax, ymin, ymax]) % Set axis limits
axis on % Do not display axis or

% axes background in figure


%% define constants!!

% height & width
h = 7; %m
w = 9.5; %m

% total mass
t_mass = 15200; % kg
prop_mass = 8250; %kg
lm_mass = 6950; %kg

% thrust things 
thrust_max = 47000; %N

% only 60% of max thrust is throttleable unless landing is aborted!
prop_consump = 3.28*(10^-4); 

% initial conditions
global init_angle init_alt init_horz_vel init_vert_vel
init_angle = 55; %deg
init_alt = 700; %px - 2200m
init_horz_vel = 150; %m/s
init_vert_vel = -44; %m/s

% SAFE LANDING CONSTRAINTS - everying must be within this level of error
global max_vert_vel max_horz_vel max_angle  
max_vert_vel = 3; %m/s
max_horz_vel = 1.5; %m/s
max_angle = 6; %deg

% init global variables!
global g
global angleBox velBox massBox fuelBox
global startButton optionButton
global gameHasStarted
global terrainHasGenerated

g = 1.62; %m/s^2 - value for the moon


%% Main Game Loop

%titleScreen();




%% Functions

% Title Screen

% add buttons for start and options!
startButton = uicontrol('Style', 'pushbutton', 'String', 'Start!', ...
    'Position', [1180, 250, 80, 30], ...
    'Callback', @Start);


optionButton = uicontrol('Style', 'pushbutton', 'String', 'Options', ...
    'Position', [1180, 200, 80, 30], ...
    'Callback', @options);


% draw black background, title, and loop for animating the background
bkg_rect = rectangle('Position', [0,0,1280,720],... 
    'FaceColor', 'black');



% loop for animating background
% init 'star' locations!
xvec = [20:20:1260];
yvec = [20:20:700];

numCols = length(xvec);
numRows = length(yvec);

gameHasStarted = false;

% init and draw, then figure out blinking lol



for rn = 1:numRows

    for cn = 1:numCols

        if ((mod(rn,2) ~= 0) && (mod(cn,2) ~= 0))
            global o_star
            o_star(cn,rn) = rectangle('Position', [xvec(cn), yvec(rn), 5, 5], 'FaceColor', 'w', 'Curvature', 1.0);

        else
            global e_star
            e_star(cn,rn) = rectangle('Position', [xvec(cn), yvec(rn), 5, 5], 'FaceColor', 'black', 'Curvature', 1.0);

        end
        

    end

end

% STILL ERRORS OUT, need to fix variable assignment things because it's
% broken! 
%{
for rn = 1:numRows


    if ((mod(rn,2) ~= 0) && (mod(cn,2) ~= 0))

        o_star(:,rn).FaceColor = 'w';
        pause(1)
        o_star(:,rn).FaceColor = 'k';


    else

        e_star(:,rn).FaceColor = 'k';
        pause(1)
        e_star(:,rn).FaceColor = 'w';
        
    end

        
    

end
%}

    % title?!?
drawing_title = true;

while drawing_title

        % define relative x and y
        relx = 450;
        rely= 450;

        width_const = 80;
    
        % draw the L
        x_l = [relx,relx,relx+50];
        y_l = [rely+80,rely, rely];
        line(x_l, y_l, 'Color', 'white');
    
        % move over 100 to make spacing consistent
        relx = relx + width_const;

        % draw the U
        x_u = [relx,  relx, relx+50, relx+50,];
        y_u = [rely+80, rely, rely, rely+80];
        line(x_u,y_u, 'Color', 'White')

        relx = relx + width_const;

        % draw the N
        x_n = [relx, relx, relx+50, relx+50];
        y_n = [rely, rely+80, rely, rely+80];
        line(x_n, y_n, 'Color', 'White');

        relx = relx + width_const;

        % draw the A - went simple and stylistic!
        x_a = [relx, relx+25, relx+50];
        y_a = [rely, rely+80, rely];
        line(x_a, y_a, 'Color', 'White');

        relx = relx + width_const;

        % draw the R - same deal as with the A
        x_r = [relx, relx, relx+50, relx+50, relx, relx+50];
        y_r = [rely, rely+80, rely+60, rely+40, rely+40, rely];
        line(x_r, y_r, 'Color', 'White');

        relx = relx+ width_const;

        % go to a new line, change relx and rely because lander is a longer
        % word
        relx = 410;
        rely = 320;

        % draw the next L!
        % draw the L
        x_l2 = [relx,relx,relx+50];
        y_l2 = [rely+80,rely, rely];
        line(x_l2, y_l2, 'Color', 'white');

        relx = relx + width_const;

        % draw the A
        x_a2 = [relx, relx+25, relx+50];
        y_a2 = [rely, rely+80, rely];
        line(x_a2, y_a2, 'Color', 'White');

        relx = relx + width_const;

        % draw the N
        x_n2 = [relx, relx, relx+50, relx+50];
        y_n2 = [rely, rely+80, rely, rely+80];
        line(x_n2, y_n2, 'Color', 'White');

        relx = relx + width_const;

        % draw the D!
        x_d = [relx, relx, relx+50, relx];
        y_d = [rely, rely+80, rely+40, rely];
        line(x_d, y_d, 'Color', 'White');

        relx = relx + width_const;

        % draw the E!
        x_e = [relx, relx+50, relx, relx, relx+50, relx, relx, relx+50];
        y_e = [rely, rely, rely, rely+40, rely+40, rely+40, rely+80, rely+80];
        line(x_e, y_e, 'Color', 'White');

        relx = relx + width_const;

        % draw the R!
        x_r2 = [relx, relx, relx+50, relx+50, relx, relx+50];
        y_r2 = [rely, rely+80, rely+60, rely+40, rely+40, rely];
        line(x_r2, y_r2, 'Color', 'White');

        drawing_title = false;

end

%eventually turn this into a loop
function Start(src, event)

    % reset from title screen!
    global gameHasStarted
    global g
    global angleBox velBox massBox fuelBox
    global startButton optionButton
    global terrainHasGenerated

    gameHasStarted = true;
    while gameHasStarted
        terrainHasGenerated = false;
        cla
        bkg_rect = rectangle('Position', [0,0,1280,720],... 
            'FaceColor', 'black');
    
        % generate terrain!
        generateTerrain();
        terrainHasGenerated = true;
        if terrainHasGenerated
            set(startButton, 'Enable', 'off')
        end
        drawLEM();
        % eventally will evaluate to a win/lose condition but is here now
        % in lieu of that
        gameHasStarted = false;
    end
end

% need to add an algorithm for terrain smoothing
function generateTerrain()

    % might need to access xVals and yVals so let's make them global
    global xVals
    global yVals
    global startButton
    global terrainHasGenerated
    
    % create series of points!
    xVals = [0:50:1280];
    yVals = [];
    num_pts_y = length(xVals);
    
    max_y = 400;

    for n = 1:num_pts_y

        yVals(n) = randi(max_y);

    end

    
    % PLATFORM SMOOTHING!!! 
    % iterate through list of y vals
    for b = 2:length(yVals)

        flat_tol = 50; %pixels

        % if values are within a 50 pixel tolerance, smooth them to a flat
        if (abs(yVals(b) - yVals(b-1))) <= flat_tol

            yVals(b) = yVals(b-1);

        end

    end

    line(xVals, yVals, 'Color', 'white')


end

% basic draw and fill function
function drawLEM()

    % x coordinates on top, y coordinates on bottom - make sure 0,0 is
    % inside the ship
    LEMShape = [0, -3, -7, -8, -7, -5, -3, -2, 0, 0, 2, 0, 0, 2, 3, 5, 7, 8, 7, 3;...
               -3, -1, -3, -3, -3,  1,  2,  6, 6, 8, 9, 8, 6, 6, 2, 1,-3,-3,-3, -1 ];
    LEMScale = 5;
    LEM = LEMScale * LEMShape;
    
    % center lander for now
    Xl = 1280/2;
    Yl = 700;

    Lander_Patch = patch(LEM(1,:)+Xl, LEM(2,:)+Yl, 'w');

end

function CalcLEMPos()
    global g
    global angleBox velBox massBox fuelBox

end
