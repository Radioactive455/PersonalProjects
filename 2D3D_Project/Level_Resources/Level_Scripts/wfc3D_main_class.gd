class_name WFC3D_MAIN
extends Resource

var wfc : WFC3D
var dimensions : Vector3i
var custom_seed : String
var dict_prototype : Dictionary
var grid_map : GridMap

func _init():
	print("INIT WFC3D_MAIN")

func init_main(_seed: String, _dims : Vector3i, _grid_map : GridMap):
	wfc = WFC3D.new()
	custom_seed = _seed
	dimensions = _dims
	grid_map = _grid_map
	dict_prototype = load_prototype_data()

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
	if wfc != null:
		if !dict_prototype.is_empty():
			wfc.init_wfc(dimensions, dict_prototype, custom_seed, grid_map)
			
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


