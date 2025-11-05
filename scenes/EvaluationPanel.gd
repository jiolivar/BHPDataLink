extends Panel

const file_path = "res://evaluation.txt"
onready var save_handle = File.new()
onready var question_template = preload("res://scenes/elements/QuestionElement.tscn")
var evaluation = []
var current_dict = {}
var current_question = 1
var total_questions = 0

signal evaluation_ended(score, total)
signal step_changed

func load_evaluation():
	save_handle.open(file_path, File.READ)
	var dict = parse_json(save_handle.get_as_text())
	save_handle.close()
	if dict and dict.has("eval1"):
		evaluation = dict["eval1"]
		#print(evaluation)
	for question in evaluation:
		var new_question_element = question_template.instance()
		new_question_element.question_id = $"%QuestionPanel".get_child_count()
		$"%QuestionPanel".add_child(new_question_element)
		new_question_element.init_question(question)
		new_question_element.connect("next_pressed", self, "_go_to_next_question")
		new_question_element.connect("wrong_pressed", self, "_on_wrong_pressed")
		
	$"%QuestionPanel".get_current_tab_control().activate_question()
	for question in $"%QuestionPanel".get_children():
		if question.correct_alternative != -1: #-1 means no question, just a step
			total_questions += 1
	$"%Steps".text = str(current_question) + "/" + str(total_questions + 1)


func _go_to_next_question():
	$"%CorrectAudio".play()
	if $"%QuestionPanel".current_tab+1 == $"%QuestionPanel".get_child_count():
		var score = 0
		var total = 0
		for question in $"%QuestionPanel".get_children():
			if question.correct_alternative != -1: #-1 means no question, just a step
				total += 1
				score += int(question.correct_alternative == question.selected_alternative)
		print("scorescorescorescore  ", score, " - ", total)
		Signals.emit_signal("exercise_win", 3, 0)
		emit_signal("evaluation_ended", score, total)
	else:
		$"%QuestionPanel".current_tab = $"%QuestionPanel".current_tab+1
		$"%QuestionPanel".get_current_tab_control().activate_question()
		if $"%QuestionPanel".get_current_tab_control().correct_alternative != -1:
			$"%Steps".visible = true
			current_question += 1
			$"%Steps".text = str(current_question) + "/" + str(total_questions + 1)
		else:
			$"%Steps".visible = false
		emit_signal("step_changed")


func _on_wrong_pressed():
	$"%WrongAudio".play()
	pass
