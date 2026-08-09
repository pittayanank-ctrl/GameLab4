extends Node2D

@onready var btn_continue: Button = $UI/btnContinue
@onready var btn_start: Button = $UI/btnStart
@onready var btn_option: Button = $UI/btnOption
@onready var btn_credit: Button = $UI/btnCredit
@onready var btn_exit: Button = $UI/btnExit

@onready var logo_sprite = $LogoAnimationPlayer
@onready var AnimationFallIdle = $AnimationFallIdle

var is_slashing := false

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	$UI.size = get_viewport_rect().size

	btn_continue.disabled = !GameManager.has_gamesaved()

	GameManager.load_option()

	logo_sprite.play("new_animation")
	AnimationFallIdle.play("Idle101")

	setup_button_hover(btn_start)
	setup_button_hover(btn_continue)
	setup_button_hover(btn_option)
	setup_button_hover(btn_credit)
	setup_button_hover(btn_exit)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_slashing = true
			AnimationFallIdle.play("Slashing101")

func setup_button_hover(button: Button):
	var original_position = button.position
	var original_scale = button.scale

	var tween: Tween = null

	button.mouse_entered.connect(func():
		if tween:
			tween.kill()

		tween = create_tween()
		tween.set_parallel(true)

		tween.tween_property(
			button,
			"position",
			original_position + Vector2(8, 0),
			0.15
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			button,
			"scale",
			original_scale * 1.05,
			0.15
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)

	button.mouse_exited.connect(func():
		if tween:
			tween.kill()

		tween = create_tween()
		tween.set_parallel(true)

		tween.tween_property(
			button,
			"position",
			original_position,
			0.15
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			button,
			"scale",
			original_scale,
			0.15
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)


func _process(delta: float) -> void:
	pass


func _on_btn_start_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	GameManager.restart()


func _on_btn_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/options.tscn")


func _on_btn_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/credit.tscn")


func _on_btn_continue_pressed() -> void:
	GameManager.load_game()


func _on_btn_exit_pressed() -> void:
	get_tree().quit()


func _on_animation_fall_idle_animation_finished() -> void:
	if is_slashing:
		is_slashing = false
		AnimationFallIdle.play("Idle101")
