extends RigidBody2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.y += Global.GRAVEDAD * state.step
