extends Area2D

var speed: int
var rotation_speed: int
var direction_x: float

signal collision
var can_collide: bool = true

func _ready():
	var rng := RandomNumberGenerator.new()
	
	#texture
	var path: String = "res://PNG/Meteors/meteorBrown_big" + str(rng.randi_range(1,4)) + ".png"
	$MeteorSprite.texture = load(path)
	
	#start pos
	var width: float = get_viewport().get_visible_rect().size[0]
	var random_x: float = rng.randf_range(0, width)
	var random_y: float = rng.randf_range(-150, -50)
	position = Vector2(random_x, random_y)
	
	#speed
	speed = rng.randi_range(200, 500)
	
	#rotation
	rotation_speed = rng.randi_range(40, 100)
	
	#direction
	direction_x = rng.randf_range(-1, 1)


func _process(delta):
	position += Vector2(direction_x, 1.0) * speed * delta
	rotation_degrees += rotation_speed * delta

func _on_body_entered(_body):
	if can_collide:
		collision.emit()

func _on_area_entered(area):
	area.queue_free() # remove the laser
	$ExplosionSFX.play()
	$MeteorSprite.hide()
	can_collide = false
	await get_tree().create_timer($ExplosionSFX.stream.get_length()).timeout
	queue_free() # remove the meteor
