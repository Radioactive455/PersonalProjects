extends Node2D

# 1. load the meteor scene/object
var meteor_scene: PackedScene = load("res://Scenes/meteor.tscn")
var laser_scene: PackedScene = load("res://Scenes/laser.tscn")
var star_scene: PackedScene = load("res://Scenes/star.tscn")

var health: int = 3

func _ready():
	# set up health UI
	get_tree().call_group('ui', 'set_health', health)
	
	
	#stars
	var rng := RandomNumberGenerator.new()
	
	var dim: Vector2 = get_viewport().get_visible_rect().size
	
	for i in 20:
		#create and add stars to node list
		var star: Node = star_scene.instantiate()
		$Stars.add_child(star)
		
		#position of star
		var pos_x: int = rng.randi_range(0, int(dim.x))
		var pos_y: int = rng.randi_range(0, int(dim.y))

		star.position = Vector2(pos_x, pos_y)
		
		#scale of star
		var scl: float = rng.randf_range(0.5, 1.5)
		star.scale = Vector2(scl, scl)
		
		#animation speed
		star.get_node("AnimatedSprite2D").speed_scale = rng.randf_range(0.6, 1.4)


func _on_meteor_timer_timeout():
	# 2. create an instance
	var meteor: Node = meteor_scene.instantiate()
	
	# 3. attach the node to the level scene tree
	$Meteors.add_child(meteor)
	
	# connect the signal
	meteor.connect('collision', on_meteor_collision)


func on_meteor_collision():
	health -= 1
	get_tree().call_group('ui', 'set_health', health)
	$Player.play_collision_sound()
	
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")


func _on_player_laser(pos):
	var laser: Node = laser_scene.instantiate()
	
	$Lasers.add_child(laser)
	laser.position = pos
