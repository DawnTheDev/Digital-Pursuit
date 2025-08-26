extends Control

@onready var character1 = $VBoxContainer/character1
@onready var character2 = $VBoxContainer/character2
@onready var character3 = $VBoxContainer/character3
@onready var character4 = $VBoxContainer/character4

@onready var n1 = $"1"
@onready var n0 = $"0"

var deb = true

var curplr = 1

var AllChr = [
	Singleton.Characters["DPS"],
	Singleton.Characters["Tank"],
	Singleton.Characters["Healer"],
	Singleton.Characters["Mage"]
	]
# CONFIGS
@onready var nextscene = "res://node_2d.tscn"
@onready var mainscene = "res://main.tscn"
var maxplrcount = Singleton.maxplrcount

func _on_character_1_pressed() -> void:
	ButtonPressed(character1, 1)


func _on_character_2_pressed() -> void:
	ButtonPressed(character2, 2)


func _on_character_3_pressed() -> void:
	ButtonPressed(character3, 3)


func _on_character_4_pressed() -> void:
	ButtonPressed(character4, 4)

func ButtonPressed(button,chr: int):
	for i in range(maxplrcount):
		#print(str(i + 1))
		if curplr == i + 1:
			button.text = "Player " + str(i + 1)
			button.disabled = true
			
			if curplr == 1:
				player1.character = AllChr[chr - 1]
			elif curplr == 2:
				player2.character = AllChr[chr - 1]
			elif curplr == 3:
				player3.character = AllChr[chr - 1]
			elif curplr == 4:
				player4.character = AllChr[chr - 1]
			
			if curplr < maxplrcount:
				curplr = curplr + 1
				break
				
			else:
				#print("current player reached player count")
				get_tree().change_scene_to_file(mainscene)

func _physics_process(delta: float) -> void:
	if deb: return
	deb = true
	#await get_tree().create_timer(.1).timeout
	var rdm = RandomNumberGenerator.new()
	var rgn = rdm.randi_range(1, 2)
	
	if rgn == 1:
		spawnrandom(n0)
	else:
		spawnrandom(n1)
	
	deb = false

func spawnrandom(obj):
	var rng = RandomNumberGenerator.new()
	var screen_size = get_viewport_rect().size
	var rx = rng.randf_range(0, screen_size.x)
	var ry = rng.randf_range(0, screen_size.y)
	
	
	
	obj.position = Vector2(rx, ry)
