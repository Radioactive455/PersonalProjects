@tool

extends Node3D

@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(val : bool) -> void:
	if Engine.is_editor_hint():
		create_dungeon()

var dun_cell_scene : PackedScene = preload("res://Level_Resources/tiles.tscn")


var directions : Dictionary = {
	  "North" : Vector3i.FORWARD
	, "South" : Vector3i.BACK
	, "West" : Vector3i.LEFT
	, "East" : Vector3i.RIGHT
}

func create_dungeon():
	for c in get_children():
		remove_child(c)
		c.queue_free()
		
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		
		# if it is not empty or a border
		if cell_index <= 13 && cell_index > 0:
			var dun_cell : Node3D = dun_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) + Vector3(0.5, 0, 0.5)
			add_child(dun_cell)
