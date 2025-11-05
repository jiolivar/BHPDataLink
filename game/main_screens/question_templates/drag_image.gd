tool

extends BaseQuestionPanel

class_name DragImage

var total_correct := 0
var total_wrong := 0
var total_elements := 0

func _ready():
	_search_elements($"%CorrectElements", true)
	_search_elements($"%IncorrectElements", false)
	print(total_elements)
	
	connect("notify_end", self, "_on_notify_end")
	

func _search_elements(node, correct):
	if node:
		if node is DragableElement:
			if correct:
				total_elements = total_elements+1
			node.connect("notify_correct", self, "_correct")
			node.connect("notify_wrong", self, "_wrong")
		for child in node.get_children():
			_search_elements(child, correct)

func _correct():
	total_correct = total_correct+1
	if total_elements == total_correct:
		#print("wr: ", total_wrong)
		$"%PopUp".star_count = max(0,3-total_wrong)
		$"%PopUp".show()
		Signals.emit_signal("exercise_win", $"%PopUp".star_count, 0)


func _wrong():
	total_wrong = total_wrong+1

func _on_PopUp_button_pressed():
	end()


func _on_notify_end():
	Transition.change_scene(Main.advance_exercise_and_get_next())

