extends Node

var exercises_scorm_registered := false


signal exercises_setup_completed()
var exercises_setup_complete := false

var all_exercises_completed := false
var should_show_completed_message_on_next_main := false
var should_show_retry_message_on_next_main := false
var need_reset_all_exercises := false
var all_exercises_unlocked := false
var fail_score := 0.0

# Question1 - Minigame 1
var exercises := [
	{
		"complete_name": "Introduccion",
		"id": "Slide1", "description" : "Slide 1", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/SlideIntro01.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Definiciones \nTUM",
		"id": "Tutorial1", "description" : "Tutorial 1", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/DefTumExplainSlide.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Codigos de \nProcesos",
		"id": "Tutorial2", "description" : "Tutorial 2", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/UnshceduledProcessDowntimeSlide.tscn", "type" : "Dynamic", 
	},{
		"complete_name": "Modulo 1\nDinamica 1",
		"id": "Dynamic1", "description" : "Question 1", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/1_identifycorrect.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 2",
		"id": "Dynamic2", "description" : "Question 2", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/2_connecting_pairs.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 3",
		"id": "Dynamic3", "description" : "Question 3", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/3_truefalsesequence.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 4",
		"id": "Dynamic4", "description" : "Question 4", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/4_connecting_pairs.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 5",
		"id": "Dynamic5", "description" : "Question 5", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/5_sorting_elements.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 6",
		"id": "Dynamic6", "description" : "Question 6", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/6_identify_corcect_image.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 7",
		"id": "Dynamic7", "description" : "Question 7", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/7_identify_elements.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 8",
		"id": "Dynamic8", "description" : "Question 8", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/8_identify_elements_image.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 9",
		"id": "Dynamic9", "description" : "Question 9", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/9_truefalsesequence.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 10",
		"id": "Dynamic10", "description" : "Question 10", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/10_drag_elements.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 11",
		"id": "Dynamic11", "description" : "Question 11", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/11_sorting_elements.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 12",
		"id": "Dynamic12", "description" : "Question 12", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/12_identify_elements.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 13",
		"id": "Dynamic13", "description" : "Question 13", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/13_connecting_pairs.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 14",
		"id": "Dynamic14", "description" : "Question 14", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/14_connecting_pairs_images.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 15",
		"id": "Dynamic15", "description" : "Question 15", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/15_identifycorrect.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 16",
		"id": "Dynamic16", "description" : "Question 16", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/16_connecting_pairs_images.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 17",
		"id": "Dynamic17", "description" : "Question 17", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/17_truefalsesequence.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 18",
		"id": "Dynamic18", "description" : "Question 18", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/18_identify_correct.tscn", "type" : "Dynamic", 
	},
	{
		"complete_name": "Modulo 1\nDinamica 19",
		"id": "Dynamic19", "description" : "Question 19", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/Dynamics/19_drag_elements.tscn", "type" : "Dynamic", 
	},{
		"complete_name": "Tutorial \nInteractivo",
		"id": "Tutorial 3", "description" : "Tutorial 3", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/tutorial/tutorial_Tum1.tscn", "type" : "Dynamic", 
	},{
		"complete_name": "Dinamica 1\nInteractiva",
		"id": "Dynamic20", "description" : "Question 20", "exerciseType" : ScormWrapper.ExerciseType_Default,
		"correct_responses" : [], "weight" : 1.0, 
		"path" : "res://exercises/HaulRouteEval.tscn", "type" : "Dynamic", 
	}
	
]


func _ready():
	
	if OS.has_feature("scorm"):
		if ScormWrapper.setup_complete:
			register_scorm_exercises()
		else:
			ScormWrapper.connect("setup_completed", self, "register_scorm_exercises")
		
		yield(get_tree(), "idle_frame")
		
	Signals.connect("exercise_win", self, "_on_exercise_win")


func register_scorm_exercises() -> void:
	for exercise_data in exercises:
		ScormWrapper.register_exercise(
			exercise_data["id"], exercise_data["exerciseType"], 
			exercise_data["description"], exercise_data["correct_responses"], exercise_data["weight"], [0.0, 3.0]
			)
	
	exercises_scorm_registered = true
	
	ScormWrapper.end_register_exercises()
	
	check_all_exercises_completed()
	
	if all_exercises_completed :
		if ScormWrapper.advance >= ScormWrapper.COMPLETE_EXERCISES_VALUE:
			all_exercises_unlocked = true
		else:
			all_exercises_unlocked = false
	
	exercises_setup_complete = true
	emit_signal("exercises_setup_completed")


func _on_exercise_win(points, total_time) -> void:
	print(">> Exercise Win : ", Main.current_exercise_id, " with ", points, " points")
	
	if OS.has_feature("scorm"):
		
		var exercises_updated := false
		var new_exercise_just_finished := false
		
		var status = ScormWrapper.get_exercise_prop(Main.current_exercise_id, ScormWrapper.ExerciseModel_Result)
		var current_points = ScormWrapper.get_exercise_prop(Main.current_exercise_id, ScormWrapper.ExerciseModel_Score)
		if status == ScormWrapper.ExerciseResult_Incompleted or points > current_points:
			if status == ScormWrapper.ExerciseResult_Incompleted:
				new_exercise_just_finished = true
			ScormWrapper.set_exercise_score_and_result(Main.current_exercise_id, points, ScormWrapper.ExerciseResult_Completed)
			ScormWrapper.recalculate_total_result()
			ScormWrapper.update_total_result()
			exercises_updated = true
	
		if exercises_updated:
			check_all_exercises_completed()
			if all_exercises_completed and new_exercise_just_finished:
				if ScormWrapper.advance >= ScormWrapper.COMPLETE_EXERCISES_VALUE:
					should_show_completed_message_on_next_main = true
					should_show_retry_message_on_next_main = false
					need_reset_all_exercises = false
					all_exercises_unlocked = true
				else:
					should_show_completed_message_on_next_main = false
					should_show_retry_message_on_next_main = true
					need_reset_all_exercises = true
					all_exercises_unlocked = false


func get_next_exercise(current_exercise_index : int) -> int:
	if OS.has_feature("scorm"):
		if should_show_completed_message_on_next_main or should_show_retry_message_on_next_main:
			return exercises.size()
		
		if all_exercises_unlocked:
			return current_exercise_index + 1
		
		for index in range(current_exercise_index + 1, exercises.size()):
			var id = exercises[index]["id"]
			if ScormWrapper.get_exercise_prop(id, ScormWrapper.ExerciseModel_Result) != ScormWrapper.ExerciseResult_Completed:
				return index
		
		for index in range(0, current_exercise_index):
			var id = exercises[index]["id"]
			if ScormWrapper.get_exercise_prop(id, ScormWrapper.ExerciseModel_Result) != ScormWrapper.ExerciseResult_Completed:
				return index
		
		return exercises.size()
	else:
		return current_exercise_index + 1


func can_enter_exercise(exercise_index : int) -> bool:
	if OS.has_feature("scorm"):
		if all_exercises_unlocked:
			return true
		
		var id = exercises[exercise_index]["id"]
		if ScormWrapper.get_exercise_prop(id, ScormWrapper.ExerciseModel_Result) != "completed":
			return true
		if ScormWrapper.get_exercise_prop(id, ScormWrapper.ExerciseModel_Score) == 3:
			return true
		return false
	else:
		return true


func check_all_exercises_completed() -> void:
	for i in range(0, exercises.size()):
		if ScormWrapper.get_exercise_prop(exercises[i]["id"], ScormWrapper.ExerciseModel_Result) != "completed":
			all_exercises_completed = false
			return
	all_exercises_completed = true


func reset_all_exercises() -> void:
	fail_score = ScormWrapper.advance
	
	for i in range(0, exercises.size()):
		var exercise_id = exercises[i]["id"]
		ScormWrapper.set_exercise_score_and_result(exercises[i]["id"], 0, ScormWrapper.ExerciseResult_Incompleted)
	
	ScormWrapper.recalculate_total_result()
	ScormWrapper.update_total_result()
	
	need_reset_all_exercises = false
