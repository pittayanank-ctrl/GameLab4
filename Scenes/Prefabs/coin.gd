extends Area2D

# You can change these to your likings
@export var amplitude := 4
@export var frequency := 5
@onready var coins_sprite = $coinsAnimatedSprite2D

var time_passed = 0
var initial_position := Vector2.ZERO

func _ready():
	initial_position = position
	coins_sprite.play("default")
	
# Coin collected
func _on_body_entered(body):
	if body.is_in_group("Player"):
		AudioManager.coin_pickup_sfx.play()
		GameManager.add_score()
		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(position.x,position.y-100), 0.5)
		tween.set_parallel()
		tween.tween_property(self, "scale", Vector2(2,2), 0.5)
		await tween.finished
		queue_free()
