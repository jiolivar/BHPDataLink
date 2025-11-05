tool

extends InteractableElement

class_name DragableElement

onready var initial_pos = position

var dragging := false
var offset := Vector2.ZERO
var current_drop_zones = []
var nearest_drop_zone
var should_resume_highlite := false


signal dragged


func _ready():
	._ready()

func _process(delta):
	._process(delta)
	if dragging:
		position = get_viewport().get_mouse_position() + offset
		_update_nearest_drop_zone()

	
func _input(event):
	if dragging and not completed and event is InputEventMouseButton and not event.pressed:
		Main.grabbing_element = false
		dragging = false
		$"%Icon".z_index = 0
		if should_resume_highlite:
			set_highlite(true)
		if nearest_drop_zone and nearest_drop_zone.id == id:
			nearest_drop_zone.set_highlite(false)
			$"%CorrectAudio".play()
			var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self,"global_position",nearest_drop_zone.global_position,0.1)
			completed = true
			emit_signal("notify_correct")
			set_highlite(false)
		elif nearest_drop_zone:
			$"%WrongAudio".play()
			_return_to_initial_pos()
			emit_signal("notify_wrong")
		else:
			_return_to_initial_pos()

func _return_to_initial_pos():
	var distance = initial_pos.distance_to(position)
	$"%ReturnAudio".volume_db = clamp(-(30-distance*0.05), -30, -10)
	$"%ReturnAudio".play()
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"position",initial_pos,0.3)
	

func _on_DragableElement_input_event(viewport, event, shape_idx):
	if not Main.grabbing_element and not completed and event is InputEventMouseButton and event.pressed:
		Main.grabbing_element = true
		dragging = true
		offset = position - get_viewport().get_mouse_position()
		$"%Icon".z_index = 100
		should_resume_highlite = true
		set_highlite(false)
		emit_signal("dragged")

func _update_nearest_drop_zone():
	nearest_drop_zone = null
	if current_drop_zones.size():
		var min_distance = 9999999.0
		for drop_zone in current_drop_zones:
			drop_zone.set_highlite(false)
			if drop_zone.use_parent_area and drop_zone.id == id:
				nearest_drop_zone = drop_zone
				break
			else:
				var current_distance = global_position.distance_to(drop_zone.global_position)
				if current_distance < min_distance:
					min_distance = current_distance
					nearest_drop_zone = drop_zone
	if nearest_drop_zone:
		nearest_drop_zone.set_highlite(true)

func _on_DragableElement_area_entered(area):
	if area is DropZone:
		current_drop_zones.push_back(area)


func _on_DragableElement_area_exited(area):
	current_drop_zones.erase(area)
	area.set_highlite(false)


func _on_DragableElement_mouse_entered():
	pass # Replace with function body.


func _on_DragableElement_mouse_exited():
	should_resume_highlite = false
