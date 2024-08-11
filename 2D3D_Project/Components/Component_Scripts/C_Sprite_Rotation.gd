class_name SpriteRotationComponent extends Node

# In case we want to disable it
@export var is_enabled: bool = true
@export var RotationTimer: float = 0.1

var camera = null
var spr3DPath: NodePath = ".." # default path 
var rotationTimerUpdate: float = 0

func _enter_tree() -> void:
	# This component can only work with Sprite3Ds
	if owner.get_class() != "Sprite3D":
		#check parent's children
		var node = get_node_or_null("../Sprite3D") 
		assert(node is Sprite3D, "Tree must have a Sprite3D")
		
		var animPlayerCheck = get_node_or_null("../Sprite3D/AnimationPlayer")
		assert(animPlayerCheck is AnimationPlayer, "Tree must have AnimationPlayer")
		
		spr3DPath = node.get_path()
		print("SUCCESS")
	
	owner.set_meta(&"SpriteRotationComponent",self) # Register
	
	
func _exit_tree() ->void:
	owner.remove_meta(&"SpriteRotationComponent") # Unregister


func set_camera(c):
	camera = c

func SpriteRotation(delta):
	if camera == null or !is_enabled:
		return
		
	if rotationTimerUpdate >= 0:
		rotationTimerUpdate -= delta
		return
	else:
		rotationTimerUpdate = RotationTimer
	
	var spr3D = get_node_or_null(spr3DPath)
	
	var player_fwd: Vector3 = -camera.global_transform.basis.z
	var fwd: Vector3 = owner.global_transform.basis.z
	var left: Vector3 = owner.global_transform.basis.x
	
	# if facing same dir: dot value is 1
	# if facing op dir: dot value is -1
	var l_dot: float = left.dot(player_fwd)
	var f_dot: float = fwd.dot(player_fwd)
	
	var row: int = 0 # reset the row dir
	
	spr3D.flip_h = false # keep sprite up to date
	
	if f_dot < -0.85:
		row = 0 # front sprite
	elif f_dot > 0.85:
		row = 4 # back sprite
	else:
		spr3D.flip_h = l_dot > 0
		
		if abs(f_dot) < 0.3:
			row = 2 # left sprite
		elif f_dot < 0:
			row = 1 # forward-left sprite
		else: 
			row = 3 # back left sprite
	
	if owner is Sprite3D:
		owner.frame = owner.anim_col + row * owner.hframes
	else:
		spr3D.frame = spr3D.anim_col + row * spr3D.hframes
