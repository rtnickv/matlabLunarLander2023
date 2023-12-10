% Nick Vessa - MECE 117- 12/5/2023
% Air Hockey?!?
% Yeah, air hockey!

clear, clc;

% init figure window
scrsize = get(0,'ScreenSize');
figPos = [30, 50, 500, 700];
fig1 = figure("Position", figPos, 'Color', [1,1,1], 'Toolbar', 'None', 'KeyPressFcn', @keyDownListener);

% define axis limits
xmax = 500;
xmin = 0;
ymax = 700;
ymin = 0;

% set up axes
axis manual % Disable automatic axis scaling
axis equal % Set axis aspect ratio to 1
axis([xmin, xmax, ymin, ymax]) % Set axis limits
axis on % Do not display axis or
hold on
% axes background in figure


% DEFINE CONSTANTS & GLOBAL VARIABLES
% X and Y for both blockers and the mousePos
global Xb1 Yb1 Xm Ym Xb2 Yb2 Xp Yp Xp2 Yp2 Vb1y Vb1x Vp1y Vp1x Vb1n Vb1s Vp1n Vp1s
global escapePressed
escapePressed = 0;
Xm = 0;
Ym = 0;

% create collision boolean :D
global didCollide
didCollide = false;


% DRAW SCREEN ELEMENTS
% Create blue walls
XBW = 0;
YBW = 0;
blueShape = [0, 0, 40, 40, 460, 460, 500, 500, 0; ...
            0, 350, 350, 40, 40, 350, 350, 0, 0];
bluePatch = patch(blueShape(1,:)+XBW, blueShape(2,:)+YBW, 'b');

% Create red walls
XRW = 0;
YRW = 0;
redShape = [0, 500, 500, 460, 460, 40, 40, 0, 0; ...
            700, 700, 350, 350, 660, 660, 350, 350, 700];
redPatch = patch(redShape(1,:)+XRW, redShape(2,:)+YRW, 'r');

% create user blocker, puck, and "AI" blocker
% set initial conditions
Xb1 = 250;
Yb1 = 150;
Xb2 = 250;
Yb2 = 550;
Xp = 250;
Yp = 350;
Vb1x = 1;
Vb1y = 1;
Vb2x = 1;
Vp1y = .1;
Vp1x = 0;

% puck direction variable?
global puckDir
puckDir = -1;
redBlockDir = 1;

% create objects 
% set radii for puck and blockers
rb = 30;
rp = 15;
theta = linspace(0, 2*pi, 181);

% blue blocker
XB1 = rb*sin(theta);
YB1 = rb*cos(theta);
blueBlocker = patch(XB1+Xb1, YB1+Yb1, 'b');


% red blocker
XR1 = rb*sin(theta);
YR1 = rb*cos(theta);
redBlocker = patch(XR1+Xb2, YR1+Yb2, 'r');


% puck
global XP YP
XP = rp*sin(theta);
YP = rp*cos(theta);
puck = patch(XP+Xp, YP+Yp, 'k');


% MAIN GAME LOOP
while ~escapePressed

    % have puck move initially
    Yp = Yp + Vp1y*puckDir;
    Xp = Xp + Vp1x*puckDir;

    % round values to make collisions easier
    Yp_r = round(Yp, 0);
    Xp_r = round(Xp, 0);

    % move red blocker back and forth!?!
    Xb2 = Xb2 + Vb2x*redBlockDir;
    if Xb2 >= 400

        redBlockDir = -1;

    elseif Xb2 <= 100

        redBlockDir = 1;

    end
    % update position for blockers and pucks
    set(redBlocker, 'XData', XR1+Xb2, 'YData', YR1+Yb2)
    set(puck, 'XData', XP+Xp, 'YData', YP+Yp)
    set(blueBlocker, 'XData', XB1+Xb1, 'YData', YB1+Yb1)
    % output variables for debug things
    %fprintf("Xp is %f and Yp is %f\n", Xp_r, Yp_r)
    %fprintf("Xb1 is %f and Yb1 is %f\n", Xb1, Yb1)
    % trying to get collisions working 
    % they sorta kinda work
    % each if statement compares the absolute value of the X and Y 
    % positions of the puck and blocker
    if (abs(Xp_r - Xb1) < rb) && (abs(Yp_r - Yb1) < rb)

        disp('collision')
        calcPuckPos(Xb1, Yb1)

    elseif (abs(Xp_r - Xb2) < rb) && (abs(Yp_r - Yb2) < rb)

        disp('collision')
        calcPuckPos(Xb2, Yb2)

    end

    % basic wall collision things
    % just switched puck direction based on whether it hits the right wall
    % or left wall
    if (abs(Xp_r - 460) < rp)

        puckDir = -1;

    elseif (abs(Xp_r - 40) < rp)

        puckDir = 1;

    end

    % same deal as above but with top and bottom walls
    if (abs(Yp_r - 660) < rp)

        puckDir = -1;

    elseif (abs(Yp_r - 40) < rp)

        puckDir = 1;

    end
    % pause to update graphics
    pause(0.001)
    


end


% FUNCTIONS
% having blockerX and blockerY as parameters allows for collisions for red
% and blue blockers
function calcPuckPos(blockerX, blockerY)

    % adjusted so puck is 1/5 the "mass" of blocker
    mp = .2; 
    mb = 1; 

    rb = 30;
    rp = 15;

    global Xb1 Yb1 Xb2 Yb2 Xp Yp Xp2 Yp2 Vb1 Vb1y Vb1x Vp1 Vp1y Vp1x Vb1n Vb1s Vp1n Vp1s
    global Vp2s Vp2n  puckDir

    % calculate angle between blocker and puck
    th = -atan2(blockerY - Yp, blockerX - Xp);
    alpha = atan2(Vb1y, Vb1x);
    beta = atan2(Vp1y, Vp1x);

    % the following calcs are from the PDF

    % define Vp1?
    Vp1 = sqrt(Vp1x^2 + Vp1y^2);
    Vb1 = sqrt(Vb1x^2 + Vb1y^2);

    % eliminate overlap prior to collision calculations
    Xp2 = blockerX - (rp + rb) * cos(th);
    Yp2 = blockerY + (rp + rb) * sin(th);

    % set to arbitrary values?
    Vb1n = Vb1 * cos(th + alpha);
    Vb1s = Vb1 * sin(th + alpha);

    Vp1n = Vp1 * cos(th + beta);
    Vp1s = Vp1 * sin(th + beta);

    Vp2s = Vp1s;
    
    P1n = mp * Vp1n + mb * Vb1n;
    % flip direction on collision
    if P1n < 0
        puckDir = 1;
    end

    KE1 = .5*mp*(Vp1^2) + .5*mb*(Vb1^2);

    a = (mp^2 + mp * mb)/mb;
    b = -(2*P1n*mp)/mb;
    c = ((P1n^2)/mb) + mp * Vp1s^2 + mb * Vb1s^2 - 2 * KE1;

    Vp2n = ((-b - sqrt(b^2-4*a*c))/2*a);

    % chose to omit blocker vel calcs
    % computing final speed of puck after collision

    Vp2 = sqrt(Vp2n^2 + Vp2s^2);
    beta2 = atan2(Vp2s, Vp2n) - th;

    Vp2x = Vp2*cos(beta2);
    Vp2y = Vp2*sin(beta2);

    Vp1y = Vp2y;
    Vp1x = Vp2x;

    Yp = Yp2 + Vp1y*puckDir;
    Xp = Xp2 + Vp1x*puckDir;

end


function keyDownListener(~, event)

    global KeyID escapePressed Xb1 Yb1
    KeyID = event.Key;
    
    switch KeyID

        case 'escape'
            escapePressed = 1;
        case 'uparrow'
            Yb1 = Yb1 + 5;
        case 'downarrow'
            Yb1 = Yb1 - 5;
        case 'leftarrow'
            Xb1 = Xb1 - 5;
        case 'rightarrow'
            Xb1 = Xb1 + 5;


    end


end
