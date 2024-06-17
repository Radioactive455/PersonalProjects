extends Area2D

@export var speed: int = 500

func _ready():
	var tween: Tween = create_tween()
	tween.tween_property($LaserRed01, 'scale', Vector2(1,1), 0.15).from(Vector2(0,0))

func _process(delta):
	position.y -= speed * delta
