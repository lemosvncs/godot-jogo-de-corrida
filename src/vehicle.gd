extends Node2D
# 20px = 1m
# Vehicle characteristics
@export var engine_force:= 1000.0
@export var brake_force:float=10000.00
@export var mass = 100.0 # Kg
@export var front_axle_distance:float=7.0
@export var rear_axle_distance:float=14.0
var wheel_base = front_axle_distance + rear_axle_distance
var center_of_mass_height:float = 1 * 10 # 0.5m em pixels

## Physics
var G = Global.G
var vehicle_weight:float = mass * G # weight

## Constants
const c_air_drag:float=0.4257
const c_rolling_resistance:float=12.8

## Vehicle Dynamics
var velocity:Vector2=Vector2.ZERO
var speed:float
var front_weight:float
var rear_weight:float
var acc_vector:Vector2=Vector2.ZERO
var acceleration:float
# forces 
var f_drag:Vector2
var f_traction:Vector2
var f_rolling_res:Vector2
var f_brake:Vector2
var forces:Vector2
var previous_velocity = Vector2.ZERO
var current_velocity = Vector2.ZERO

# children
@onready var front_axle = $FrontWheels
@onready var rear_axle = $RearWheels
@onready var com_indicator = $COMIndicator

@onready var body_size = $BodySprite.texture.size

# HUD
@onready var hud = %VehicleHUD
@onready var hud_wf = %VehicleHUD/FrontWeight
@onready var hud_wr = %VehicleHUD/RearWeight

func _ready() -> void:
	# Setup the body
	front_axle.position.x = front_axle_distance
	rear_axle.position.x = -rear_axle_distance
	
	#front_axle_distance = front_axle.position.x - com_indicator.position.x
	#rear_axle_distance = rear_axle.position.x - com_indicator.position.x
	hud_wf.max_value = vehicle_weight
	hud_wr.max_value = vehicle_weight
	
	print(front_axle_distance)
	print(rear_axle_distance)
	
func _physics_process(delta: float) -> void:
	var direction:Vector2=transform.x
	


	
	#acceleration = sqrt(acc_vector.x * acc_vector.x + acc_vector.y * acc_vector.y)
	
	
	var brake = Input.get_action_strength("brake")
	var gas = Input.get_action_strength("gas")
	
	# EndHud
	
	#print("Body size: ", body_size.x)
	# (rear_axle_distance + front_axle_distance) = wheel base
	var weight_transfer = center_of_mass_height/wheel_base * mass * acceleration
	front_weight = front_axle_distance/wheel_base * vehicle_weight - weight_transfer
	rear_weight = rear_axle_distance/wheel_base * vehicle_weight + weight_transfer
	
	
	# Hud
	hud_wf.value = front_weight
	hud_wr.value = rear_weight
	
	# print(direction)
	# Longitudinal forces
	f_traction = direction * engine_force * gas
	
	if velocity.x > 0:
		f_brake = direction * brake_force * brake
	else:
		f_brake = Vector2.ZERO
		
	f_drag = -c_air_drag * velocity * (speed * speed)
	f_rolling_res = c_rolling_resistance * velocity
	forces = f_traction + f_drag + f_rolling_res - f_brake
	
	var acc = forces/mass
	previous_velocity = current_velocity
	velocity = velocity + delta * acc
	#speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
	speed = velocity.dot(direction.normalized())
	
	current_velocity = velocity
	
	acc_vector = (current_velocity - previous_velocity)/delta
	acceleration = acc_vector.dot(direction.normalized())
	
	position = position + delta * velocity
	
