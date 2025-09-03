extends Control

@onready var nextscene = "res://Scenes/Mode Selection.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(nextscene)


func _on_exit_pressed() -> void:
	get_tree().quit()
