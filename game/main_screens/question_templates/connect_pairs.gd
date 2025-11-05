tool

extends BaseQuestionPanel

var total_correct := 0
var total_wrong := 0

func _ready():
	for element in $"%Elements".get_children():
		element.connect("notify_correct", self, "_correct")
		element.connect("notify_wrong", self, "_wrong")
	
	connect("notify_end", self, "_on_notify_end")
	$PopUp.connect("button_pressed", self, "_on_PopUp_button_pressed")


func _correct():
	total_correct = total_correct+1
	if $"%Elements".get_child_count() == total_correct:
		$"%PopUp".star_count = max(0,3-total_wrong)
		$"%PopUp".show()
		Signals.emit_signal("exercise_win", $"%PopUp".star_count, 0)


func _wrong():
	total_wrong = total_wrong+1


func _on_PopUp_button_pressed():
	end()


func _on_notify_end():
	yield(get_tree().create_timer(0.5), "timeout")
	Transition.change_scene(Main.advance_exercise_and_get_next())

