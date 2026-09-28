import math
import numpy as np
import matplotlib.pyplot as plt

class Car:
    #Car class initialisation
    def __init__(self,mass,CdA0,induceddrag,CL,Area,power,peaklateralg,load_transfer,):
            self.mass = mass
            self.CdA0 = CdA0
            self.induceddrag = induceddrag #drag induced by generating downforce
            self.CL = CL#lift coeficient
            self.Area = Area #Area of aero 
            self.power = power  #watts (220 kw)
            self.peaklateralg = peaklateralg #Assumption of peak lateral g's
            self.gripcoefficient = peaklateralg
            self.load_transfer = load_transfer


    #Calculates maximum acceleration force available from grip
    def gripforceaccel(self, normalforce,):
        return (self.gripcoefficient *  normalforce) / self.mass

    #Calculates downforce
    def downforce(self,density, Velocity,):
        return (1/2 * density * Velocity * Velocity * self.CL * self.Area)

    #Finds the max speed able to be acheived in a corner considering the cars downforce and velocity
    def maxcornerspeed(self, cornerradius, density, gravity):
        Velocity = math.sqrt(self.gripcoefficient * gravity * cornerradius)
        for _ in range(5):
            downforce_value = abs(1/2 * density * Velocity **2 * self.CL * self.Area)
            downforce_value = min(downforce_value, 2 * self.mass * gravity)
            normalforce = self.mass * gravity + downforce_value
            Velocity = math.sqrt((self.gripcoefficient * normalforce * cornerradius) / self.mass)
        return Velocity
        
    #Calculates how much time the car spends in the corner
    def cornertime(self, cornerradius, arcofcorner, density,):
        Velocity = self.maxcornerspeed(cornerradius,density,)
        return arcofcorner / Velocity

    #Calculate the CdA which is used in the calculation for drag
    def calculateCdA(self,):
        return self.CdA0 + self.induceddrag * abs(self.CL) * self.Area
        
    #Calculates the force exerted onto the car by drag
    def dragforce(self, Velocity, density, CdA): 
        return 0.5 * density * Velocity * Velocity * CdA

    #Calculates how much acceleration the car can produce with the amount of power it has
    def poweracceleration(self,velocity):
        velocity = max(velocity, 1.0)
        return self.power / (self.mass * velocity)

    #Calculates how much acceleration is translated into velocity taking into account drag, grip and downforce
    def actualacceleration(self, Velocity, density, gravity):
        df = abs(self.downforce(density, Velocity,)) 
        normalforce_local = self.mass * gravity + df
        accel_grip = self.gripforceaccel(normalforce_local,)
        driveforce = self.drive_force(Velocity)
        CdA = self.calculateCdA()
        drag = self.dragforce(Velocity, density, CdA)
        
        accel_power = max(0.0, (driveforce - drag) / self.mass)
        return min(accel_grip, accel_power)
    
    #Calculates how much the braking before the corner influences the velocity
    def braking_decel(self, Velocity, density, gravity, brake_g_limit=2.5):
        downforce_value = abs(self.downforce(density, Velocity,))  # N
        a_tyre = self.gripcoefficient * ((self.mass * gravity + downforce_value) / self.mass)  # m/s^2
        a_brake_cap = brake_g_limit * gravity
        return min(a_tyre, a_brake_cap)

    #Calculates how much braking is needed for the corner
    def brakingdistance(self, Currentvelocity, Velocitytarget, A_brake):
            if Currentvelocity <= Velocitytarget:
                return 0.0
            return (Currentvelocity**2 - Velocitytarget**2) / (2 * A_brake)

    #The force pushing the car foward
    def drive_force(self, velocity):
     max_speed = 100  # m/s = 360 km/h
     if velocity >= max_speed:
        return 0.0
     velocity = max(velocity, 1.0)
     return self.power / velocity


    #Simulates straight line driving, balancing acceleration as well as braking to hit the corner entry speed
    def straight_time(self, length, cornerradius, Velocitytarget, entryspeed, density, gravity, tick=0.01):
        Velocity = max(entryspeed, 0.0)

        if cornerradius is not None:
            Velocitytarget = self.maxcornerspeed(cornerradius,density,gravity)

        x_pos = 0
        time = 0

        while x_pos < length:
            if Velocity > Velocitytarget:
                A_brake = self.braking_decel(Velocity, density,gravity)
                brakingneeded = (Velocity*Velocity - Velocitytarget*Velocitytarget) / (2 * A_brake) if A_brake > 1e-6 else float("inf")
            else:
                brakingneeded = 0.0
            remaining = length - x_pos

            if brakingneeded >= remaining and Velocity > Velocitytarget:
                Acc = self.braking_decel(Velocity, density,gravity) * -1
            else:
                Acc = self.actualacceleration(Velocity, density, gravity)
            Velocity = max(0.0, Velocity + Acc * tick)
            x_pos += Velocity * tick
            time += tick
        return Velocity, time


    pass