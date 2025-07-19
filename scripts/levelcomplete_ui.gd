extends Control

signal next_level_pressed
signal quit_pressed	

func _on_next_level_button_pressed() -> void:
	emit_signal("next_level_pressed")

func _on_quit_button_pressed() -> void:
	emit_signal("quit_pressed")
