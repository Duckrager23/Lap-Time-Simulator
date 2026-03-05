

from Car import Car

formula_car = Car(
    mass=798,          # F1 minimum weight with driver
    power=735000,      # ~735kw hybrid power unit
    CdA0=0.9,       
    induceddrag=0.05,  
    CL=-2.0,         # massive downforce
    Area=1.2,
    peaklateralg=1.6,  # F1 can pull 5-6g in corners
    load_transfer=0,
    
)

gt3_car = Car(
    mass=1300,         #typical GT3 BOP weight
    power=373000,      # ~500hp
    CdA0=0.8,
    induceddrag=0.04,
    CL=-1.0,            #decent aero but nothing like F1
    Area=1.8,
    peaklateralg=1.2,  # GT3 pulls around 2.5-3g
    load_transfer=0,
    
)

road_car = Car(
    mass=1600,         # average family/sports car
    power=150000,      # ~200hp
    CdA0=0.3,
    induceddrag=0.01,
    CL=-0.35,            # barely any downforce
    Area=2.2,
    peaklateralg=0.8,  # road tyres
    load_transfer=0,
    
)