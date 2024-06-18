extends Sprite3D

const SPEED: float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	add_these_numbers(5, 6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_inputs()

func check_inputs():
	if Input.is_action_pressed("ui_left"):
		rotate_y((deg_to_rad(-SPEED)))
	elif Input.is_action_pressed("ui_right"):
		rotate_y((deg_to_rad(SPEED)))

func add_these_numbers(x, y):
	var sum = x + y
	return sum
