extends Control

class_name TrueFalseSequence

onready var true_false_panel_template = preload("res://game/main_screens/question_templates/Elements/true_false_panel.tscn")

export var title := "Responda VERDADERO o FALSO"
export var enunc := ""
var questions : Dictionary
var true_false_panels = []
var current_panel := 0

var total_wrong := 0

func _ready():
	yield(get_tree(),"idle_frame")
	_create_panels()
	if true_false_panels.size():
		yield(get_tree().create_timer(0.3), "timeout")
		true_false_panels[0].show()

func _create_panels():
	for i in range(questions.size()):
		var new_panel = true_false_panel_template.instance()
		new_panel.connect("notify_end", self, "_next_panel")
		new_panel.connect("emit_wrong", self, "_wrong")
		new_panel.title = title
		new_panel.enunc = enunc
		new_panel.question = questions[i]["Question"]
		new_panel.currect_answer = questions[i]["Answer"]
		add_child(new_panel)
		true_false_panels.push_back(new_panel)
		if i > 0:
			#so bg music wont play multiple times
			new_panel.remove_child(new_panel.get_node("AudioStreamPlayer"))


func _wrong():
	total_wrong = total_wrong+1
	
func _next_panel():
	current_panel = current_panel+1
	if current_panel == true_false_panels.size():
		$"%PopUp".star_count = max(0,3-total_wrong)
		$"%PopUp".show()
		Signals.emit_signal("exercise_win", $"%PopUp".star_count, 0)
	else:
		yield(get_tree().create_timer(0.4), "timeout")
		true_false_panels[current_panel].show()
	
	
