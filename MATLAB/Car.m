classdef Car
    properties
        mass
        CdA0
        induceddrag
        CL
        Area
        power
        peaklateralg
        gripcoefficient
        load_transfer
    end

    methods
        % Car class initialisation
        function obj = Car(mass, CdA0, induceddrag, CL, Area, power, peaklateralg, load_transfer)
            obj.mass = mass;
            obj.CdA0 = CdA0;
            obj.induceddrag = induceddrag;
            obj.CL = CL;
            obj.Area = Area;
            obj.power = power;
            obj.peaklateralg = peaklateralg;
            obj.gripcoefficient = peaklateralg;
            obj.load_transfer = load_transfer;
        end

        % Calculates maximum acceleration force available from grip
        function accel = gripforceaccel(obj, normalforce)
            accel = (obj.gripcoefficient * normalforce) / obj.mass;
        end

        % Calculates downforce
        function df = downforce(obj, density, Velocity)
            df = 0.5 * density * Velocity * Velocity * obj.CL * obj.Area;
        end

        % Finds the max speed able to be achieved in a corner
        function Velocity = maxcornerspeed(obj, cornerradius, density, gravity)
            Velocity = sqrt(obj.gripcoefficient * gravity * cornerradius);

            for i = 1:5
                downforce_value = abs(0.5 * density * Velocity^2 * obj.CL * obj.Area);
                downforce_value = min(downforce_value, 2 * obj.mass * gravity);
                normalforce = obj.mass * gravity + downforce_value;
                Velocity = sqrt((obj.gripcoefficient * normalforce * cornerradius) / obj.mass);
            end
        end

        % Calculates how much time the car spends in the corner
        function time = cornertime(obj, cornerradius, arcofcorner, density, gravity)
            Velocity = obj.maxcornerspeed(cornerradius, density, gravity);
            time = arcofcorner / Velocity;
        end

        % Calculate the CdA used for drag
        function CdA = calculateCdA(obj)
            CdA = obj.CdA0 + obj.induceddrag * abs(obj.CL) * obj.Area;
        end

        % Calculates drag force
        function drag = dragforce(obj, Velocity, density, CdA)
            drag = 0.5 * density * Velocity * Velocity * CdA;
        end

        % Calculates acceleration from power
        function accel = poweracceleration(obj, velocity)
            velocity = max(velocity, 1.0);
            accel = obj.power / (obj.mass * velocity);
        end

        % Calculates actual acceleration considering drag, grip and downforce
        function Acc = actualacceleration(obj, Velocity, density, gravity)
            df = abs(obj.downforce(density, Velocity));
            normalforce_local = obj.mass * gravity + df;
            accel_grip = obj.gripforceaccel(normalforce_local);
            driveforce = obj.drive_force(Velocity);
            CdA = obj.calculateCdA();
            drag = obj.dragforce(Velocity, density, CdA);

            accel_power = max(0.0, (driveforce - drag) / obj.mass);
            Acc = min(accel_grip, accel_power);
        end

        % Calculates braking deceleration
        function decel = braking_decel(obj, Velocity, density, gravity, brake_g_limit)
            if nargin < 5
                brake_g_limit = 2.5;
            end

            downforce_value = abs(obj.downforce(density, Velocity));
            a_tyre = obj.gripcoefficient * ((obj.mass * gravity + downforce_value) / obj.mass);
            a_brake_cap = brake_g_limit * gravity;
            decel = min(a_tyre, a_brake_cap);
        end

        % Calculates braking distance
        function distance = brakingdistance(obj, Currentvelocity, Velocitytarget, A_brake)
            if Currentvelocity <= Velocitytarget
                distance = 0.0;
                return;
            end

            distance = (Currentvelocity^2 - Velocitytarget^2) / (2 * A_brake);
        end

        % The force pushing the car forward
        function force = drive_force(obj, velocity)
            max_speed = 100;

            if velocity >= max_speed
                force = 0.0;
                return;
            end

            velocity = max(velocity, 1.0);
            force = obj.power / velocity;
        end

        % Simulates straight line driving
        function [Velocity, time] = straight_time(obj, length, cornerradius, Velocitytarget, entryspeed, density, gravity, tick)
            if nargin < 8
                tick = 0.01;
            end

            Velocity = max(entryspeed, 0.0);

            if ~isempty(cornerradius)
                Velocitytarget = obj.maxcornerspeed(cornerradius, density, gravity);
            end

            x_pos = 0;
            time = 0;

            while x_pos < length
                if Velocity > Velocitytarget
                    A_brake = obj.braking_decel(Velocity, density, gravity);

                    if A_brake > 1e-6
                        brakingneeded = (Velocity * Velocity - Velocitytarget * Velocitytarget) / (2 * A_brake);
                    else
                        brakingneeded = inf;
                    end
                else
                    brakingneeded = 0.0;
                end

                remaining = length - x_pos;

                if brakingneeded >= remaining && Velocity > Velocitytarget
                    Acc = obj.braking_decel(Velocity, density, gravity) * -1;
                else
                    Acc = obj.actualacceleration(Velocity, density, gravity);
                end

                Velocity = max(0.0, Velocity + Acc * tick);
                x_pos = x_pos + Velocity * tick;
                time = time + tick;
            end
        end
    end
end