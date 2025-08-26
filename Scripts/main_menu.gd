extends Control

@onready var nextscene = "res://Scenes/Mode Selection.tscn"



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(nextscene)


func _on_button_2_pressed() -> void:
	get_tree().quit()
