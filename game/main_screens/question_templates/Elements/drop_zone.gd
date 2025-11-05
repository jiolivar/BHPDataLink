tool

extends Area2D
class_name DropZone

export var id := 0
export var text = ""

onready var drop_area
var use_parent_area := false

func _ready():
	#make really really sure is unique (local to scene doesn't all the time :S)
	var panel_style = $"%HighLite".get("custom_styles/panel").duplicate()
	$"%HighLite".set("custom_styles/panel", panel_style)
	_apply_settings()
	
func _process(delta):
	if Engine.is_editor_hint():
		_apply_settings()

func _apply_settings():
	$"%Label".text = text
	if get_parent() is CollisionShape2D:
		use_parent_area = true
		drop_area = get_parent()
		$"%CollisionShape2D".global_position = drop_area.global_position
		$"%CollisionShape2D".shape.extents = drop_area.shape.extents
		$"%HighLite".rect_position = $"%CollisionShape2D".position-drop_area.shape.extents
	else:
		drop_area = $"%CollisionShape2D"
		$"%HighLite".rect_position = -drop_area.shape.extents
	$"%HighLite".rect_size = drop_area.shape.extents*2.0
	if not Engine.is_editor_hint():
		$"%HighLite".get("custom_styles/panel").border_color = Main.highlite_color
		_set_highlight_width(Main.highlight_width)

func _set_highlight_width(width : int):
	$"%HighLite".get("custom_styles/panel").border_width_bottom = width
	$"%HighLite".get("custom_styles/panel").border_width_left = width
	$"%HighLite".get("custom_styles/panel").border_width_right = width
	$"%HighLite".get("custom_styles/panel").border_width_top = width
	

func set_highlite(_enable : bool):
	_set_highlight_width( Main.highlight_width + 2 if _enable else Main.highlight_width )
	
