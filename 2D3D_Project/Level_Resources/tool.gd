@tool
extends Node3D

func _ready():
	_work()

func _work():
	var root: Node3D = self
	for mi in root.get_children():
		if mi.is_class("MeshInstance3D"):
			print("Found MeshInstance3D ", mi)
			mi.create_trimesh_collision()

