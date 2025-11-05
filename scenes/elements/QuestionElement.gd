extends VBoxContainer

var correct_alternative := -1 #-1 means no question, just a step
var selected_alternative := -1
var active_question := false
var scrolls_done = {}
var trigger_element : CanvasItem
var focus_element := false
var question_id := 0
var feedback : Array
var is_in_feedback := false

var trigger_data := {}

var is_hook = false

onready var alternative_template = preload("res://scenes/elements/Alternative.tscn")

#onready var main_panel = get_tree().get_root().get_node("/root/Main/VBoxContainer/Control/HBoxContainer")

signal next_pressed
signal wrong_pressed


func _ready():
	pass # Replace with function body.

func init_question(question):
	print("INIT")
	$"%Title".text = question["title"]
	if question.has("question"):
		$"%Question".text = question["question"]
		$"%Question".visible = false if question["question"] == "" else true 
		print("QUESTION")
	else:
		$"%Question".visible = false
	if question.has("correct_alternative"):
		correct_alternative = question["correct_alternative"]
		#ScormWrapper.register_exercise( "QuestionID_" + str(question_id), "Pregunta", "", [0.0], 0.0, [0.0, 1.0] )
		pass
		
	if question.has("alternatives"):
		var button_group = ButtonGroup.new() # to make it radio button checkboxes have to be in the same group
		for alternative in question["alternatives"]:
			var new_alternative = alternative_template.instance()
			$"%AnswerContainer".add_child(new_alternative)
			new_alternative.get_node("CheckBox/Label").text = alternative
			new_alternative.get_node("CheckBox").group = button_group
			new_alternative.get_node("CheckBox").connect("pressed", self, "_on_answer_selected", [$"%AnswerContainer".get_child_count()-1])
			
	if question.has("trigger"):
		$"%Title".size_flags_vertical = Control.SIZE_EXPAND_FILL
		$"%HBoxContainer".visible = false
		$"%NextButton".visible = false
		
		trigger_data = question["trigger"]
		
		
	
	if question.has("feedback"):
		feedback = question["feedback"]


func connect_trigger() -> void:
	if trigger_data.empty():
		return
	
	trigger_element = get_tree().get_root().get_node_or_null(trigger_data["element"])
	
	var flag = trigger_data["flag"]
	if flag is int and flag == -1:
		focus_element = true
	
	if trigger_data.has("hook"):
		trigger_element = get_tree().get_root().get_node_or_null(trigger_data["element"])
		if trigger_element == null:
			return
		trigger_element.emit_signal("hook_start", trigger_data)
		trigger_element.connect("hook_trigger", self, "_emit_next", [flag])
		is_hook = true
	else:
		print("Trigger element:", trigger_element)
		if trigger_element == null:
			return
		if trigger_element is OptionButton:
			trigger_element.connect("item_selected", self, "_emit_next", [flag])
		elif trigger_element is BaseButton:
			trigger_element.connect("pressed", self, "_emit_next", [0, flag])
		if trigger_element is MenuButton:
			trigger_element.connect("about_to_show", self, "_emit_next", [0, flag])
		if trigger_element is PopupMenu:
			trigger_element.connect("id_pressed", self, "_emit_next", [flag])
			#trigger_element.popup_exclusive = true
			#trigger_element.set_hide_on_window_lose_focus(false)
		if trigger_element is Tree:
			trigger_element.connect("item_edited", self, "_emit_next", [0, flag])
		if trigger_element is LineEdit:
			trigger_element.connect("text_changed", self, "_emit_next", [flag])
		if trigger_element is Tabs:
			trigger_element.connect("tab_clicked", self, "_emit_next", [flag])


func _process(delta):
	pass
#	if active_question and trigger_element and focus_element:
#		var area_element = trigger_element.get_global_rect().get_area()
#		var intersection_area = intersection(main_panel.get_global_rect(), trigger_element.get_global_rect()).get_area()
#		var area_ratio = intersection_area/area_element
#		if area_ratio > 0.7: #is visible enough
#			_next_question()


func activate_question():
	active_question = true
	if trigger_element:
		trigger_element.mouse_filter = Control.MOUSE_FILTER_STOP
	connect_trigger()


func _on_NextButton_pressed():
	_next_question()


func _emit_next( value, flag ):
	if not active_question:
		return
	print("Flag: ", flag,"Valor: " ,value)
	
	if is_hook:
		print(value)
		if value != trigger_data["hook"]:
			return
	else:
		if value is String and flag is String:
			if value.to_lower() != flag.to_lower():
				return
		elif (value is int or value is float) and (flag is int or flag is float):
			if value != flag:
				return
	
	if active_question:
		_next_question()


func _next_question():
	if feedback == null or feedback.empty():
		#if correct_alternative != selected_alternative:
		#	emit_signal("wrong_pressed")
		#	return
		
		active_question = false
		if OS.has_feature("scorm") and correct_alternative != -1: #-1 means no question, just a step
			#ScormWrapper.set_exercise_score_and_result( "QuestionID_" + str(question_id), int(correct_alternative == selected_alternative), ScormWrapper.ExerciseResult_Completed )
			pass
			
		emit_signal("next_pressed")
	else:
		if is_in_feedback:
			emit_signal("next_pressed")
		else:
			
			active_question = false
			if OS.has_feature("scorm") and correct_alternative != -1: #-1 means no question, just a step
				#ScormWrapper.set_exercise_score_and_result( "QuestionID_" + str(question_id), int(correct_alternative == selected_alternative), ScormWrapper.ExerciseResult_Completed )
				pass
			$"%AnswerContainer".hide()
			$"%FeedbackContainer".show()
			$"%Feedback".text = feedback[0 if correct_alternative == selected_alternative else 1]
			is_in_feedback = true


func _on_answer_selected(button_index):
	selected_alternative = button_index
	$"%NextButton".disabled = false



#Rect2 functions not implemented yet in Godot 3.5
func min_vec(vec_1 : Vector2, vec_2 : Vector2) -> Vector2:
	return Vector2(min(vec_1.x, vec_2.x), min(vec_1.y, vec_2.y))
	
func max_vec(vec_1 : Vector2, vec_2 : Vector2) -> Vector2:
	return Vector2(max(vec_1.x, vec_2.x), max(vec_1.y, vec_2.y))

func intersection(rect_1 : Rect2, rect_2 : Rect2) -> Rect2:
	var new_rect : Rect2 = rect_2;

	if !rect_1.intersects(new_rect):
		return Rect2(0,0,0,0)

	new_rect.position = max_vec(rect_2.position, rect_1.position)

	var p_rect_end : Vector2 = rect_2.position + rect_2.size
	var end : Vector2 = rect_1.position + rect_1.size

	new_rect.size = min_vec(p_rect_end, end) - new_rect.position

	return new_rect
