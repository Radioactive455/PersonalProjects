class_name WFC3D 
extends WFC3D_MAIN

const NEIGHBORS : String = "valid_neighbors"
const MESH : String = "mesh"
const ROTATION : String = "rotation"

# stores all the nodes
var wave_function : Array
var has_been_collapsed : Array

# acts as stack for propagation
var stack : Array

# blender and godot define the xyz axis differently
# the y-axis and z-axis are swapped
# LEFT = Vector3i(-1, 0, 0)
# RIGHT = Vector3i(1, 0, 0)
# UP = Vector3i(0, 1, 0)
# DOWN = Vector3i(0, -1, 0)
# FORWARD = Vector3i(0, 0, -1)
# BACK = Vector3i(0, 0, 1)
const direction_to_index : Dictionary = {
	  Vector3i.LEFT : 2
	, Vector3i.RIGHT : 3
	, Vector3i.FORWARD : 1
	, Vector3i.BACK : 0
	, Vector3i.UP : 4
	, Vector3i.DOWN : 5
}

const mesh_rotation_convert : Dictionary = {
	0 : 0
	, 1 : 16
	, 2 : 10
	, 3 : 22
}

func _init():
	print("INIT WFC3D")

func init_wfc(new_size : Vector3i, all_prototypes : Dictionary, custom_seed : String, grid_map : GridMap):
	if custom_seed : seed(custom_seed.hash())
	dimensions = new_size
	for _z in range(dimensions.z):
		var y = []
		for _y in range(dimensions.y):
			var x = []
			for _x in range(dimensions.x):
				var pos : Vector3i = Vector3i(_x, _y,_z)
				var cell : int = grid_map.get_cell_item(pos)
				if cell == -1:
					x.append(all_prototypes.duplicate())
				else:
					# There is a value already at the location, 
					#	define it in dictionary terms
					var o : int = grid_map.get_cell_item_orientation(pos)
					
					# translate the orientation to the dictionary's style
					o = mesh_rotation_convert.find_key(o)
					
					var mesh_name : String = grid_map.mesh_library.get_item_name(cell)
					for p in all_prototypes:
						if all_prototypes[p][MESH] == mesh_name and\
						all_prototypes[p][ROTATION] == o:
							var c : Dictionary = {
								p : all_prototypes[p]
							}
							x.append(c)
							break
					
			y.append(x)
		wave_function.append(y)

func is_collapsed() -> bool:
	# navigate the array
	for _z in wave_function:
		for _y in _z:
			for _x in _y:
				if _x.size() > 1:
					return false
	return true

func get_min_entropy_coords():
	# navigate the array
	var min_positions : Array = []
	var min_size : int = 9223372036854775807 # max int value because there is no constant
	var pos_in_func : Vector3i = Vector3i(0,0,0)
	for _z in wave_function:
		pos_in_func.y = 0
		for _y in _z:
			pos_in_func.x = 0
			for _x in _y:
				if !has_been_collapsed.has(pos_in_func): # has this been collapsed?
					var size = _x.size()
					if size < min_size:
						min_positions.clear()
						min_positions.append(pos_in_func)
						min_size = size
					elif size == min_size:
						min_positions.append(pos_in_func)
				pos_in_func.x += 1
			# end for loop _x
			pos_in_func.y += 1
		# end for loop _y
		pos_in_func.z += 1
	# end for loop _z
	var chosen_pos : Vector3i = min_positions[randi_range(0, min_positions.size() - 1)]
	has_been_collapsed.append(chosen_pos)
	return chosen_pos

func collapse_at(_coords : Vector3i):
	var node = wave_function[_coords.z][_coords.y][_coords.x]
	
	var node_len = len(node) - 1
	var val : int = randi_range(0, node_len)
	
	var prototype_key : String = node.keys()[val]
	
	for n in wave_function[_coords.z][_coords.y][_coords.x].keys():
		if n != prototype_key :
			wave_function[_coords.z][_coords.y][_coords.x].erase(n)
	
func valid_dirs(_coords : Vector3i)-> Array:
	var valid_results : Array = []
	for d in direction_to_index:
		var neighbor = _coords + d
		if neighbor.z >= 0 && neighbor.z < dimensions.z:
			if neighbor.y >= 0 && neighbor.y < dimensions.y:
				if neighbor.x >= 0 && neighbor.x < dimensions.x:
					valid_results.append(d)
	
	return valid_results

func get_possibilities(_coords : Vector3i) -> Array:
	return wave_function[_coords.z][_coords.y][_coords.x].keys()

func get_possible_neighbors(_coords : Vector3i ,  dir : Vector3i) -> Array:
	var curr_dict : Dictionary = wave_function[_coords.z][_coords.y][_coords.x]
	var prototype_keys : Array = curr_dict.keys()
	
	if !prototype_keys.is_empty() :
		var possible_neighbors : Array
		#loop through every key
		for key in curr_dict:
			var neighbors = curr_dict[key][NEIGHBORS]
			
			# add necessary neighbors to the array
			# NO DUPLICATES
			var curr_neighbor : Array
			match direction_to_index[dir]: 
				0:
					curr_neighbor = neighbors["posY"]
				1:
					curr_neighbor = neighbors["negY"]
				2:
					curr_neighbor = neighbors["posX"]
				3:
					curr_neighbor = neighbors["negX"]
				4:
					curr_neighbor = neighbors["posZ"]
				5:
					curr_neighbor = neighbors["negZ"]
			
			#add any neighbor that is not already on the list
			for n in curr_neighbor:
				if not n in possible_neighbors:
					possible_neighbors.append(n)
		
		return possible_neighbors
	
	# default empty
	return Array()

func constrain(_coords : Vector3i, prototype : String ):
	wave_function[_coords.z][_coords.y][_coords.x].erase(prototype)

#update the surrounding nodes
func propagate(_coords : Vector3i):
	stack.append(_coords)
	
	while len(stack) > 0:
		var cur_coords = stack.pop_back()
		
		for d in valid_dirs(cur_coords): # iterate over adjacent cells
			var other_coords : Vector3i = (cur_coords + d)
			var other_possible_prototypes : Array = get_possibilities(other_coords).duplicate()
			
			var possible_neighbors : Array = get_possible_neighbors(cur_coords, d)
			
			#if(other_possible_prototypes.size() == 1 and !possible_neighbors.has(other_possible_prototypes[0])):
				#print("POSSIBILITIES: " + str(other_possible_prototypes))
				#print("ALLOWED NEIGHBORS ARE: " + str(possible_neighbors))
				#print("CURR COORDS" + str(cur_coords))
				#print("CURR COORDS KEYS: " + str(get_possibilities(cur_coords)))
				#print("STARTED WITH PROTOTYPE: " + str(get_possibilities(_coords)))
			
			if len(other_possible_prototypes) == 0:
				continue
			
			#var removed : Array
			for other_proto in other_possible_prototypes:
				if not other_proto in possible_neighbors:
					# remove protoype from that super position					
					constrain(other_coords, other_proto)
					#removed.append(other_proto)
					
					if not other_coords in stack:
						stack.append(other_coords)
			
			#if !removed.is_empty() and other_coords == Vector3i(4, 0, 8):
				#print("CURR COORDS" + str(cur_coords))
				#print("CURR COORDS KEYS: " + str(get_possibilities(cur_coords)))
				#print("CURR DIR: " + str(direction_to_index[d]))
				#print("ALLOWED NEIGHBORS ARE: " + str(possible_neighbors))
				#print("OLD POSSIBILITIES: " + str(other_possible_prototypes))
				#print("UPDATED POSSIBILITIES: " + str(get_possibilities(other_coords)))
				#print("REMOVED: " + str(removed) + '\n')


func clean_up(grid_map : GridMap):
	var pos_in_func : Vector3i = Vector3i(0,0,0)
	for _z in wave_function:
		pos_in_func.y = 0
		for _y in _z:
			pos_in_func.x = 0
			for _x in _y:
				var node = wave_function[pos_in_func.z][pos_in_func.y][pos_in_func.x]
				
				if node.keys().is_empty():
					#print("ERROR: " + str(pos_in_func) + " HAS NO POSSIBILITIES")
					pos_in_func.x += 1
					continue
					
				else:
					var prototype_key : String = node.keys()[0]
					
					var prototype = node[prototype_key]
					
					var mesh_name : String = prototype[MESH]
					
					var mesh_rot : int = prototype[ROTATION]
					var mesh_int : int = grid_map.mesh_library.find_item_by_name(mesh_name)
					
					grid_map.set_cell_item(pos_in_func, mesh_int, mesh_rotation_convert[mesh_rot])
					
					# check if successful tile set
					var err = grid_map.get_cell_item(pos_in_func)
					if err == -1:
						print("ERROR AT " + str(pos_in_func) + " USING MESH " + str(mesh_name))
						
					pos_in_func.x += 1
			# end for loop _x
			pos_in_func.y += 1
		# end for loop _y
		pos_in_func.z += 1
	# end for loop _z

func iterate_grid():
	var coords : Vector3i = get_min_entropy_coords()

	collapse_at(coords)
	#var print_proto : String = str(wave_function[coords.z][coords.y][coords.x].keys())
	#print("SELECTED PROTOTYPE " + print_proto + " AT " + str(coords) + '\n')
	propagate(coords)
	
