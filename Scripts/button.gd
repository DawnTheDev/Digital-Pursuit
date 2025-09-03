extends Node

#@onready var buttons = [$"7b43821b-6983-4544-8441-e608b8e72747_ec8c48382a3f9d69d8Bde8Eebe1179d3/Button", $"7b43821b-6983-4544-8441-e608b8e72747_ec8c48382a3f9d69d8Bde8Eebe1179d5/Button2"]
@onready var Return = "res://Scenes/Main Menu.tscn"
@onready var Duo = "res://Scenes/2Players.tscn"
@onready var Squad = "res://Scenes/4P.tscn"

func _on_button_pressed() -> void:
	Singleton.maxplrcount = 1
	get_tree().change_scene_to_file(Return)

func _on_button_3_pressed() -> void:
	Singleton.maxplrcount = 3
	get_tree().change_scene_to_file(Duo)

func _on_button_4_pressed() -> void:
	Singleton.maxplrcount = 4
	get_tree().change_scene_to_file(Squad)
