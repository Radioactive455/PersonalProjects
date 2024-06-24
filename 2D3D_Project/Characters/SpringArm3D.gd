extends SpringArm3D

@export var mouse_sensitivity := 0.05

func _ready() -> void:
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#connect entities to the camera
	get_tree().call_group("Imps", "set_camera", self)
	get_tree().call_group("Player", "set_camera", self)

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0) # limit pitch
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0) # rotation won't accumulate
		
		print(rotation_degrees)
