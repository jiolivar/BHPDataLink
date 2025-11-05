extends CanvasLayer

const file_path = "res://sequence.txt"
onready var save_handle = File.new()

var tracking := false
var sequence = []
var text_edit = null
var current_dict = {}
var debug_clicked := false

var last_step := -1

signal start_tracking

func _ready():
	load_sequence()
	if OS.is_debug_build():
		_search_child(get_tree().get_root())

func _process(delta):
	if OS.is_debug_build():
		if Input.is_action_just_pressed("debug_clicks"):
			debug_clicked = !debug_clicked
			if debug_clicked:
				_search_child(get_tree().get_root())
		if Input.is_action_just_pressed("save_sequence"):
			print("SAVE")
			save_sequence()
		if Input.is_action_just_pressed("clear_sequence"):
			print("CLEAR")
			sequence.clear()
		if Input.is_action_just_pressed("start_stop_track_sequence"):
			emit_signal("start_tracking")
			_search_child(get_tree().get_root())
			print("TRACKING")
			tracking = !tracking
		if Input.is_action_just_pressed("next_step"):
			print("NEXT_STEP")
			if text_edit:
				current_dict["text"] = text_edit.text
				sequence.push_back(current_dict.duplicate())
				print(current_dict)
				get_tree().get_root().remove_child(text_edit)
				text_edit.queue_free()


func _search_child(_node : Node):
	for child in _node.get_children():
		_search_child(child)
	#if _node is OptionButton:
	#	_node.connect("item_selected", self, "_control_pressed", [_node])
	if _node is BaseButton:
		_node.connect("pressed", self, "_control_pressed", [0,_node])
	if _node is MenuButton:
		_node.connect("about_to_show", self, "_search_child", [_node])
	if _node is PopupMenu:
		_node.connect("id_pressed", self, "_control_pressed", [_node])
	if _node is Tree:
		_node.connect("item_edited", self, "_control_pressed", [0,_node])
		_node.connect("item_collapsed", self, "_control_pressed_tree", [_node])
	if _node is LineEdit:
		_node.connect("text_entered", self, "_control_pressed", [_node])
	if _node is Tabs:
		_node.connect("tab_clicked", self, "_control_pressed", [_node])
	

func _control_pressed(_flag, _element : Control):
	if tracking or debug_clicked:
		current_dict.clear()
		if _element is Tree:
			var item : TreeItem = _element.get_selected()
			var rect : Rect2 = item.get_meta("__focus_rect")
			current_dict["rect"] = rect
		elif _element is Tabs:
			if tracking:
				print(_element.get_tab_rect(_element.current_tab))
			current_dict["rect"] = _element.get_tab_rect(_element.current_tab)

		current_dict["element"] = _element.get_path()
		yield(get_tree().create_timer(0.2), "timeout")
		current_dict["flag"] = _flag
			
		if tracking:
			print(_element, " - ", _flag)
			_show_tracker_text_edit()
		
		if debug_clicked:
			print(current_dict)

func _control_pressed_tree(item : TreeItem, _element : Control):
	if tracking or debug_clicked:
		if not item.collapsed:
			current_dict.clear()
			var rect : Rect2 = item.get_meta("__focus_rect")
			current_dict["rect"] = rect
			current_dict["element"] = _element.get_path()
			current_dict["flag"] = 0
			if tracking:
				_show_tracker_text_edit()
			
		if debug_clicked:
			print(current_dict)

func _show_tracker_text_edit():
	text_edit = TextEdit.new()
	text_edit.name = "TextEditElementTracker"
	text_edit.rect_global_position = Vector2(500,300)
	text_edit.rect_size = Vector2(500,300)
	text_edit.modulate = Color(1,1,1,0.5)
	add_child(text_edit)
	#get_tree().get_root().get_node("Main/TutorialCanvas").add_child(text_edit)
	text_edit.grab_focus()
	_search_child(get_tree().get_root())

func save_sequence():
	var dict = {}
	dict["tut1"] = sequence
	save_handle.open(file_path, File.WRITE)
	save_handle.store_line(JSON.print(dict, "\t"))
	save_handle.close()

func load_sequence():
	save_handle.open(file_path, File.READ)
	var dict = parse_json(save_handle.get_as_text())
	save_handle.close()
	if dict and dict.has("tut1"):
		sequence = dict["tut1"]
		#print(sequence)
