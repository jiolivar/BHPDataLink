extends Node

var previus_exercises := {}
var current_exercises := {}
var next_exercise_index := 0
var total_index := 0

var previus_total_result := 0.0
var current_total_result := 0.0

var exercises_completed := 0

var total_result_bounds := [0.0,100.0]

const ExerciseType_TrueFalse = "true-false"
const ExerciseType_Choice = "choice"
const ExerciseType_FillIn = "fill-in"
const ExerciseType_LongFillIn = "long-fill-in"
const ExerciseType_Matching = "matching"
const ExerciseType_Performance = "performance"
const ExerciseType_Sequencing = "sequencing"
const ExerciseType_Likert = "likert"
const ExerciseType_Numeric = "numeric"
const ExerciseType_Other = "other"

var ExerciseType_Default = ExerciseType_Other

const ExerciseResult_Correct = "correct"
const ExerciseResult_Incorrect = "incorrect"
const ExerciseResult_Unanticipated = "unanticipated"
const ExerciseResult_Neutral = "neutral"

const ExerciseResult_Completed = "completed"
const ExerciseResult_Incompleted = "incomplete"

const ExerciseModel_IdName = "ID_NAME"
const ExerciseModel_Index = "INDEX"
const ExerciseModel_Type = "TYPE"
const ExerciseModel_Description = "DESCRIPTION"
const ExerciseModel_Response = "RESPONSE"
const ExerciseModel_CorrectResponses = "CORRECT_RESPONSES"
const ExerciseModel_Weight = "WEIGHT"
const ExerciseModel_Time = "TIME"
const ExerciseModel_Result = "RESULT"

const ExerciseModel_Score = "SCORE"
const ExerciseModel_ScoreBounds = "SCORE_BOUNDS"


const CourseStatus_Passed = "passed"
const CourseStatus_Failed = "failed"
const CourseStatus_Unknown = "unknown"


var ScormInterface : JavaScriptObject

signal setup_completed()
var setup_complete := false
var advance := 0.0

const COMPLETE_EXERCISES_VALUE := 0.85

# First wait to setup_complete = true or signal setup_completed
# Then register exercises with register_exercise(...)
# Then call end_register_exercises()

enum ScormVersion {
	_1_2,
	_2004
}

var version : int = ScormVersion._1_2

func _init():
	if version == ScormVersion._1_2:
		ExerciseType_Default = ExerciseType_Performance


func _ready():
	if OS.has_feature("scorm"):
		print("[SCORM WRAPPER] Running with SCORM")
		ScormInterface = JavaScript.get_interface("ScormInterface")
		
		if ScormInterface != null:
			print("[SCORM WRAPPER] SCORM Interface created")
			print("[SCORM WRAPPER] Config : ", (ScormInterface.ScormInterfaceConfig.end_url))
		_setup()


func _setup() -> void:
	
	_map_previus_exercises()
	
	print("[SCORM WRAPPER] Setup completed")
	setup_complete = true
	emit_signal("setup_completed")


func end_register_exercises() -> void:
	if ScormInterface == null:
		return
	
	var check_exercises_count : int = 0
	
	if version == ScormVersion._1_2:
		check_exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.objectives._count"))
	else:
		check_exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.interactions._count"))
	
	print("[SCORM WRAPPER] Checked Exercises : ", check_exercises_count, " exercises.")
	
	total_index = next_exercise_index
	if version == ScormVersion._1_2:
		var id = ScormInterface.ScormProcessGetValue("cmi.objectives." + str(total_index) + ".id")
		
		if id != "TOTAL":
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(total_index) + ".id", "TOTAL")
			
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(total_index) + ".score.raw", previus_total_result)
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(total_index) + ".score.min", total_result_bounds[0])
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(total_index) + ".score.max", total_result_bounds[1])
			print("[SCORM WRAPPER] Register o Updated Total result with ", previus_total_result)
	else:
		
		var id = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(total_index) + ".id")
		
		if id != "TOTAL":
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".id", "TOTAL")
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".type", ExerciseType_Default)
			
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".student_response", "")
			
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".description", "TOTAL POINTS")
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".learner_response", "")
			
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".correct_responses.0.pattern", "")
			
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".weighting", 0.0)
			#ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".timestamp", time)
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".result", previus_total_result)
			print("[SCORM WRAPPER] Register o Updated Total result with ", previus_total_result)
	
	recalculate_total_result()
	print("[SCORM WRAPPER] Previus result: ", previus_total_result, " and new result: ", current_total_result)
	update_total_result()


func register_exercise(id_name : String, type : String, description : String, correct_responses : Array, weight : float, score_bounds : Array) -> void:
	if ScormInterface == null:
		return
	
	current_exercises[id_name] = {}
	
	if version == ScormVersion._1_2:
		current_exercises[id_name][ExerciseModel_IdName] = id_name
		current_exercises[id_name][ExerciseModel_Index] = next_exercise_index
		current_exercises[id_name][ExerciseModel_ScoreBounds] = score_bounds
	else:
		current_exercises[id_name][ExerciseModel_IdName] = id_name
		current_exercises[id_name][ExerciseModel_Index] = next_exercise_index
		current_exercises[id_name][ExerciseModel_Type] = type
		current_exercises[id_name][ExerciseModel_Description] = description
		current_exercises[id_name][ExerciseModel_CorrectResponses] = correct_responses	
		current_exercises[id_name][ExerciseModel_Weight] = weight
		#current_exercises[ExerciseModel_Time] = time
	
	var id_name_exists : bool = previus_exercises.has(id_name)
	
	if not id_name_exists:
		if version == ScormVersion._1_2:
			current_exercises[id_name][ExerciseModel_Score] = 0.0
			current_exercises[id_name][ExerciseModel_Result] = ExerciseResult_Incompleted
			
			var r = _register_exercise_at_index(next_exercise_index, id_name, "", "", "", [], 1.0, 0, current_exercises[id_name][ExerciseModel_Result], current_exercises[id_name][ExerciseModel_Score], score_bounds)
			if r:
				print("[SCORM WRAPPER] Registered new exercise: ", id_name, " at index : ", next_exercise_index)
			
		else:
			current_exercises[id_name][ExerciseModel_Response] = ""
			current_exercises[id_name][ExerciseModel_Result] = ExerciseResult_Unanticipated
		
			var r = _register_exercise_at_index(next_exercise_index, id_name, type, description, "", correct_responses, weight, 0, current_exercises[id_name][ExerciseModel_Result], 0,score_bounds)
			if r:
				print("[SCORM WRAPPER] Registered new exercise: ", id_name, " at index : ", next_exercise_index)
	else:
		var need_update = false
		
		if version == ScormVersion._1_2:
			
			var new_score = previus_exercises[id_name][ExerciseModel_Score]
			var new_result = previus_exercises[id_name][ExerciseModel_Result]
			
			if next_exercise_index != previus_exercises[id_name][ExerciseModel_Index]:
				need_update = true
			
			current_exercises[id_name][ExerciseModel_Score] = new_score
			current_exercises[id_name][ExerciseModel_Result] = new_result
			
			if need_update:
				var r = _register_exercise_at_index(next_exercise_index, id_name, "", "", "", [], 1.0, 0, new_result, new_score, score_bounds)
				if r:
					print("[SCORM WRAPPER] Updating exercise: ", id_name)
			
		else:
			 
			var new_response = previus_exercises[id_name][ExerciseModel_Response]
			var new_result = previus_exercises[id_name][ExerciseModel_Result]
			
			if type != previus_exercises[id_name][ExerciseModel_Type] or \
				correct_responses != previus_exercises[id_name][ExerciseModel_CorrectResponses]:
				new_response = ""
				new_result = ExerciseResult_Unanticipated
				need_update = true
			
			if description != previus_exercises[id_name][ExerciseModel_Description] or \
				weight != previus_exercises[id_name][ExerciseModel_Weight] or \
				next_exercise_index != previus_exercises[id_name][ExerciseModel_Index]:
				need_update = true
			
			current_exercises[id_name][ExerciseModel_Response] = new_response
			current_exercises[id_name][ExerciseModel_Result] = new_result
			
			if need_update:
				var r = _register_exercise_at_index(next_exercise_index, id_name, type, description, new_response, correct_responses, weight, previus_exercises[id_name][ExerciseModel_Time], new_result, 0, score_bounds)
				if r:
					print("[SCORM WRAPPER] Updating exercise: ", id_name)
					
	
	next_exercise_index += 1


func get_exercise_prop(id_name : String, prop_name : String):
	if current_exercises.has(id_name) and current_exercises[id_name].has(prop_name):
		return current_exercises[id_name][prop_name]
	
	return null


func set_exercise_result(id_name : String, result) -> void:
	if current_exercises.has(id_name):
		current_exercises[id_name][ExerciseModel_Result] = result
		var index = current_exercises[id_name][ExerciseModel_Index]
		if version == ScormVersion._1_2:
			pass
		else:
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".result", result)
		print("[SCORM WRAPPER] Updating exercise result: ", id_name, " with ", result)


func set_exercise_score_and_result(id_name : String, score, result) -> void:
	if current_exercises.has(id_name):
		current_exercises[id_name][ExerciseModel_Score] = score
		current_exercises[id_name][ExerciseModel_Result] = result
		var index = current_exercises[id_name][ExerciseModel_Index]
		if version == ScormVersion._1_2:
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".score.raw", float(score))
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".status", result)
		print("[SCORM WRAPPER] Updating exercise result: ", id_name, " with ", score, " => ", result)


func commit() -> void:
	if ScormInterface == null:
		return
	if version == ScormVersion._1_2:
		var r = ScormInterface.ScormCommit()
		if r:
			print("[SCORM WRAPPER] Saved Progress")
		else:
			print("[SCORM WRAPPER] Error Saving Progress")


func finish() -> void:
	if ScormInterface == null:
		return
	if version == ScormVersion._1_2:
		ScormInterface.ScormProcessFinish()


func recalculate_total_result() -> void:
	current_total_result = 0.0
	exercises_completed = 0
	
	for id_name in current_exercises:
		var result = current_exercises[id_name][ExerciseModel_Result]
		if version == ScormVersion._1_2:
			if result == ExerciseResult_Completed:
				current_total_result += current_exercises[id_name][ExerciseModel_Score]
				exercises_completed += 1
				
		else:
			if result is int or result is float:
				current_total_result += result
				exercises_completed += 1
	
	print("[SCORM WRAPPER] Recalculated total Score: ", current_total_result, " with ", exercises_completed, " exercises completed")


func update_total_result() -> void:
	
	if version == ScormVersion._1_2:
		ScormInterface.ScormProcessSetValue("cmi.objectives." + str(total_index) + ".score.raw", current_total_result)
	else:
		ScormInterface.ScormProcessSetValue("cmi.interactions." + str(total_index) + ".result", current_total_result)
	
	advance = clamp(current_total_result * 1.0 / (current_exercises.size() * 3.0), 0.0, 1.0)
	
	if version == ScormVersion._1_2:
		ScormInterface.ScormProcessSetValue("cmi.core.score.min", 0)
		ScormInterface.ScormProcessSetValue("cmi.core.score.max", 100) 
		
		ScormInterface.ScormProcessSetValue("cmi.core.score.raw", advance * 100)
		
		if advance >= COMPLETE_EXERCISES_VALUE:
			ScormInterface.ScormProcessSetValue("cmi.core.lesson_status", "completed")
			ScormInterface.ScormProcessSetValue("cmi.core.exit", "")
		else:
			ScormInterface.ScormProcessSetValue("cmi.core.lesson_status", "incomplete")
			ScormInterface.ScormProcessSetValue("cmi.core.exit", "suspend")
	else:
		ScormInterface.ScormProcessSetValue("cmi.score.min", 0)
		ScormInterface.ScormProcessSetValue("cmi.score.max", 100) 
		
		ScormInterface.ScormProcessSetValue("cmi.score.raw", advance * 100)
		ScormInterface.ScormProcessSetValue("cmi.score.scaled", advance)
		
		ScormInterface.ScormProcessSetValue("cmi.progress_measure", advance)
		
		if advance >= COMPLETE_EXERCISES_VALUE:
			ScormInterface.ScormProcessSetValue("cmi.completion_status", "completed")
			ScormInterface.ScormProcessSetValue("cmi.success_status", CourseStatus_Passed)
		else:
			ScormInterface.ScormProcessSetValue("cmi.completion_status", "incomplete")
			ScormInterface.ScormProcessSetValue("cmi.success_status", CourseStatus_Unknown)
	
	print("[SCORM WRAPPER] New total Score: ", advance * 100)


func _register_exercise_at_index(index : int, id_name : String, type : String, description : String, response : String, correct_responses : Array, weight : float, time : int, result : String, score : float, score_bounds : Array) -> bool:
	
	if ScormInterface == null:
		return false
	
	var exercises_count : int = 0
	
	if version == ScormVersion._1_2:
		exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.objectives._count"))
	else:
		exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.interactions._count"))
	
	if index <= exercises_count:
		if version == ScormVersion._1_2:
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".id", id_name)
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".score.raw", score)
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".score.min", float(score_bounds[0]))
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".score.max", float(score_bounds[1]))
			ScormInterface.ScormProcessSetValue("cmi.objectives." + str(index) + ".status", result)
			return true
		else:
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".id", id_name)
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".type", type)
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".description", description)
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".learner_response", response)
			
			for i in range(correct_responses.size()):
				ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".correct_responses." + str(i) + ".pattern", correct_responses[i])
			
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".weighting", weight)
			#ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".timestamp", time)
			ScormInterface.ScormProcessSetValue("cmi.interactions." + str(index) + ".result", result)
			
			return true
	
	print("[SCORM WRAPPER] Failed on Create or Update exercise: ", id_name)
	return false


func _map_previus_exercises() -> void:
	if ScormInterface == null:
		return
	
	var exercises_count : int = 0
	
	if version == ScormVersion._1_2:
		exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.objectives._count"))
	else:
		exercises_count = int(ScormInterface.ScormProcessGetValue("cmi.interactions._count"))
	
	print("[SCORM WRAPPER] Found : ", exercises_count, " previous exercises.")
	
	for index in range(exercises_count):
		
		var id_name
		
		if version == ScormVersion._1_2:
			id_name = ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".id")
		else:
			id_name = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".id")
		
		if id_name == "TOTAL":
			if version == ScormVersion._1_2:
				previus_total_result = float(ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".score.raw"))
			else:
				previus_total_result = float(ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".result"))
			continue
		
		previus_exercises[id_name] = {}
		
		if version == ScormVersion._1_2:
			previus_exercises[id_name][ExerciseModel_IdName] = id_name
			previus_exercises[id_name][ExerciseModel_Index] = index
			previus_exercises[id_name][ExerciseModel_Score] = float(ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".score.raw"))
			previus_exercises[id_name][ExerciseModel_ScoreBounds] = [float(ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".score.min")), float(ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".score.max"))]
			previus_exercises[id_name][ExerciseModel_Result] = ScormInterface.ScormProcessGetValue("cmi.objectives." + str(index) + ".status")
			
		else:
			previus_exercises[id_name][ExerciseModel_IdName] = id_name
			previus_exercises[id_name][ExerciseModel_Index] = index
			previus_exercises[id_name][ExerciseModel_Type] = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".type")
			previus_exercises[id_name][ExerciseModel_Description] = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".description")
			previus_exercises[id_name][ExerciseModel_Response] = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".learner_response")
		
			var correct_responses_count = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".correct_responses._count")
			previus_exercises[id_name][ExerciseModel_CorrectResponses] = []
		
			for r_index in range(correct_responses_count):
				previus_exercises[id_name][ExerciseModel_CorrectResponses].append( ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".correct_responses." + str(r_index) + ".pattern") )
		
			previus_exercises[id_name][ExerciseModel_Weight] = float(ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".weighting"))
			#previus_exercises[ExerciseModel_Time] = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".timestamp")
			var result = ScormInterface.ScormProcessGetValue("cmi.interactions." + str(index) + ".result")
			previus_exercises[id_name][ExerciseModel_Result] = result if result == ExerciseResult_Unanticipated else int(result)
		
		print("[SCORM WRAPPER] Mapped ", previus_exercises.size(), " Exercises")
