extends Path2D
class_name MovingPlatform

@export var path_time = 2
@export var ease: Tween.EaseType
@export var transition: Tween.TransitionType
@export var path_follow_2D: PathFollow2D

@export_category("Platform Appearance")
@export var platform_texture: Texture2D

@onready var platform_sprite: Sprite2D = $AnimatableBody2D/Sprite2D


func _ready():
	# เปลี่ยนรูป Platform
	if platform_texture:
		platform_sprite.texture = platform_texture

	move_tween()


func move_tween():
	var tween = get_tree().create_tween()
	tween.set_loops(999999)

	tween.tween_property(
		path_follow_2D,
		"progress_ratio",
		1.0,
		path_time
	).set_ease(ease).set_trans(transition)

	tween.tween_property(
		path_follow_2D,
		"progress_ratio",
		0.0,
		path_time
	).set_ease(ease).set_trans(transition)
