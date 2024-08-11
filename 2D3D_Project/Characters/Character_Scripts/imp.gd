extends Sprite3D

@export var anim_col: int = 0

func get_component(component: StringName) -> Node:
	return get_meta(component, null)
	
func has_component(component: StringName) -> bool:
	return has_meta(component)

func set_camera(c):
	if has_component("SpriteRotationComponent"):
		var cSpriteRot := get_component("SpriteRotationComponent")
		cSpriteRot.set_camera(c)

func _process(delta):
	if has_component("SpriteRotationComponent"):
		var cSpriteRot := get_component("SpriteRotationComponent")
		cSpriteRot.SpriteRotation(delta)
