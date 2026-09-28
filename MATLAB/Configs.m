% Note these car configs are estimates

formula_car = Car( ...
    798, ...      % mass, kg
    0.9, ...      % CdA0
    0.05, ...     % induceddrag
    -2.0, ...     % CL
    1.2, ...      % Area
    735000, ...   % power, watts
    2.0, ...      % peaklateralg
    0 ...         % load_transfer
    );

gt3_car = Car( ...
    1300, ...     % mass, kg
    0.8, ...      % CdA0
    0.04, ...     % induceddrag
    -1.0, ...     % CL
    1.8, ...      % Area
    373000, ...   % power, watts
    1.2, ...      % peaklateralg
    0 ...         % load_transfer
    );

road_car = Car( ...
    1600, ...     % mass, kg
    0.3, ...      % CdA0
    0.01, ...     % induceddrag
    -0.35, ...    % CL
    2.2, ...      % Area
    478000, ...   % power, watts
    0.8, ...      % peaklateralg
    0 ...         % load_transfer
    );