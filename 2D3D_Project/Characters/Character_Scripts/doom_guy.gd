extends CharacterBody3D

@export var SPEED := 3.0
@export var JUMP_STRENGTH := 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _snap_vector := Vector3.DOWN

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _animation_tree: AnimationTree = $AnimationTree

func get_component(component: StringName) -> Node:
	return get_meta(component, null)
	
func has_component(component: StringName) -> bool:
	return has_meta(component)

func set_camera(c):
	if has_component("SpriteRotationComponent"):
		var cSpriteRot := get_component("SpriteRotationComponent")
		cSpriteRot.set_camera(c)

func _process(_delta) -> void:
	_spring_arm.position = lerp(position, _spring_arm.position, .15) 

func _physics_process(delta) -> void:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	velocity.x = move_direction.x * SPEED
	velocity.z = move_direction.z * SPEED
	velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = JUMP_STRENGTH
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	
	if velocity.length() > 0.2:
		var look_dir = Vector2(velocity.z, velocity.x)
		rotation.y = look_dir.angle()
	
	update_animation_parameters()
	
	if has_component("SpriteRotationComponent"):
		var cSpriteRot := get_component("SpriteRotationComponent")
		cSpriteRot.SpriteRotation()
	
	move_and_slide()

func update_animation_parameters():
	_animation_tree.set("parameters/conditions/idle", velocity == Vector3.ZERO)
	_animation_tree.set("parameters/conditions/is_Moving", velocity != Vector3.ZERO)
