extends Control

@onready var plr1 = $"1plr"
@onready var plr2 = $"2plr"
@onready var plr3 = $"3plr"
@onready var plr4 = $"4plr"

@onready var nextscene = "res://playerSelection.tscn"

func _on_plr_pressed() -> void:
	buttonpressed(1)


func _on_plr2_pressed() -> void:
	buttonpressed(2)


func _on_plr3_pressed() -> void:
	buttonpressed(3)


func _on_plr4_pressed() -> void:
	buttonpressed(4)

func buttonpressed(count: int):
	#print(count)
	Singleton.maxplrcount = count
	get_tree().change_scene_to_file(nextscene)
