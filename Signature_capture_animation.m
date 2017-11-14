%% Introduction

% Final Project for 2.086 - Spring 2017, Professor Frey
% 
% Written by Seiji Engelkemier


%% Get Signature

close all

% Create blank NxN matrix as background for signature.
N = 10^3;
blank_slate = ones(N,N);

% Run script to input signature.
% Output is a two column array of [x y] points in the order that they were
% captured.
xy_pts = SignatureTrack(blank_slate);


%% Animate signature

% Play back the animation of the signature twice.
figure
for t = 1:2
    clf
    h = animatedline;
    axis([0 N 0 N])
    title('Animated Signature')
    for i = 2:length(xy_pts)
        addpoints(h,xy_pts([i-1 i],1),xy_pts([i-1 i],2))
        hold on
        drawnow
    end
    pause(1)
end
