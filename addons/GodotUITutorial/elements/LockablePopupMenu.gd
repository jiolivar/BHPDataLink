extends PopupMenu
class_name LockablePopupMenu


var locked_panel_1 : ColorRect
var locked_panel_2 : ColorRect

export var locked_panel_1_offset : Vector2
export var locked_panel_2_offset : Vector2

export var debug_lock := false


func _ready():
	
	locked_panel_1 = ColorRect.new()
	locked_panel_2 = ColorRect.new()

	locked_panel_1.color = Color.transparent
	locked_panel_2.color = Color.transparent

	if debug_lock:
		locked_panel_1.color = Color.blanchedalmond
		locked_panel_2.color = Color.blanchedalmond
		locked_panel_1.color.a = 0.5
		locked_panel_2.color.a = 0.5
	
	add_child(locked_panel_1)
	locked_panel_1.visible = false
	add_child(locked_panel_2)
	locked_panel_2.visible = false



# FUNCIONES PARA BLOQUEAR
func lock(free_item_index : int) -> void:
	popup_exclusive = true
	set_hide_on_window_lose_focus(false)
	
	yield(get_tree(), "idle_frame")
	
	var margin = 8
	var rect = Rect2()
	rect.position = rect_position
	rect.size = rect_size
	rect.size.y = (rect_size.y - margin * 2)/(get_item_count()) * free_item_index + margin
	
	locked_panel_1.rect_position = Vector2.ZERO - Vector2(0, rect_size.y)
	locked_panel_1.rect_size = rect.size + Vector2(0, rect_size.y) + locked_panel_1_offset
	locked_panel_1.visible = true
	
	rect.position.y = (rect_size.y - margin * 2)/(get_item_count()) * (free_item_index + 1) + margin
	rect.end.y = rect_size.y
	locked_panel_2.rect_position = Vector2(0, rect.position.y) + locked_panel_2_offset
	locked_panel_2.rect_size = rect.size
	
	locked_panel_2.visible = true
	

func unlock() -> void:
	popup_exclusive = false
	set_hide_on_window_lose_focus(true)
	
	locked_panel_1.visible = false
	locked_panel_2.visible = false
	locked_panel_1.rect_position = Vector2(-100,0)
	locked_panel_2.rect_position = Vector2(-100,0)
	locked_panel_1.rect_size = Vector2(0,0)
	locked_panel_2.rect_size = Vector2(0,0)
