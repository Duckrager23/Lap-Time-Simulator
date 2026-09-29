clc;
clear;

%% Constants
gravity = 9.81;
density = 1.225;

%% Load car configs and track data
Configs;
Trackdata;

%% Choose car
while true
    car_choice = lower(strtrim(input("Choose car (f1/gt3/road): ", "s")));

    if car_choice == "f1"
        car = formula_car;
        break;
    elseif car_choice == "gt3"
        car = gt3_car;
        break;
    elseif car_choice == "road"
        car = road_car;
        break;
    else
        disp("Invalid choice, please enter f1, gt3 or road");
    end
end

%% Map out the track
map_corner = 0;
gripcoefficient = car.peaklateralg;
map_straight = 0;
segment_speeds = {};

for i = 1:length(spa_track)

    name = spa_track(i).name;
    seg_type = spa_track(i).type;
    length_value = spa_track(i).length;
    width = spa_track(i).width;
    cornerradius = spa_track(i).radius;
    direction = spa_track(i).direction;

    if seg_type == "corner"
        arcofcorner = length_value / cornerradius;
        map_corner = map_corner + (arcofcorner * cornerradius) * width;

        Velocity = car.maxcornerspeed(cornerradius, density, gravity);
        downforce_value = abs(car.downforce(density, Velocity));
        normalforce = car.mass * gravity + downforce_value + car.load_transfer;
    else
        map_straight = map_straight + length_value * width;
    end
end

%% Initialise racing line
spa_racing_line = struct( ...
    'name', {}, ...
    'type', {}, ...
    'length', {}, ...
    'width', {}, ...
    'radius', {}, ...
    'offset', {} ...
);

%% Calculate racing line
for i = 1:length(spa_track)

    name = spa_track(i).name;
    seg_type = spa_track(i).type;
    length_value = spa_track(i).length;
    width = spa_track(i).width;
    radius = spa_track(i).radius;
    direction = spa_track(i).direction;

    if seg_type == "straight"

        spa_racing_line(end + 1) = struct( ...
            'name', name, ...
            'type', seg_type, ...
            'length', length_value, ...
            'width', width, ...
            'radius', radius, ...
            'offset', 0 ...
        );

    else
        outside = width / 2;

        if direction == "R"
            entry_offset = -outside;
            apex_offset = outside;
            exit_offset = -outside;
        else
            entry_offset = outside;
            apex_offset = -outside;
            exit_offset = outside;
        end

        spa_racing_line(end + 1) = struct( ...
            'name', name + " entry", ...
            'type', "corner", ...
            'length', length_value * 0.3, ...
            'width', width, ...
            'radius', radius, ...
            'offset', entry_offset ...
        );

        spa_racing_line(end + 1) = struct( ...
            'name', name + " apex", ...
            'type', "corner", ...
            'length', length_value * 0.4, ...
            'width', width, ...
            'radius', radius, ...
            'offset', apex_offset ...
        );

        spa_racing_line(end + 1) = struct( ...
            'name', name + " exit", ...
            'type', "corner", ...
            'length', length_value * 0.3, ...
            'width', width, ...
            'radius', radius, ...
            'offset', exit_offset ...
        );
    end
end

%% Lap time adder
laptime = 0.0;
Velocity = 0.0;

distance_travelled = 0.0;
plot_distance = 0;
plot_speed = 0;

for i = 1:length(spa_racing_line)

    name = spa_racing_line(i).name;
    seg_type = spa_racing_line(i).type;
    length_value = spa_racing_line(i).length;
    radius = spa_racing_line(i).radius;

    if seg_type == "corner"

        Velocitytarget = car.maxcornerspeed(radius, density, gravity);
        laptime = laptime + length_value / max(Velocitytarget, 0.1);
        Velocity = Velocitytarget;

        distance_travelled = distance_travelled + length_value;

        plot_distance(end + 1) = distance_travelled;
        plot_speed(end + 1) = Velocity;

        if contains(name, "entry")
            clean_name = erase(name, " entry");
            segment_speeds(end + 1, :) = {clean_name, "corner", Velocity};
        end

    else
        Velocitytarget = 0.0;

        for j = i + 1:length(spa_racing_line)
            if spa_racing_line(j).type == "corner"
                Velocitytarget = car.maxcornerspeed(spa_racing_line(j).radius, density, gravity);
                break;
            end
        end

        [velocity, time] = car.straight_time(length_value, radius, Velocitytarget, Velocity, density, gravity, 0.001);

        laptime = laptime + time;
        Velocity = velocity;

        distance_travelled = distance_travelled + length_value;

        plot_distance(end + 1) = distance_travelled;
        plot_speed(end + 1) = Velocity;

        segment_speeds(end + 1, :) = {name, "straight", velocity};
    end
end

%% Total track length
total_length = 0.0;

for i = 1:length(spa_track)
    total_length = total_length + spa_track(i).length;
end

%% Average speed
avg_lap_speed = total_length / laptime;

%% Input/output
disp("Track name: " + Trackname);
disp(" ");
disp("Car parameters: ");
disp("Mass: " + car.mass + " Kg");
disp("Power: " + car.power / 1000 + " KW");
disp(" ");
disp("Lap time: " + round(laptime, 3) + " Seconds");
disp("Average lap speed: " + round(avg_lap_speed * 3.6, 0) + " km/h");
disp(" ");
disp("Downforce: " + round(downforce_value / gravity, 3) + " Kg (" + round(downforce_value, 3) + ") N");
disp("Normal force: " + normalforce + " N");
disp("Total length (m): " + total_length);

seetime = lower(strtrim(input("Would you like to see segment time? Y|N ", "s")));

if seetime == "y"
    for i = 1:size(segment_speeds, 1)

        name = segment_speeds{i, 1};
        seg_type = segment_speeds{i, 2};
        speed = segment_speeds{i, 3};

        if seg_type == "straight"
            fprintf("Straight %s: %.2f km/h\n", name, speed * 3.6);
        elseif seg_type == "corner"
            fprintf("Corner %s: %.2f km/h\n", name, speed * 3.6);
        end
    end
end

%% Plot speed profile
figure;

plot(plot_distance, plot_speed * 3.6, 'LineWidth', 1.5);

xlabel('Distance around track (m)');
ylabel('Speed (km/h)');
title('Simulated Speed Profile - Spa-Francorchamps');

grid on;
