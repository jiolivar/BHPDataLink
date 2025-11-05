extends Control

var total_stars := 0
var current_stars := 0

func _ready():
	
	var btn_group = preload("res://game/main_screens/main_menu/ExerciseSelector/exercise_button_group.tres")
	
	for child in $TitleAndMenu/VBox/Panel/Margin/VBox/ScrollContainer/MarginContainer/GridContainer.get_children():
		child.queue_free()
	
	var dynamics = 0
	var minigames = 0
	var i = 0
	
	if Exercises.exercises_scorm_registered:
		$"%StartsNum".show()
		$"%StarIcon".show()
	else:
		$"%StartsNum".hide()
		$"%StarIcon".hide()
	
	
	for exercise_data in Exercises.exercises:
		var btn_inst := preload("res://game/main_screens/main_menu/ExerciseSelector/ExerciseButton.tscn").instance()
		$TitleAndMenu/VBox/Panel/Margin/VBox/ScrollContainer/MarginContainer/GridContainer.add_child(btn_inst)
		if exercise_data["type"] == "Dynamic":
			if exercise_data.has("complete_name"):
				btn_inst.set_text(exercise_data["complete_name"])
			else:
				btn_inst.set_text("Dinamica " + str(dynamics + 1))
			dynamics += 1
		else:
			if exercise_data.has("complete_name"):
				btn_inst.set_text(exercise_data["complete_name"])
			else:
				btn_inst.set_text("Minijuego " + str(minigames + 1))
			#btn_inst.set_alt(true)
			minigames += 1
		btn_inst.exercise_index = i
		
		if Exercises.exercises_scorm_registered:
			var result = ScormWrapper.get_exercise_prop(exercise_data["id"], ScormWrapper.ExerciseModel_Result)
			var points = ScormWrapper.get_exercise_prop(exercise_data["id"], ScormWrapper.ExerciseModel_Score)
			
			if result is String and result == ScormWrapper.ExerciseResult_Incompleted:
				btn_inst.set_alt(true)
				btn_inst.set_status(0)
			elif result == ScormWrapper.ExerciseResult_Completed:
				btn_inst.show_stars(true)
				btn_inst.set_points(int(points))
				current_stars += int(points)
				btn_inst.set_status(1 if points >= 3 else 2)
			
			total_stars += 3
		
		if Exercises.all_exercises_unlocked:
			btn_inst.set_status(0)
		
		#btn_inst.get_node("Start").group = btn_group
		
		i += 1
	
	
	if Exercises.exercises_scorm_registered:
		$"%StartsNum".text = str(current_stars) + "/" + str(total_stars)


func _on_Return_pressed():
	$"%AudioStreamPlayer".play()
	Transition.change_scene( "res://game/main_screens/main_menu/main_menu.tscn" )


func _on_Start_pressed():
	pass # Replace with function body.


