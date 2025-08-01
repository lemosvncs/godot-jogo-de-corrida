extends Node2D

@export var engine_force = 1000
@export var mass = 1000
var velocity:Vector2=Vector2.ZERO
var speed:float

func _physics_process(delta: float) -> void:
	var direction:Vector2=transform.x
	#print(direction)
	# Longitudinal forces
	
	var traction = direction * engine_force
	var forces = traction
	
	var acc = forces/mass
	velocity = velocity + delta * acc
	speed = (velocity.x * velocity.x + velocity.y * velocity.y)
	
	position = position + delta * velocity
