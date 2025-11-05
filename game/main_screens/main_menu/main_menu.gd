extends Control

const anim_speed = 0.6

func _ready():
	
#	if Main.get_completed_all_exercises():
#		if OS.has_feature("TruckDriving"):
#			$TitleAndMenu.rect_scale = Vector2(0.0,0.0)
#			$PopUp.show()
#			Main.reset_completed_all_exercises()
#		else:
#			pass
	
	$"%Advance".hide()
	$"%Approved".hide()
	
	if Exercises.exercises_setup_complete:
		update_advance()
	else:
		Exercises.connect("exercises_setup_completed", self, "update_advance")
	


func _on_Start_pressed():
	Transition.change_scene(Main.start_excercises_and_get())
	$"%AudioStreamPlayer".play()


func _on_LevelSelector_pressed():
	Transition.change_scene("res://game/main_screens/main_menu/ExerciseSelector/exercise_selector.tscn")
	$"%AudioStreamPlayer".play()


func _on_PopUp_button_pressed():
	
#	if OS.has_feature("scorm"):
#		if ScormWrapper.ScormInterface != null and ScormWrapper.ScormInterface.ScormInterfaceConfig.end_url != "":
#			ScormWrapper.ScormInterface.ScormProcessFinish()
#			yield(get_tree().create_timer(0.6), "timeout")
#			if ScormWrapper.ScormInterface.ScormInterfaceConfig.end_url_on_parent != null and ScormWrapper.ScormInterface.ScormInterfaceConfig.end_url_on_parent:
#				JavaScript.get_interface("window").parent.location.replace(ScormWrapper.ScormInterface.ScormInterfaceConfig.end_url)
#			else:
#				JavaScript.get_interface("window").location.replace(ScormWrapper.ScormInterface.ScormInterfaceConfig.end_url)
#			return
#
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($TitleAndMenu,"rect_scale",Vector2.ONE,anim_speed).from(Vector2.ZERO)
	yield(tween, "finished")
	pass


func update_advance() -> void:
	
	$"%Advance".show()
	
	var advance : float = clamp(ScormWrapper.advance, 0.0, 1.0)
	$"%Advance".text = str(floor(advance * 100.0)) + "% completado"
	if advance >= ScormWrapper.COMPLETE_EXERCISES_VALUE:
		$"%Approved".show()
	
	if Main.is_first_time and advance < ScormWrapper.COMPLETE_EXERCISES_VALUE:
		$TitleAndMenu.rect_scale = Vector2(0.0,0.0)
		$FirstTimePopUp.text = $FirstTimePopUp.text.format({ "approved_score" : str(floor(ScormWrapper.COMPLETE_EXERCISES_VALUE * 100.0)) })
		$FirstTimePopUp._apply_settings()
		$FirstTimePopUp.show()
		Main.is_first_time = false
	elif Exercises.should_show_completed_message_on_next_main:
		$TitleAndMenu.rect_scale = Vector2(0.0,0.0)
		$CompletedPopUp.text = $CompletedPopUp.text.format({ "score" : str(floor(advance * 100.0)), "approved_score" : str(floor(ScormWrapper.COMPLETE_EXERCISES_VALUE * 100.0)) })
		$CompletedPopUp._apply_settings()
		$CompletedPopUp.show()
		Exercises.should_show_completed_message_on_next_main = false
	elif Exercises.should_show_retry_message_on_next_main:
		$TitleAndMenu.rect_scale = Vector2(0.0,0.0)
		$RetryPopUp.text = $RetryPopUp.text.format({ "fail_score" : str(floor(Exercises.fail_score * 100.0)), "approved_score" : str(floor(ScormWrapper.COMPLETE_EXERCISES_VALUE * 100.0)) })
		$RetryPopUp._apply_settings()
		Exercises.fail_score = 0.0
		$RetryPopUp.show()
		Exercises.should_show_retry_message_on_next_main = false
