# Lap-Time-Simulator
A physics-based Formula lap time simulation tool built in Python

## Overview
This program is a physics-based lap time calculator; it uses the set parameters of a car with physics formulas to calculate the time it would take said car to go around a track, all while approximating the racing line of the track as well. 

## How to run
**Dependencies:**
- Python 3
- NumPy
- Matplotlib

Install dependencies with:
```
pip install numpy matplotlib
```
or if that doesn't work use this instead
```
pip3 install numpy matplotlib
```

Simply download all files from the GitHub repo into the same folder and run `main.py` in a Python interpreter. You will be prompted to pick from a preset car configuration: F1, GT3, or road car. Parameters can be modified in `Configs.py`. The terminal will display your lap time along with additional data such as track length and downforce generated. You will then be prompted to view speeds for each track segment

## Project structure
- `main.py` - main simulation loop
- `Car.py` - Car class and physics methods
- `Configs.py` - car configurations
- `Trackdata.py` - Spa-Francorchamps track data
- `Constants.py` - physical constants

## Physics model
The physics model here essentially hinges on how different forces affect our grip as well as our velocity. Firstly, we must calculate our actual grip on the road surface. To do this, we must take the first downforce, normal force, and our car's grip/friction coefficient into account, using this we will be able to find if acceleration is added to this system, how much of the car's power is transferred into motion from the tires. These calculations are then coupled with the actual acceleration as well as subtracting the effects of drag to find how much our velocity variable is influenced. It's important to note that downforce does obviously scale with velocity. Secondly, in terms of the braking physics, it is essentially this in reverse; we use how much grip we are creating to minus our velocity by a certain amount when we are about to enter a corner.

Key Formulas:
Downforce = 0.5 × ρ × v² × CL × A
Drag = 0.5 × ρ × v² × CdA
Corner speed = √(μ × g × r)
Acceleration = min(power/velocity × mass, grip force / mass) - drag / mass




## Validated Results
| Car | Simulated | Real World | Difference |
|-----|-----------|------------|------------|
| Formula 1 | 1:43 | 1:41 | ~2% |
| GT3 | 2:34 | 2:20-2:30 | ~5% |
| Road Car (Porsche 992 Turbo S) | 3:07 | 3:00-3:15 | Within range |

> Note: A Porsche 992 Turbo S is used as the road car reference, as unlike Formula 1 and GT3, road car performance is not standardised.

> Note: The deviation from real-world results to simulated results is due to estimations on track dimensions as well as the simplification of the tyre model, but this gap will close as the model is improved.


## Car configurations
| Parameter | Formula Car | GT3 Car | Porsche 992 Turbo S |
|-----------|-------------|---------|---------------------|
| Mass (kg) | 798 | 1300 | 1600 |
| Power (kW) | 735 | 373 | 150 |
| CL | -2.0 | -1.0 | -0.35 |
| Peak Lateral G | 2.0 | 1.2 | 0.8 |
| CdA0 | 0.9 | 0.8 | 0.3 |

> Note: Car configurations are based on publicly available information as well as best estimates of parameters


## Known limitations and planned improvements
Although this program models key aspects of vehicle dynamics, there are still many limitations to this program. Firstly, due to the lack of real-world data, there are assumptions that we must make, such as having the grip coefficient equal the peak lateral forces of the car. Additionally, we assume the car keeps the same speed throughout the entire corner rather than changing at certain points of the corner. Secondly, the track segments themselves as well as the corner radii, are estimations, meaning unless better track data is obtained, this won't be 100% accurate. But there are also many ways to improve this model in the future, such as separating mechanical grip from aerodynamic grip. This will ultimately give us a more accurate depiction of how the car's velocity changes throughout corners. 
