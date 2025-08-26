extends Node

#@onready var buttons = [$"7b43821b-6983-4544-8441-e608b8e72747_ec8c48382a3f9d69d8Bde8Eebe1179d3/Button", $"7b43821b-6983-4544-8441-e608b8e72747_ec8c48382a3f9d69d8Bde8Eebe1179d5/Button2"]
@onready var nextscene = "res://Scenes/Main Menu.tscn"

func _on_button_pressed() -> void:
	Singleton.maxplrcount = 1
	get_tree().change_scene_to_file(nextscene)



func _on_button_2_pressed() -> void:
	Singleton.maxplrcount = 2
	get_tree().change_scene_to_file(nextscene)
