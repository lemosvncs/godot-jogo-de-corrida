extends Node2D

@onready var veh = %Vehicle
@onready var debug = %Debug

func _process(delta: float) -> void:
	debug.text = "
	f_long: %s
	" % [
		veh.f_long
	#snapped(veh.speed, 0.01), veh.f_drag, veh.f_traction, veh.f_brake, veh.forces, 
	#veh.velocity/20,
	#veh.acceleration/20,
	#veh.front_weight,
	#veh.rear_weight,
	#veh.vehicle_weight
	]

	if Input.is_action_pressed("reset"):
		veh.position = Vector2(0, 100)
