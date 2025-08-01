extends Node2D

@onready var veh = %Vehicle
@onready var debug = %Debug

func _process(delta: float) -> void:
	debug.text = "%s" % veh.speed
