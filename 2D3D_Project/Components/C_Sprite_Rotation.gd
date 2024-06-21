class_name SpriteRotationComponent extends Node

# In case we want to disable it
@export var is_enabled: bool = true

func _enter_tree() -> void:
	# This component can only be a child of Sprite3Ds
	assert(owner is Sprite3D, "Owner must be a Sprite3D")
	owner.set_meta(&"SpriteRotationComponent",self) # Register
	print("Success!")
	
func _exit_tree() ->void:
	owner.remove_meta(&"SpriteRotationComponent") # Unregister
	
func get_component(component: StringName) -> Node:
	return get_meta(component, null)
	
func has_component(component: StringName) -> bool:
	return has_meta(component)

func SpriteRotation():
	var tOwner := get_owner()
	
	if tOwner.camera == null or !is_enabled:
		return
	
	var camera = tOwner.camera
	
	var player_fwd: Vector3 = -camera.global_transform.basis.z
	var fwd: Vector3 = tOwner.global_transform.basis.z
	var left: Vector3 = tOwner.global_transform.basis.x
	
	# if facing same dir: dot value is 1
	# if facing op dir: dot value is -1
	var l_dot: float = left.dot(player_fwd)
	var f_dot: float = fwd.dot(player_fwd)
	
	var row: int = 0 # reset the row dir
	
	owner.flip_h = false # keep sprite up to date
	
	if f_dot < -0.85:
		row = 0 # front sprite
	elif f_dot > 0.85:
		row = 4 # back sprite
	else:
		owner.flip_h = l_dot > 0
		
		if abs(f_dot) < 0.3:
			row = 2 # left sprite
		elif f_dot < 0:
			row = 1 # forward-left sprite
		else: 
			row = 3 # back left sprite
	
	owner.frame = tOwner.anim_col + row * 4
