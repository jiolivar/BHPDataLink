extends "res://exercises/tutorial/tutorial_1.gd"

signal hook_start(trigger_data)
signal hook_trigger(hook)

var timebox_line : LineEdit
var timebox_button : Button
var window_4_close : Button

var addrecord_line : LineEdit
var addrecord_button : Button
var window_3_close : Button

var trigger_data : Dictionary

func _ready():
	
	Signals.connect("exercise_win", self, "_on_exercise_win")
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$"%EvaluationPanel".load_evaluation()
	
	
	
	pass



func _on_Main_hook_start(_trigger_data):
	
	trigger_data = _trigger_data
	
	if trigger_data["hook"] == "TimeBox":
		timebox_line = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_4_Container/Tutorial_4/MarginContainer/Control/VBoxContainer/MarginContainer/Panel2/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/TimeTextBox")
		timebox_button = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_4_Container/Tutorial_4/MarginContainer/Control/VBoxContainer/MarginContainer/Panel2/MarginContainer/VBoxContainer/HBoxContainer/RefreshButton")
		window_4_close = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_4_Container/Tutorial_4/MarginContainer/Control/VBoxContainer/CloseBar/HBoxContainer/CloseButton")
		
		#window_4_close.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tutorial_4_close_enable = false
		
		timebox_button.connect("pressed", self, "_on_timebox_pressed")
	
	elif trigger_data["hook"] == "AddRecord":
		addrecord_line = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_3_Container/Tutorial3/MarginContainer/Control/VBoxContainer/MarginContainer2/HBoxContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/UserContact/Panel/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/DescriptionTextBox")
		addrecord_button = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_3_Container/Tutorial3/MarginContainer/Control/VBoxContainer/MarginContainer2/HBoxContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/UserContact/HBoxContainer4/AddRecordButton")
		window_3_close = get_tree().get_root().get_node_or_null("/root/MainTutorial1/Tutorial_1/Tutorial_3_Container/Tutorial3/MarginContainer/Control/VBoxContainer/CloseBar/HBoxContainer/CloseButton")
		
		#window_3_close.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tutorial_3_close_enable = false
		
		addrecord_button.connect("pressed", self, "_on_addrecord_pressed")


func _on_timebox_pressed():
	yield(get_tree(), "idle_frame")
	if timebox_line.text == "00:00:00":
		emit_signal("hook_trigger", "TimeBox")


func _on_addrecord_pressed():
	if addrecord_line.text != "":
		emit_signal("hook_trigger", "AddRecord")


func _on_tutorial_3_close() -> void:
	._on_tutorial_3_close()
	if tutorial_3_close_enable:
		return
	$"%PopUp2".restart()
	$"%PopUp2".show()


func _on_tutorial_4_close() -> void:
	._on_tutorial_4_close()
	if tutorial_4_close_enable:
		return
	$"%PopUp2".restart()
	$"%PopUp2".show()


func _on_EvaluationPanel_evaluation_ended(score, total):
	
	Signals.emit_signal("exercise_win", clamp(3 - (total - score), 0, 3), 0)
	print("score: ", score)


func _on_exercise_win(points, total_time):
	$"%PopUp".star_count = points
	$"%PopUp".show()


func _on_PopUp_button_pressed():
	Transition.change_scene(Main.advance_exercise_and_get_next())
