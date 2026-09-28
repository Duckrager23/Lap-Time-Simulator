function tyre = tyremodel(normalforce, slipangle, slipratio, tyretemp, tyrewear, gripcoefficient, velocity, cornerradius, mass)
%Find slip angle
slipanglefactor = minGrip + ...
    (1 - minGrip) * exp(-((slipangle - peakSlipAngle) / width)^2);
 
%Find slip ratio
slipratiofactor = minGrip + ...
    (1 - minGrip) * ...
    exp(-((slipRatio - peakSlipRatio) / width)^2);

%Find tyre temp
tempfactor = minGrip + ...
    (1 - minGrip) * ...
    exp(-((tyreTemp - optimalTemp) / tempWidth)^2);

% Wear factor
tyreWear = max(0, min(1, tyrewear));
wearfactor = 1 - 0.35 * tyreWear;

%Effective grip coefficient
effectivemu = gripcoefficient * slipanglefactor * slipratiofactor * tempfactor * wearfactor;
 
maxForce = normalForce * effectiveMu;

latForce = mass * velocity^2 / cornerRadius;

longForce = sqrt(max(0, maxForce^2 - latForce^2));

tyre.effectiveMu = effectivemu;
tyre.maxForce = maxforce;
tyre.latForce = latForce;
tyre.longForce = longForce;

tyre.slipAngleFactor = slipanglefactor;
tyre.slipRatioFactor = slipratiofactor;
tyre.tempFactor = tempfactor;
tyre.wearFactor = wearfactor;

end



 

  