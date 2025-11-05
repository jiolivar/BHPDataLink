extends Control

export var punctuation := 2.5
export var vehicle := "CE1508"
export var user_state := 2 # 0 no existe, 1 desconectado, 2 glasses off, 3 conectado
export var self_management := false

var data : Dictionary
var category := 0

var last_selected := false

# category:
# 0 -> no user
# 1 -> disconected
# 2 -> glasses off
# 3 -> self management
# 4 -> low risk
# 5 -> med risk
# 6 -> high risk

signal pressed(iris_button_ref, pressed)
signal risk_tag_pressed(iris_button_ref)

func _ready():
	update()


func set_user_data(_data : Dictionary) -> void:
	vehicle = _data.get("vehicle", "")
	punctuation = _data.get("punctuation", 0.0)
	user_state = _data.get("user_state", 2)
	self_management = _data.get("self_management", false)
	
	data = _data
	
	update()


func update() -> void:
	
	$"%Punctuation".text = str(punctuation)
	$"%Vehicle".text = vehicle
	
	var stylebox : StyleBox
	
	if user_state == 0:
		$"%TextContainer".visible = false
		stylebox = UI.LIGHTGREY
		category = 0
	elif user_state == 1:
		$"%TextContainer".visible = true
		stylebox = UI.GREY
		category = 1
	elif user_state >= 2:
		$"%TextContainer".visible = true
		if user_state == 2:
			stylebox = UI.OUTLINE_LIGHTGREEN
			category = 2
		elif self_management:
			stylebox = UI.OUTLINE_BLUE
			category = 3
		elif punctuation >= 5.0:
			stylebox = UI.OUTLINE_RED
			category = 6
		elif punctuation >= 4.5:
			stylebox = UI.OUTLINE_YELLOW
			category = 5
		else:
			stylebox = UI.OUTLINE_GREEN
			category = 4
	
	if stylebox != null:
		$"%Button".set("custom_styles/normal", stylebox)
		$"%Button".set("custom_styles/hover", stylebox)
		$"%Button".set("custom_styles/pressed", stylebox)
	
	if data.get("total_high_risk", 0) > 0:
		$"%RiskTagButton".set("custom_styles/normal", UI.RED)
		$"%RiskTagButton".set("custom_styles/hover", UI.RED)
		$"%RiskTagButton".set("custom_styles/pressed", UI.RED)
		
		$"%RiskTagButton".show()
	elif data.get("total_med_risk", 0) > 0:
		$"%RiskTagButton".set("custom_styles/normal", UI.YELLOW)
		$"%RiskTagButton".set("custom_styles/hover", UI.YELLOW)
		$"%RiskTagButton".set("custom_styles/pressed", UI.YELLOW)
		
		$"%RiskTagButton".show()
	else:
		$"%RiskTagButton".hide()
	

func set_last_selected(_last_selected : bool) -> void:
	last_selected = _last_selected
	$"%SelectTag".set("custom_styles/panel", UI.GREY if _last_selected else UI.LIGHTGREY)


func _on_Button_pressed():
	emit_signal("pressed", self, $"%Button".pressed)
	$"%SelectTag".visible = $"%Button".pressed


func _on_RiskTagButton_pressed():
	emit_signal("risk_tag_pressed", self)


func is_pressed() -> bool:
	return $"%Button".pressed

func set_pressed(new_pressed : bool) -> void:
	$"%Button".pressed = new_pressed
