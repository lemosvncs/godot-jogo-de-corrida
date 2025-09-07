extends RigidBody2D

var front_wheels:Node2D
var rear_wheels:Node2D

var motor:Motor 
var transmission:Transmission 
var diff:Differential 

var config = {
	"idk": 1.0,
	"physics": {
		# "coef_friction_tires": 0.9,
	}
}

func _ready() -> void:
	front_wheels = $FrontWheels
	rear_wheels = $RearWheels

	motor = Motor.new()
	transmission = Transmission.new()
	diff = Differential.new()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var forward =Vector2.RIGHT.rotated(rotation)

	# Step 1: engine Torque
	var engine_torque_nm = motor.calc_torque(1.0)
	var transmission_torque_nm = transmission.calc_transmission_torque(engine_torque_nm)
	diff.set_diff_torque(transmission_torque_nm, rear_wheels)

	# # Step 2: Apply torque to wheels
	# Leva em consideração a força máxima possível (normal) pela gravidade
	for wheel in rear_wheels.get_children():
		var res_force = wheel.torque/wheel.radius
		res_force = res_force
		var max_tire_force = (mass * Global.G / 4) * wheel.coef_friction
		res_force = clamp(res_force, -max_tire_force, max_tire_force)
		# Aponta a força pra direção que a roda tá apontado
		# Não é tão útil na roda traseira, por enquanto, mas vai ser útil na roda dianteira
		state.apply_force(forward.rotated(wheel.global_rotation) * res_force)
		
class Motor:
	var current_rpm:float=0.0
	var max_rpm:float=6000.0
	var max_torque:float=200.0

	func calc_torque(gas_input:float) -> float:
		var rpm_factor = max(0.1, 1.0 - (current_rpm/max_rpm)) 
		return max_torque * gas_input * rpm_factor

class Transmission:
	func calc_transmission_torque(engine_torque_nm:float) -> float:
		return engine_torque_nm

class Differential:
	func set_diff_torque(transmission_torque_nm:float, rear_wheels:Node2D):
		for wheel in rear_wheels.get_children():
			wheel.torque = transmission_torque_nm
