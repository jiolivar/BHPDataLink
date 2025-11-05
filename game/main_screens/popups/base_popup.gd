tool
extends Control

export var title := ""
export(String, MULTILINE) var text
export(String, "Comenzar", "Reintentar", "Continuar", "Custom" ) var buton_text := "Comenzar"
export var custom_buton_text := ""
export var show_stars := false
export(int, 0, 3) var star_count := 0

const anim_speed = 0.6

signal button_pressed
signal closed

func _ready():
	visible = false
	_apply_settings()
	
func show():
	visible = true
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($"%Panel","rect_scale",Vector2.ONE,anim_speed).from(Vector2.ZERO)
	tween.parallel().tween_property($"%BG","modulate",Color.white,anim_speed).from(Color(0,0,0,0)).set_trans(Tween.TRANS_QUAD)
	yield(tween, "finished")
	if show_stars:
		for i in range(star_count):
			var star = $"%Stars".get_child(i)

			star.appear(i)
			yield(get_tree().create_timer(0.3), "timeout")
	

func _process(delta):
	if Engine.is_editor_hint():
		_apply_settings()
		pass

func _apply_settings():
	$"%Stars".visible = show_stars
	$"%Title".text = title
	$"%Text".text = text
	if buton_text == "Custom":
		$"%Button".text = custom_buton_text
	else:
		$"%Button".text = buton_text

func _on_Button_pressed():
	$"%AudioStreamPlayer".play()
	$"%Button".disabled = true
	close_popup()
	yield(self,"closed")
	emit_signal("button_pressed")


func restart():
	$"%Button".disabled = false


func close_popup():
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property($"%Panel","rect_scale",Vector2.ZERO,anim_speed).from(Vector2.ONE)
	tween.parallel().tween_property($"%BG","modulate",Color(0,0,0,0),anim_speed).from(Color.white).set_trans(Tween.TRANS_QUAD)
	yield(tween, "finished")
	visible = false
	emit_signal("closed")
