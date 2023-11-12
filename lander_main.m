  % Nick Vessa - MECE 117 - 10/24/23
% Final Project
% Lunar Lander

% Current status - Lander falls but does not rotate and physics are kinda
% scuffed

clear,clc;

% configure the figure window 
scrsize = get(0,'ScreenSize');
% create figure window
% set resolution to 720p :D
figPos = [30, 50, 1280, 720];
global fig1
fig1 = figure("Position", figPos, 'Color', [0,0,0], 'Toolbar', 'None', 'KeyPressFcn', @keyDownListener, 'KeyReleaseFcn', @keyReleaseListener);

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


% total mass
global fuel t_mass lm_mass
t_mass = 15200; % kg
fuel = 8250; %kg
lm_mass = 6950; %kg

% thrust things 
global thrust_max
thrust_max = 400; 
% prev value was 47000 N

global R
R = 1.738*10^6;

% only 60% of max thrust is throttleable unless landing is aborted!
global prop_consump
%prop_consump = 3.28*10^-4; 
prop_consump = 50;

% initial conditions
global th alt horzVel vertVel throttle_frac
th = 55; %degW
alt = 700; %px - 2200m
%pixels to m conversion
% 700px = 2200m, 1px = 3.14m
horzVel = 47; %m/s
vertVel = -14; %m/s
throttle_frac = 0.1; % from 0-1

% SAFE LANDING CONSTRAINTS - everying must be within this level of error
global max_vert_vel max_horz_vel max_angle  
max_vert_vel = 3; %m/s
max_horz_vel = 1.5; %m/s
max_angle = 6; %deg

% init global variables!
global g xVals yVals
global angleBox vertvelBox massBox fuelBox horzvelBox altBox
global startButton optionButton
global gameHasStarted
global terrainHasGenerated

g = 1.62; %m/s^2 - value for the moon
global dt
dt = .05; % seconds

%% Start Game Code w/ Title Screen

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
    global g XPos YPos xVals yVals
    global angleBox horzvelBox vertvelBox massBox fuelBox altBox throttleBox
    global th alt horzVel vertVel throttle_frac fuel t_mass
    global startButton optionButton
    global terrainHasGenerated

    % init textboxes 
    altBox = uicontrol('Style','edit', 'String', num2str(alt), ...
        'Position', [1180, 350, 80, 30], 'Enable', 'inactive');
    angleBox = uicontrol('Style','edit', 'String', num2str(th), ...
        'Position', [1180, 400, 80, 30], 'Enable', 'inactive');
    vertvelBox = uicontrol('Style','edit', 'String', num2str(vertVel), ...
        'Position', [1180, 450, 80, 30], 'Enable', 'inactive');
    horzvelBox = uicontrol('Style','edit', 'String', num2str(horzVel), ...
        'Position', [1180, 500, 80, 30], 'Enable', 'inactive');
    massBox = uicontrol('Style','edit', 'String', num2str(t_mass), ...
        'Position', [1180, 550, 80, 30], 'Enable', 'inactive');
    fuelBox = uicontrol('Style','edit', 'String', num2str(fuel), ...
        'Position', [1180, 600, 80, 30], 'Enable', 'inactive');
    throttleBox = uicontrol('Style','edit', 'String', num2str(throttle_frac), ...
        'Position', [1180, 650, 80, 30], 'Enable', 'inactive');

    % init labels
    altLabel = uicontrol('Style', 'text', 'String', 'Altitude', 'Position', [1180, 375, 60, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    angleLabel = uicontrol('Style', 'text', 'String', 'Angle', 'Position', [1180, 425, 60, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    vertVelLabel = uicontrol('Style', 'text', 'String', 'Vertical Velocity', 'Position', [1180, 475, 100, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    horzVelLabel = uicontrol('Style', 'text', 'String', 'Horizontal Velocity', 'Position', [1180, 525, 100, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    massLabel = uicontrol('Style', 'text', 'String', 'Lander Mass', 'Position', [1180, 575, 100, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    fuelLabel = uicontrol('Style', 'text', 'String', 'Current Fuel Level', 'Position', [1180, 625, 100, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');
    throttleLabel = uicontrol('Style', 'text', 'String', 'Throttle Level', 'Position', [1180, 675, 100, 20], 'ForegroundColor', 'white', 'BackgroundColor', 'none');


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
    
    % define tolerance for collisions
    x_tol = 80;
    y_tol = 10;
    

    % main game loop?!?
    gameHasStarted = true;
    while gameHasStarted

        % run calc pos function here 
        CalcLEMPos();
        pause(.05)

        % still trying to work out collision shit
        %[ii, jj] = find(abs(yVals-YPos) < y_tol);
        %disp(ii)

        if YPos <= 100
            gameHasStarted = false;

        end
        
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
    xVals = [0:80:1280];
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

% basic draw and fill function - try polyshape for rotation?
function drawLEM()
    global Lander_Patch
    global LEM
    global XPos YPos
    % x coordinates on top, y coordinates on bottom - make sure 0,0 is
    % inside the ship
    LEMShape = [0, -3, -7, -8, -7, -5, -3, -2, 0, 0, 2, 0, 0, 2, 3, 5, 7, 8, 7, 3;...
               -3, -1, -3, -3, -3,  1,  2,  6, 6, 8, 9, 8, 6, 6, 2, 1,-3,-3,-3, -1 ];
    LEMScale = 5;
    LEM = LEMScale * LEMShape;
    
    % start lander in top left
    XPos = 20;
    YPos = 700;
    Lander_Patch = patch(LEM(1,:)+XPos, LEM(2,:)+YPos, 'w');

end

function CalcLEMPos()
    global g R XPos YPos dt
    global angleBox horzvelBox vertvelBox massBox fuelBox altBox throttleBox
    global th horzVel vertVel t_mass alt lm_mass fuel altitude throttle_frac thrust_max prop_consump
    global Lander_Patch
    global LEM

    % grab variables from text boxes
    th = str2num(angleBox.String);
    horzVel = str2num(horzvelBox.String);
    vertVel = str2num(vertvelBox.String);
    t_mass = str2num(massBox.String);
    fuel = str2num(fuelBox.String);
    altitude = str2num(altBox.String);
    throttle_frac = str2num(throttleBox.String);

    % calculate values here 
    az = ((throttle_frac*thrust_max*cosd(-th))/prop_consump) - (g-((vertVel^2)/(R+YPos)));
    ax = (((throttle_frac*thrust_max*sind(-th))/prop_consump));

    %omit fuel consumption rate calc?

    XPos = XPos + horzVel*dt; % times the time step?
    YPos = YPos + vertVel*dt;

    horzVel = horzVel + ax*dt;
    vertVel = vertVel + az*dt;



    fuel = fuel - prop_consump*dt; % times time STEP!!!!
    t_mass = lm_mass + fuel; % STILL NEED TIME STEP

    % rotation?
    RtnMtrx = [ cosd(-th), sind(-th); ...
                -sind(-th), cosd(-th)];
    LEM_R = RtnMtrx * LEM;

    set(Lander_Patch, 'XData', LEM_R(1,:)+XPos, 'YData', LEM_R(2,:)+YPos);

    % set values for boxes
    set(horzvelBox, 'String', num2str(horzVel));
    set(vertvelBox, 'String', num2str(vertVel));
    set(fuelBox, 'String', num2str(fuel));
    set(altBox, 'String',num2str(YPos));

end

% handle rotating in its own thing :D
% still need to workshop rotating
%{
function rotateLander()
    global XPos YPos LEM Lander_Patch th angleBox dt
    % set direction for rotating
    RtnMtrx = [ cosd(-th), sind(-th); ...
    -sind(-th), cosd(-th)];
    LEM_R = LEM * RtnMtrx;
    set(Lander_Patch, 'XData', LEM_R(1,:)+XPos, 'YData', LEM_R(2,:)+YPos)
    disp("rotate!")
    pause(dt)
    %rotate(LEM, th)

end
%}

% key listener
% would like to define something where while the key is released, increment
% goes back down
function keyDownListener(src, event)
    
    global keyID
    global angleBox throttleBox
    global th 
    global throttle_frac
    global XPos YPos
    global LEM Lander_Patch
    
    keyID = event.Key;
    % switch statement for handling keyinput and changing values 
    switch keyID
        case 'leftarrow'
            th = th + 1;
            set(angleBox, 'String', num2str(th));
            %rotateLander();
        case 'rightarrow'
            th = th - 1;
            set(angleBox, 'String', num2str(th));
            %rotateLander();
        case 'space'
            throttle_frac = throttle_frac + 0.05;
            set(throttleBox, 'String', num2str(throttle_frac));
            if throttle_frac > .59

                %disp("Max throttle reached")
                throttle_frac = .59;
                    
            end

    end

end

% to handle fun throttle functionality
function keyReleaseListener(~, event)

    global keyID
    global throttleBox
    global throttle_frac
        
    keyID = event.Key;

    switch keyID

        case 'space'
            throttle_frac = 0;
            set(throttleBox, 'String', num2str(throttle_frac));
    end

end



