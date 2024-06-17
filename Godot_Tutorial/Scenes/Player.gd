extends CharacterBody2D
@export var speed: int = 500 #can be seen and editted from editor due to @export
var can_shoot: bool = true

signal laser(pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * speed
	move_and_slide()
	
	#shoot input
	if Input.is_action_just_pressed("shoot") and can_shoot:
		#spawn laser
		laser.emit($LaserStartPos.global_position)
		can_shoot = false;
		$LaserTimer.start()
		$LaserSFX.play()

func play_collision_sound():
	$DamageSFX.play()
	
	

func _on_laser_timer_timeout():
	can_shoot = true
