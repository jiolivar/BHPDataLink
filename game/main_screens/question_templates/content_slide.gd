extends BaseQuestionPanel

class_name ContentSlide

var content_panels = []
var current_content_index = 0
var content_anim_speed = 0.5
var titles : Dictionary
var current_content
onready var last_mouse_pos = get_global_mouse_position()

var is_animating := false

export var content_already_created := false

signal slides_completed()

func _ready():
	if content_already_created:
		
		for child in $"%ContentContainer".get_children():
			content_panels.push_back(child)
			child.anchor_right = 1
			child.anchor_bottom = 1
			child.visible = false
		
		if content_panels.size() > 0:
			current_content = content_panels[current_content_index]
		yield(get_tree().create_timer(0.5), "timeout")
		if current_content:
			yield(_show_current_content(), "completed")
		
		pass
	else:
		if titles.has(0):
			title = titles[0]["Title"]
		._ready()
		var path = filename.get_base_dir()+"/content/"
		var i = 1
		while true:
			var file_name = str(i)+".png"
			var loaded_content = load(path + file_name)
			if !loaded_content:
				file_name = str(i)+".ogv"
				loaded_content = load(path + file_name)
			if !loaded_content:
				break
			else:
				var content_panel : Control
				if loaded_content is StreamTexture:
					content_panel = TextureRect.new()
					content_panel.texture = loaded_content
					content_panel.expand = true
					content_panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				elif loaded_content is VideoStream:
					content_panel = VideoPlayer.new()
					content_panel.stream = loaded_content
				if content_panel:
					content_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
					content_panel.anchor_right = 1
					content_panel.anchor_bottom = 1
					content_panel.rect_size = Vector2.ZERO
					content_panel.visible = false
					$"%ContentContainer".add_child(content_panel)
					content_panels.push_back(content_panel)
			i += 1
		if content_panels.size():
			current_content = content_panels[current_content_index]
		yield(get_tree().create_timer(0.5), "timeout")
		if current_content:
			yield(_show_current_content(), "completed")

func _process(delta):
	$"%PrevArrow".visible = last_mouse_pos.x < $"%SlideContent".rect_global_position.x+$"%SlideContent".rect_size.x*0.5
	$"%NextArrow".visible = last_mouse_pos.x >= $"%SlideContent".rect_global_position.x+$"%SlideContent".rect_size.x*0.5
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		last_mouse_pos = get_global_mouse_position()
	elif event is InputEventMouseButton and event.is_pressed():
		last_mouse_pos = get_global_mouse_position()
		if last_mouse_pos.x >= $"%SlideContent".rect_global_position.x+$"%SlideContent".rect_size.x*0.5:
			_go_to_next_content()
		if last_mouse_pos.x < $"%SlideContent".rect_global_position.x+$"%SlideContent".rect_size.x*0.5:
			_go_to_prev_content()

func _hide_current_content():
	_content_done(current_content_index)
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(current_content,"rect_scale",Vector2.ZERO,content_anim_speed).from(Vector2.ONE)
	tween.parallel().tween_property(current_content,"modulate",Color.transparent,content_anim_speed).from(Color.white)
	yield(tween, "finished")
	current_content.visible = false
	if current_content is VideoPlayer:
		current_content.stop()
		$AudioStreamPlayer.volume_db = -10

func _go_to_prev_content():
	if is_animating:
		return
	if current_content_index > 0:
		if $"%Click":
			$"%Click".play()
		is_animating = true
		yield(_hide_current_content(), "completed")
		current_content_index -= 1
		current_content = content_panels[current_content_index]
		yield(_show_current_content(), "completed")
		is_animating = false
#	else:
#		is_animating = true
#		yield(end(), "completed")
#		is_animating = false
#		Transition.change_scene(Main.advance_exercise_and_get_prev())

func _go_to_next_content():
	if is_animating:
		return
	if current_content_index < content_panels.size()-1:
		if $"%Click":
			$"%Click".play()
		is_animating = true
		yield(_hide_current_content(), "completed")

		current_content_index += 1
		current_content = content_panels[current_content_index]
		yield(_show_current_content(), "completed")
		is_animating = false
	else:
		emit_signal("slides_completed")
		is_animating = true
		yield(end(), "completed")
		is_animating = false
		Transition.change_scene(Main.advance_exercise_and_get_next())


func _show_current_content():
	if current_content:
		current_content.modulate = Color.transparent
		var size
		if current_content is TextureRect:
			size = current_content.texture.get_size()
		elif current_content is VideoPlayer:
			size = current_content.get_video_texture().get_size()
		elif current_content is Control:
			size = current_content.rect_size
		$"%ContentContainer".ratio = size.x/size.y
		
		current_content.rect_pivot_offset = current_content.rect_scale*current_content.rect_size/2.0
		
		if titles.has(current_content_index):
			$"%Title".text = titles[current_content_index]["Title"]
			print(titles[current_content_index]["Title"])
		
		current_content.visible = true
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(current_content,"rect_scale",Vector2.ONE,content_anim_speed).from(Vector2.ZERO)
		tween.parallel().tween_property(current_content,"modulate",Color.white,content_anim_speed).from(Color.transparent)
		yield(tween, "finished")
		if current_content is VideoPlayer:
			current_content.play()
			$AudioStreamPlayer.volume_db = -40
		_content_ready(current_content_index)

func _content_ready(_content_index : int):
	pass

func _content_done(_content_index : int):
	pass
