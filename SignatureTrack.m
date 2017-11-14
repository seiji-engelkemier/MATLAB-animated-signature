function outtrack=SignatureTrack(inmat)

% SignatureTrack
% 
%   Main components of Signature Track are directly from Ralph Mettier's
%   Mousetrack from 2004, shared on MATLAB's File Exchange.
% 
%   Adapting Ralph Mettier's introduction:
%   """ 
%   SignatureTrack(X) returns a Mx2 tensor, which contains the x and y  
%   position of the mouse cursor during its motion over the selected image 
%   'inmat'. As adapted, SignatureTrack is designed to take any MxN matrix  
%   but not images.  
%   """
% 
%   Press any key to start tracking mouse (or pen) position. When done with
%   one continuous segment, press any key to stop tracking. Move mouse to  
%   new segment's starting location and repeat. Close figure when done.
% 
%   Comments:
%       I modified Ralph Mettier's script so the tracking is started and 
%       stopped by pressing any key as long as the MATLAB window is in 
%       focus. This way, someone can use a pen input without accidentally 
%       triggering the start/stop conditions.
%       Another edit is including real-time feedback (plotting) of mouse 
%       position using dots. For some reason, plotting a continuous line in 
%       (near) real-time produced a line offset from the actual mouse 
%       position.
%       Third edit disconnects different segments, so the animation will
%       look like normal handwriting.
% 
%       Since the original script was written in 2004, it could be updated 
%       to use dot notation but I left get() & set() as is because they 
%       still work.
% 
%   Edits by Seiji Engelkemier
%   Date: May 21st 2017


% Test if inmat is a valid input.
try
    imagefig=figure('units','normalized','position',[0.1 0.1 0.8 0.8]);
    imagesc(inmat)
%     Adjust purple and yellow color mapping of imagesc 
%     to black and white colormap.
    colormap(gray(2)) 
    set(gca,'ydir','normal');
catch
    close(imagefig)
    disp('Only NxM tensors, or NxMx3 RGB image data can be displayed as images')
end

% Clear userdata from root properties.
set(0,'userdata',[]);
% Press any key to start tracking.
set(imagefig,'WindowKeyPressFcn',{@starttrack,inmat}); 

% Condition satisfied when figure window is closed. Data is returned to
% Signature_capture_animation.m
waitfor(imagefig) 
outtrack=get(0,'userdata');
% -------------------------------------------------------------------------

function starttrack(imagefig,varargins,image)

disp('tracking started')

% Press any key to stop tracking.
% The following line clears user data from current figure (but not from root properties).
set(gcf,'WindowKeyPressFcn',{@stoptrack,image},'userdata',[]);

% Mouse movement activates motionfunction to capture mouse's position over
% the figure.
set(gcf,'windowbuttonmotionfcn',{@motionfunction, image});

%--------------------------------------------------------------------------

function motionfunction(imagefig,varargins,image)

% Append current mouse location to current trail of x,y points; save to 
% current figure's 'userdata' property.
set(gcf,'userdata',[get(gcf,'userdata');get(0,'pointerlocation')])

% This tracks the mouse location with dots to provide feedback to signer as 
% signature is written.
pt = get(gca,'CurrentPoint');
plot(pt(1,1),pt(1,2),'k.','MarkerSize',5)
ax = [0 length(image) 0 length(image)];
axis(ax);
hold on
drawnow

%--------------------------------------------------------------------------

function stoptrack(imagefig,varargins,image)

% Stop collecting data.
set(gcf,'windowbuttonmotionfcn',[]); 

disp('tracking stopped')

% This section saves the x,y points while adjusting for MATLAB
% figure and axis sizes.
    
    units0=get(0,'units');
    unitsf=get(gcf,'units');
    unitsa=get(gca,'units');

    set(0,'units','pixels');
    set(gcf,'units','pixels');
    set(gca,'units','pixels');

    x=get(gca,'xlim');
    y=get(gca,'ylim');
    axsize=get(gca,'position');
    figsize=get(gcf,'position'); 
    ratio=diag([diff(x)/axsize(3) diff(y)/axsize(4)]);
    shift=figsize(1:2)+axsize(1:2); 

    set(0,'units',units0);
    set(gcf,'units',unitsf);
    set(gca,'units',unitsa);

    % The variable to store the current segment's x,y points.
    mousetrail=(get(gcf,'userdata')-repmat(shift,size(get(gcf,'userdata'),1),1))*ratio;

% Check if there were any points stored already, if so append new mousetrail
% to previous data.
oldtrail = get(0,'userdata');
if isempty(oldtrail)
    % Pass 
else
    % Disconnect new segment from previous segment for plotting purposes.
    % Credit to JM for letting me know about the [nan nan] feature.
    mousetrail = [oldtrail;[nan nan];mousetrail];
end

% Save mousetrail to root properties. 
set(0,'userdata',mousetrail);
% Press any key to resume tracking.
set(gcf,'WindowKeyPressFcn',{@starttrack,image});