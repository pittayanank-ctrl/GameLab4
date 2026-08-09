extends Button

@export var exitToScene: PackedScene


func _ready() -> void:
	setup_button_hover(self)


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


func _on_pressed() -> void:
	if exitToScene != null:
		SceneTransition.load_scene(exitToScene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Levels/menu.tscn")
