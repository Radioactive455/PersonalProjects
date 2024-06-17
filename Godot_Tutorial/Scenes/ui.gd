extends CanvasLayer

static var img = load("res://PNG/UI/playerLife1_red.png")
var time_elapsed := 0

func set_health(amount):
	# remove all children
	for child in $MarginContainer2/HBoxContainer.get_children():
		child.queue_free() #deletes the node
	
	# create new children. amount is set by health
	for i in amount:
		var text_rect:= TextureRect.new()
		text_rect.texture = img
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		
		$MarginContainer2/HBoxContainer.add_child(text_rect)


func _on_score_timer_timeout():
	time_elapsed += 1
	$MarginContainer/Label.text = str(time_elapsed)
	Global.score = time_elapsed
