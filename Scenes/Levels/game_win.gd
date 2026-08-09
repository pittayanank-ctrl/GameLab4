extends Node2D

func _ready() -> void:
	GameManager.delete_save_game()
	AudioManager.WalkSfx.stop()
	await get_tree().create_timer(1).timeout
	$UWinBuiAudio.play()


func _on_btn_play_pressed() -> void:
	GameManager.restart()
