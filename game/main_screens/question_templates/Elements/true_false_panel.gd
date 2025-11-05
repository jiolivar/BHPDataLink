extends BaseQuestionPanel

export var currect_answer := true

signal emit_wrong

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$"%Title".text = title
	$"%Enunc".text = enunc
	$"%Question".text = question
	
	#return
	#yield(get_tree().create_timer(0.5), "timeout")
	#show()

func _on_TrueButton_pressed():
	if currect_answer:
		_run_correct()
	else:
		$"%WrongAudio".play()
		emit_signal("emit_wrong")


func _on_FalseButton_pressed():
	if not currect_answer:
		_run_correct()
	else:
		$"%WrongAudio".play()
		emit_signal("emit_wrong")

func _run_correct():
	$"%CorrectAudio".play()
	$"%TrueButton".disabled = true
	$"%FalseButton".disabled = true
	yield(get_tree().create_timer(0.2), "timeout")
	end()
