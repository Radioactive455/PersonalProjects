@tool # allows for script to run in editor
extends Node3D

@onready var grid_map : GridMap = $GridMap
@onready var mesh_lib : MeshLibrary = grid_map.mesh_library

# Hidden from editor variables
var wfc : WFC3D

@export var dimensions : Vector3i :
	set(values):
		if Engine.is_editor_hint():
			dimensions = values

@export var start : bool :
	set(value):
		if Engine.is_editor_hint(): # only run if in editor
			generate()

@export_multiline var custom_seed : String : 
	set(_seed):
		custom_seed = _seed

func load_prototype_data()-> Dictionary:
	var file : FileAccess = FileAccess.open("res://Level_Resources/exported_mesh_data.json", FileAccess.READ)
	var json_object : JSON = JSON.new()
	var err = json_object.parse(file.get_as_text())
	if err == OK:
		return json_object.get_data()
	else :
		print("JSON Parse Error: ", json_object.get_error_message(), " in ", json_object, " at line ", json_object.get_error_line())
		return Dictionary()


func generate():
	wfc = WFC3D.new()
	
	if wfc != null:
		var dict_prototype : Dictionary = load_prototype_data()
		if !dict_prototype.is_empty():
			grid_map.clear()
			wfc.init_wfc(dimensions, dict_prototype, custom_seed)
			
			var fail_safe : int = 0
			var limit: int = (dimensions.x * dimensions.y * dimensions.z) + 10
			while not wfc.is_collapsed():
				wfc.iterate_grid()
				
				if fail_safe > limit: 
					print("CRITICAL FAILURE! INFINITE LOOP!")
					break; # prevent infinite loops while debugging
				else : 
					fail_safe += 1
			#end while loop
			
			wfc.clean_up(grid_map)
			
			print("GENERATION COMPLETE!")
			return
		
	print("FAILURE TO GENERATE!")


