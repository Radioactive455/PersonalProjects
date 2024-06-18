extends Area3D

const ROT_SPEED: float = 1.5 # number of degrees the coin rotates every frame

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotate_y(deg_to_rad(ROT_SPEED))
	

func _on_body_entered(_body):
	queue_free()
