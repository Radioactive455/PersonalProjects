extends Control

@export var level_scene: PackedScene = load("res://Scenes/level.tscn")

func _ready():
	$CenterContainer/VBoxContainer/Label2.text += str(Global.score)
	$GameOverSFX.play()


func _input(event):
	if event.is_action_pressed("shoot"):
		get_tree().change_scene_to_packed(level_scene)
