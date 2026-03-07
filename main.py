from Constants import gravity
from Constants import density
from Trackdata import Trackname
from Trackdata import spa_track
from Car import Car
from Configs import formula_car, gt3_car, road_car

#Choose car
while True:
    car_choice = input("Choose car (f1/gt3/road): ").strip().lower()
    if car_choice == "f1":
        car = formula_car
        break
    elif car_choice == "gt3":
        car = gt3_car
        break
    elif car_choice == "road":
        car = road_car
        break
    else:
        print("Invalid choice, please enter f1, gt3 or road")

#Map out the track so that we are able to calculate the racing line
map_corner = 0
gripcoefficient = car.peaklateralg
map_straight = 0
segment_speeds = []
for name, seg_type, length, width, cornerradius, direction in spa_track:

    if seg_type == "corner":
        arcofcorner = length / cornerradius
        map_corner += (arcofcorner * cornerradius) * width
        Velocity = car.maxcornerspeed(cornerradius, density, gravity)
        downforce_value = abs(car.downforce(density, Velocity,))
        normalforce = car.mass * gravity + downforce_value + car.load_transfer
    else:
        map_straight += length * width 
        
        
#Initilise the racing line
spa_racing_line = []

#Calculate racing line through track data and map it relative to the track data giving us the racing line
for name, seg_type, length, width, radius, direction in spa_track:

    if seg_type == "straight":
        spa_racing_line.append(
            (name, seg_type, length, width, radius, 0)
        )

    else:
        outside = width / 2
        inside = -width / 2

        if direction == "R":
            entry_offset = -outside
            apex_offset  =  outside
            exit_offset  = -outside
        else:
            entry_offset =  outside
            apex_offset  = -outside
            exit_offset  =  outside

        spa_racing_line.append(
            (name+" entry", "corner", length*0.3, width, radius, entry_offset)
        )

        spa_racing_line.append(
            (name+" apex", "corner", length*0.4, width, radius, apex_offset)
        )

        spa_racing_line.append(
            (name+" exit", "corner", length*0.3, width, radius, exit_offset)
        )

#Lap time adder
laptime = 0.0
Velocity = 0.0

for i, (name, seg_type, length, width, radius, offset) in enumerate(spa_racing_line):
    
    if seg_type == "corner": #Calculate time spent in corner at max corner speed
        Velocitytarget = car.maxcornerspeed(radius, density,gravity)
        laptime += length / max(Velocitytarget, 0.1)
        Velocity = Velocitytarget
        if "entry" in name:
         clean_name = name.replace(" entry", "")
         segment_speeds.append((clean_name, "corner", Velocity))

    else:
        Velocitytarget = 0.0
        for j in range(i+1, len(spa_racing_line)):
            if spa_racing_line[j][1] == "corner":
                Velocitytarget = car.maxcornerspeed(spa_racing_line[j][4],density, gravity) #Look ahead to find next corner target speed
                break
                
        velocity, time = car.straight_time(length, radius, Velocitytarget, Velocity, density, gravity, tick=0.001)
        laptime += time
        Velocity = velocity
        segment_speeds.append((name, "straight", velocity))
total_length = 0.0
for _, _, length, _, _, _ in spa_track:
    total_length += length

#Average speed across the full lap
avg_lap_speed = total_length / laptime

#Input/output
print("Track name: ", Trackname)
print()
print("Car parameters: ")
print("Mass: ", car.mass, "Kg")
print("Power: ", car.power / 1000, "KW")
print()
print("Lap time:", round(laptime, 3), "Seconds")
print("Average lap speed:", round(avg_lap_speed, 0) * 3.6, "km/h")
print()
print("Downforce:", round(downforce_value/gravity, 3), "Kg","(",round(downforce_value, 3),")", "N" )
print("Normal force:", normalforce, "N")
print("Total length (m):", total_length)

seetime = input("Would you like to see segment time? Y|N ").strip().lower()

if seetime == "y":
    for name, seg_type, speed in segment_speeds:
        if seg_type == "straight":
            print(f"Straight {name}: {speed * 3.6:.2f} km/h")
        elif seg_type == "corner":
            print(f"Corner {name}: {speed * 3.6:.2f} km/h")