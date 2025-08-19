
# Vehicle Dynamics
https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html

## Units

Everything should be in SI unless stated otherwise. Ex.: speed could/should be shown to player as Km/h or Mi/h. But all calculations will be at m/s.

The *Global* autload contains a definition for how many pixels are in a meter, which will be used troughout.	

## Physics Calculations
<!-- 
Forces must be set only at f_long(), f_lat() and f_yaw(). Everywhere else it should be read_only. Example: *f_rolling_resistance* will bet set at f_long() using calc_rolling_resistance().

### Fx = Flong

#### Força máxima

A força máxima aplicável aos pneus é determinada pela força que o carro faz no chão (e vice-versa):

> max(Fx) = u * Fz

Onde *u* é o coeficiente de fricção entre o pneu e o chão.

Se o a força longitudinal exceder esse limite o carro começa a derrapar e o coeficiente de fricção fica dinâmico e cai. -->


### Step 1: Inputs

- Gas

- Brake

- Gear

- Steering

### Step 2: Engine Produces Torque

calc_engine_torque()
	sets engine_torque_nm:float 

### Step 3: Transmission Changes Torque

calc_transmission_reduction(engine_torque_nm:float):
   returns transmission_torque_nm 

### Step 4: Differential distributes torque to the wheels

calc_differential_torque(transmission_torque_nm:float):
	returns [lw_torque_nm, rw_torque_nm]

### Step 5: Wheels

update_rotation(wheel_torque_nm, delta)
calc_longitudinal_froce() -> Vector2 # Force that the wheel applies on ground

### Step 6: Apply forces at chassi
apply_force_at_chassi(wheel_rotate)
