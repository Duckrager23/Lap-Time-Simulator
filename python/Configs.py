from python.Car import Car
#Note these car configs are estimates
formula_car = Car(
    mass=798, #Kg
    power=735000, #~735kw hybrid power unit
    CdA0=0.9,       
    induceddrag=0.05,  
    CL=-2.0,
    Area=1.2,
    peaklateralg=2.0,
    load_transfer=0,
    
)

gt3_car = Car(
    mass=1300, #Kg
    power=373000, #~500hp
    CdA0=0.8,
    induceddrag=0.04,
    CL=-1.0,
    Area=1.8,
    peaklateralg=1.2,
    load_transfer=0,
    
)

road_car = Car(
    mass=1600, #Kg
    power=478000, #~641hp
    CdA0=0.3,
    induceddrag=0.01,
    CL=-0.35,
    Area=2.2,
    peaklateralg=0.8,
    load_transfer=0,
    
)