extends Node2D

func _ready() -> void:
	$GameoverAudio.play(0)
	
func _on_gameover_audio_finished() -> void:
	$GameoverAudio.play(0)

func _on_btn_play_2_pressed() -> void:
	GameManager.restart()
