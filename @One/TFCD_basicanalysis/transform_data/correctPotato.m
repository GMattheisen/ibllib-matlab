function [speedCorrected, speed] = correctPotato(inputs)
% number of ticks per revolution (take into account decoding mode)
ntpr = inputs.nticksperrotation ;
ticks = inputs.ticks;

% calculate speed
speed = [0; diff(ticks)];


% estimate phase of the wheel for every sample
wheelPhase = mod(ticks,ntpr)/ntpr;

% phase bins used for correction
phaseBins = [0:.04:1];
meanTicks = zeros(size(phaseBins,2)-1,1);
speedCorrected = speed;

% mean speed over whole session
meanSpeed = mean(speed);

for ind = 1:numel(phaseBins)-1
    % find samples that fall in this phase bin
    if ind<numel(phaseBins)-1
        binIdx = wheelPhase>=phaseBins(ind) & wheelPhase<phaseBins(ind+1);
    else
        binIdx = wheelPhase>=phaseBins(ind) & wheelPhase<=phaseBins(ind+1);
    end
    % mean speed in phase bin
    meanTicks(ind) = mean(speed(binIdx));
    % correct to mean for whole session
    speedCorrected(binIdx) = speedCorrected(binIdx) / meanTicks(ind) * meanSpeed;
end
if inputs.plot
% potato plot
meanTicks = [ meanTicks; meanTicks(1) ];
figure;polarplot(phaseBins*2*pi,meanTicks)
end
end