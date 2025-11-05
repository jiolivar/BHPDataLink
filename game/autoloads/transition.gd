extends CanvasLayer

var next_scene : String
var transition_parameters := {}

var quick_animating = false

func change_scene(scene):
	$Curtain/Anim.play("show")
	next_scene = scene
	$"%Tween".interpolate_method(self, "change_audio_bus_volume", 0.0, -80.0, 1.0)
	$"%Tween".start()
	

func change_scene_params(scene,params):
	change_scene(scene)
	transition_parameters = params

func _on_Anim_animation_finished(anim_name):
	if anim_name == "show" and not quick_animating:
		if OS.has_feature("scorm"):
			if Exercises.need_reset_all_exercises:
				Exercises.reset_all_exercises()
				
			if ScormWrapper.setup_complete:
				ScormWrapper.commit()
		
		get_tree().change_scene(next_scene)
		$Curtain/Anim.play("hide")
		$"%Tween".interpolate_method(self, "change_audio_bus_volume", -80.0, 0.0, 1.0)
		$"%Tween".start()
		
func change_audio_bus_volume(value: float):
	var index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, value)


func quick_animate() -> void:
	quick_animating = true
	$Curtain/Anim.play("show")
	yield(get_tree().create_timer(1.2), "timeout")
	$Curtain/Anim.play("hide")
	quick_animating = false
