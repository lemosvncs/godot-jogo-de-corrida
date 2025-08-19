extends Node2D
# 20px = 1m
# Vehicle characteristics
@export var conf = {
	"transmission_efficiency":1,
	"drive_efficiency":1,
	"wheel_radius": 0.3,
	"front_axle_distance": 0.5,
	"rear_axle_distance": 0.7,
	"mass": 1500,
	"frontal_area": 1,
	"friction_coef":0.3, # Coeficiente para um coverte
	"static_coef_fric_tire_ground": 0.4,
}
@export var engine_force:= 1000.0
@export var brake_force:float=10000.00
#@export var front_axle_distance:float= 1.1 * Global.PIXEL_METER
#@export var rear_axle_distance:float= 0.9 * Global.PIXEL_METER
var wheel_base = conf["front_axle_distance"] + conf["rear_axle_distance"]
var center_of_mass_height:float = 0.5 * Global.PIXEL_METER # 0.5m em pixels

## Physics
var G = Global.G
#var vehicle_weight:float

## Constants
const c_air_drag:float=0.4257
const c_rolling_resistance:float=12.8

## Vehicle Dynamics
var velocity:Vector2=Vector2.ZERO
var acc:Vector2=Vector2.ZERO
var speed:float
var front_weight:float
var rear_weight:float
var acc_vector:Vector2=Vector2.ZERO
var acceleration:float

# forces 
var f_long:Vector2
var f_lat:Vector2
var f_yaw:Vector2

var f_drag:Vector2
var f_traction:Vector2
var f_rolling_resistance:Vector2
var f_brake:Vector2

var f_max_traction:Vector2

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
@onready var hud_wf = %VehicleHUD/Weight/FrontWeight
@onready var hud_wr = %VehicleHUD/Weight/RearWeight
@onready var hud_wf_label = %VehicleHUD/Weight/FrontWeightLabel
@onready var hud_wr_label = %VehicleHUD/Weight/RearWeightLabel
@onready var speedometer = %Speedometer

#class VehicleEngine:
	#var rpm:float
	#var torque:float
	
func get_engine_torque_at_rpm(rpm:float, gear:int):
	match gear:
		1:
			if rpm > 0.0  and rpm <= 2000.0:
				return -(rpm**2)/1000 + 2*rpm + 3000
		2:
			if 1400.0 < rpm  and rpm < 4000.0:
				return -((rpm + 2000)**2)/1000 + 9.1*rpm + 500
		3:
			if 3800.0 < rpm  and rpm < 7000.0:
				return -((0.5 * rpm + 500)**2)/3000 + rpm -700

func get_gear_ratio(gear:int):
	match gear:
		1:
			return 2.66
		2:
			return 1.78
		3:
			return 1.30

func get_engine_drive_force(rpm:float, 
	gear:int,
	transmission_efficience:float=0.7,
	differential_ratio:float=3.42,
	):
	var torque = get_engine_torque_at_rpm(rpm, gear)
	return torque * get_gear_ratio(gear) * differential_ratio * transmission_efficience

func set_f_long(dir:Vector2, velocity:Vector2):
	f_max_traction = conf["mass"] * G * conf["static_coef_fric_tire_ground"] * dir
	
	f_rolling_resistance = calc_rolling_resistance()
	f_drag = calc_f_drag(velocity)
	
	var engine_torque = get_engine_torque_at_rpm(500, 1)
	# n_tf = transmission_ration  + drive_ration
	# efi_tf = transmission_efficiency * final drive efficiency
	var eff = conf["transmission_efficiency"] * conf["drive_efficiency"]
	# acc = (torque_at_rpm * n_tf * efi_tf)/wheel_radius - f_rolling_resistance - f_drag - mass * G * sin_theta
	var f_traction = (engine_torque * eff)/conf["wheel_radius"] * dir

	f_long = f_traction - f_rolling_resistance - f_drag
	
	if f_long > f_max_traction:
		f_long = f_max_traction * 0.9
	
func calc_f_lat(): 
	pass

func calc_f_yaw():
	pass
	
func calc_f_drag(velocity:Vector2) -> Vector2:
	# TODO aumentar a área se o carro estiver virando
	var drag = 0.5 * Global.AIR_DENSITY * conf["frontal_area"] * conf["friction_coef"] * velocity * velocity
	return drag

func calc_rolling_resistance() -> Vector2:
	return Vector2.ZERO
	
func calc_wheel_axis_weight():
	# Static
	var static_front_weight = conf["mass"] * G * (conf["front_axle_distance"]/wheel_base)
	var static_rear_weight = conf["mass"] * G * (conf["rear_axle_distance"]/wheel_base)
	
func _ready() -> void:
	# Setup the body
	front_axle.position.x = conf["front_axle_distance"] * Global.PIXEL_METER
	rear_axle.position.x = -conf["rear_axle_distance"] * Global.PIXEL_METER
	
	#front_axle_distance = front_axle.position.x - com_indicator.position.x
	#rear_axle_distance = rear_axle.position.x - com_indicator.position.x
	#hud_wf.max_value = vehicle_weight
	#hud_wr.max_value = vehicle_weight

	
func _physics_process(delta: float) -> void:
	var direction:Vector2=transform.x
	
	set_f_long(direction, velocity)
	
	#acceleration = sqrt(acc_vector.x * acc_vector.x + acc_vector.y * acc_vector.y)
	
	var brake = Input.get_action_strength("brake")
	var gas = Input.get_action_strength("gas")
	
	# Forces
	front_weight = conf["mass"] * G * (conf["front_axle_distance"]/wheel_base)
	rear_weight = conf["mass"] * G * (conf["rear_axle_distance"]/wheel_base)
	
	acc = f_long/conf["mass"]
	
	velocity += acc * delta
	position = position + delta * velocity
	speedometer.text= str(sqrt(velocity.dot(direction)) * 3.6)
	
func _process(delta: float) -> void:
	# Hud
	hud_wf.value = front_weight
	hud_wr.value = rear_weight
	hud_wf_label.text = str(front_weight)
	hud_wr_label.text = str(rear_weight)
	
	
	# EndHud
