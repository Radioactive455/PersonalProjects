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
		# limit pitch
		rotation_degrees.x = clamp(rotation_degrees.x, -50.0, 15.0) 
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		# rotation won't accumulate
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0) 

	if event is InputEventKey:
		if event.pressed and event.is_action("escape"):
			# Sending this notification will inform all nodes about the program
			#	termination, but will not terminate the program itself unlike
			#	in 3.X. In order to achieve the previous behavior, 
			#	SceneTree.quit should be called after the notification.
			# get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
