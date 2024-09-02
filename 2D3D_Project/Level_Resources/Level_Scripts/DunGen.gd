@tool # allows for script to run in editor
extends Node3D

@onready var grid_map : GridMap = $GridMap

# allows start to be accessed in editor
# every time 'start' is accessed, it calls the set_start func
@export var start : bool = false : set = set_start
func set_start(_val:bool)->void:
	if Engine.is_editor_hint(): # only run if in editor
		generate()
		# fill in the rest with WFC
		var wfc : WFC3D_MAIN = WFC3D_MAIN.new()
		wfc.init_main(custom_seed, border_size, grid_map)
		wfc.generate()

@export_range(0,1) var survival_chance : float = 0.25
@export var border_size : Vector3i : 
	set(value):
		border_size = value
		if Engine.is_editor_hint(): # only run if in editor
			visualize_border()

@export var room_number : int = 4
@export var room_margin : int = 1
@export var room_recursion : int = 15
@export var min_room_size : int = 2
@export var max_room_size : int = 5

const TILE_BORDER : int = 0 #8
const TILE_CORNER : int = 1
const TILE_ROOM : int = 8 #0
const TILE_DOOR : int = 6
const TILE_HALL: int = 13
const TILE_T_INTER: int = 12
const TILE_CROSS_INTER: int = 5

# orientations: 
# Open Right: 0 	DEFAULT
# Open Left: 10 	180 about y
# Open Up:	 16 	90 about y
# Open Down: 22 	270 about y

const ORIENTATION_RIGHT : int = 0
const ORIENTATION_LEFT	: int = 10
const ORIENTATION_UP	: int = 16
const ORIENTATION_DOWN 	: int = 22

@export_multiline var custom_seed : String = "" : set = set_seed
func set_seed(val : String) -> void:
	custom_seed = val
	seed(val.hash())

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []

func visualize_border():
	grid_map.clear()
	for i in range(-1, border_size.x + 1):
		if i < 0 or i > border_size.x - 1:
			for j in range(-1, border_size.z + 1):
				grid_map.set_cell_item(Vector3i(i, 0, j), TILE_BORDER)
				grid_map.set_cell_item(Vector3i(j, 0, i), TILE_BORDER)


func generate():
	room_tiles.clear()
	room_positions.clear()
	#set seed if custom_seed not empty
	if custom_seed : set_seed(custom_seed)
	
	visualize_border()	
	
	for i in room_number:
		make_room(room_recursion)
	
	var rpv2 : PackedVector2Array = []
	var del_graph : AStar2D = AStar2D.new()
	var mst_graph: AStar2D = AStar2D.new()
	
	for p in room_positions:
		rpv2.append(Vector2(p.x, p.z))
		del_graph.add_point(del_graph.get_available_point_id(), Vector2(p.x, p.z))
		mst_graph.add_point(mst_graph.get_available_point_id(), Vector2(p.x, p.z))
	
	var delaunay : Array = Array(Geometry2D.triangulate_delaunay(rpv2))
	
	# create triangles between room positions
	for i in delaunay.size()/3:
		var p1 : int = delaunay.pop_front()
		var p2 : int = delaunay.pop_front()
		var p3 : int = delaunay.pop_front()
		del_graph.connect_points(p1, p2)
		del_graph.connect_points(p2, p3)
		del_graph.connect_points(p1, p3)
	
	# find min spanning tree
	var visited_points : PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections : Array[PackedInt32Array] = []
		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if !visited_points.has(c):
					var con : PackedInt32Array = [vp, c]
					possible_connections.append(con)
					
		var connection : PackedInt32Array = possible_connections.pick_random()
		#compare lengths
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) <\
			rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
					connection = pc # store the shortest
					
			#connect the point to the visited point array
		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		del_graph.disconnect_points(connection[0], connection[1])
	
	var hallway_graph : AStar2D = mst_graph
	
	#randomly add paths back into the generated level to keep things interesting
	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p:
				var kill : float = randf()
				if survival_chance > kill :
					hallway_graph.connect_points(p,c)
					
	create_hallways(hallway_graph)


func create_hallways(hallway_graph : AStar2D):
	var hallways : Array[PackedVector3Array] = []
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c > p:
				var room_from : PackedVector3Array = room_tiles[p]
				var room_to : PackedVector3Array = room_tiles[c]
				var tile_from : Vector3 = room_from[0]
				var tile_to : Vector3 = room_to[0]
				
				for t in room_from:
					if t.distance_squared_to(room_positions[c]) <\
					tile_from.distance_squared_to(room_positions[c]):
						tile_from = t
				
				for t in room_to:
					if t.distance_squared_to(room_positions[p]) <\
					tile_to.distance_squared_to(room_positions[p]):
						tile_to = t
				
				var hallway : PackedVector3Array = [tile_from, tile_to]
				hallways.append(hallway)
				
				# create temp doorways (will be corrected after hallways are created)
				grid_map.set_cell_item(tile_from, TILE_DOOR)
				grid_map.set_cell_item(tile_to, TILE_DOOR)
				
	
	var aStar : AStarGrid2D = AStarGrid2D.new()
	aStar.size = Vector2i.ONE * (border_size.x * border_size.z)
	aStar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	aStar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	aStar.update()
	
	# set room tiles as solid so A-star won't go through them
	for RM in room_tiles:
		for t in RM:
			if grid_map.get_cell_item(Vector3(t.x, 0, t.z)) != TILE_DOOR:
				aStar.set_point_solid(Vector2i(t.x, t.z))
	
	for h in hallways:
		var pos_from : Vector2i = Vector2i(h[0].x, h[0].z)
		var pos_to : Vector2i = Vector2i(h[1].x, h[1].z)
		var hall : PackedVector2Array = aStar.get_point_path(pos_from, pos_to)
			
		
		for t in hall.size():
			if t == 0 or t == hall.size() - 1:
				continue
			
			var tile_type : int = TILE_HALL
			var curr = hall[t]
			var pos : Vector3i = Vector3i(curr.x, 0, curr.y)
			
			if grid_map.get_cell_item(pos) < 0: # is it unused?
				var next = null
				var prev = null
				if t < hall.size() - 1:
					next = hall[t + 1]
				if t > 0:
					prev = hall[t - 1]
				
				if next != null and prev != null:
					if next.x != prev.x and next.y != prev.y: # CORNER NEEDED
						tile_type = TILE_CORNER
						if curr.y > prev.y || curr.y > next.y:
							if curr.x > next.x || curr.x > prev.x:
								grid_map.set_cell_item(pos, tile_type, ORIENTATION_LEFT)
							else:
								grid_map.set_cell_item(pos, tile_type, ORIENTATION_UP)
						else:
							if curr.x < prev.x || curr.x < next.x:
								grid_map.set_cell_item(pos, tile_type, ORIENTATION_RIGHT)
							else:
								grid_map.set_cell_item(pos, tile_type, ORIENTATION_DOWN)
						
						continue
					else:
						# tile is a straight path
						if prev.x != curr.x:
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_UP)
						elif prev.y != curr.y :
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_LEFT)
				
				# using only one valid position, determine the orientation
				elif next != null:
					if next.x != curr.x:
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_UP)
					elif next.y != curr.y :
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_LEFT)
				elif prev != null:
					if prev.x != curr.x:
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_UP)
					elif prev.y != curr.y :
							grid_map.set_cell_item(pos, tile_type, ORIENTATION_LEFT)
		
		# correct the door's
		for t in grid_map.get_used_cells_by_item(TILE_DOOR):
			grid_map.set_cell_item(t, -1) # empty the tile
			#var tile_type : int = TILE_DOOR
			#if grid_map.get_cell_item(t + Vector3i.RIGHT) == TILE_HALL or\
			#grid_map.get_cell_item(t + Vector3i.RIGHT) == TILE_CORNER:
				#grid_map.set_cell_item(t, tile_type, ORIENTATION_UP)
				#
			#elif grid_map.get_cell_item(t + Vector3i.LEFT) == TILE_HALL or\
			#grid_map.get_cell_item(t + Vector3i.LEFT) == TILE_CORNER:
				#grid_map.set_cell_item(t, tile_type, ORIENTATION_DOWN)
				#
			#elif grid_map.get_cell_item(t + Vector3i.BACK) == TILE_HALL or\
			#grid_map.get_cell_item(t + Vector3i.BACK) == TILE_CORNER:
				#grid_map.set_cell_item(t, tile_type, ORIENTATION_RIGHT)
				#
			#elif grid_map.get_cell_item(t + Vector3i.FORWARD) == TILE_HALL or\
			#grid_map.get_cell_item(t + Vector3i.FORWARD) == TILE_CORNER:
				#grid_map.set_cell_item(t, TILE_DOOR, ORIENTATION_LEFT)


func make_room(rec : int):
	if !rec > 0:
		return
	
	var width : int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height : int = (randi() % (max_room_size - min_room_size)) + min_room_size
	
	var start_pos : Vector3i
	start_pos.x = randi() % (border_size.x - width + 1)
	start_pos.z = randi() % (border_size.z - height + 1)
	
	#check if it is possible to make a room here
	for r in range(-room_margin, height + room_margin):
		for c in range(-room_margin, width + room_margin):
			var tPos :  Vector3i = start_pos + Vector3i(c, 0, r)
			if grid_map.get_cell_item(tPos) == TILE_BORDER:
				make_room(rec - 1)
				return
			else:
				for rm in room_tiles:
					if rm.has(tPos):
						make_room(rec - 1)
						return
	
	var room : PackedVector3Array = []
	for r in height:
		for c in width:
			var tPos2 :  Vector3i = start_pos + Vector3i(c, 0, r)
			if (r > 0 and r < height - 1) and (c > 0 and c < width - 1):
				grid_map.set_cell_item(tPos2, TILE_ROOM)
			room.append(tPos2)
	room_tiles.append(room)
	
	#calculate center pos
	var avg_x : float = start_pos.x + (float(width) / 2)
	var avg_z : float = start_pos.z + (float(height) / 2)
	var pos : Vector3 = Vector3(avg_x, 0, avg_z)
	room_positions.append(pos)
