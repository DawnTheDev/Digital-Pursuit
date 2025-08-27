extends Node2D

@onready var tilemap = $TileMapLayer
@onready var pIndicator = $TileMapLayer/Control/ColorRect/Label

@onready var virusNodes = [$Virus, $Virus2, $Virus3]

var Plr1Movement = PlayerMovement
var Plr2Movement = PlayerMovement

var VControllers: Array[PlayerMovement] = []

var id: Array

var debounce: bool
var activePlr = 1

func _ready():
	Plr1Movement = await PlayerMovement.new(tilemap, $Player)
	Plr1Movement._init(tilemap, $Player)
	add_child(Plr1Movement)
	Plr1Movement.setturn(true)
	
	Plr2Movement = await PlayerMovement.new(tilemap, $Player2)
	Plr2Movement._init(tilemap, $Player2)
	add_child(Plr2Movement)
	Plr2Movement.setturn(false)
	
	for nodes in virusNodes:
		var controllers = await PlayerMovement.new(tilemap, nodes)
		add_child(controllers)
		controllers._init(tilemap, nodes)
		VControllers.append(controllers)
	
	

func _input(event):
	if event.is_action_pressed("click") and not debounce:
		
		if activePlr == 1:
			debounce = true
			print("PLAYER 1")
			id = Plr1Movement.setpathid(
				tilemap.local_to_map($Player.global_position),
				tilemap.local_to_map(get_global_mouse_position())
				)
		 
			Plr1Movement.calpath(id)
			
			await get_tree().create_timer(1).timeout
			Plr1Movement.setturn(false)
			Plr2Movement.setturn(true)
			activePlr = 2
			
			debounce = false
			
		else:
			print("PLAYER 2")
			debounce = true
			id = Plr2Movement.setpathid(
				tilemap.local_to_map($Player2.global_position),
				tilemap.local_to_map(get_global_mouse_position())
				)
		 	
			Plr2Movement.calpath(id)
			
			# MAKE VIUS MOVE HERE
			
			await get_tree().create_timer(1).timeout
			Plr2Movement.setturn(false)
			Plr1Movement.setturn(true)
			activePlr = 1
			
			debounce = false
		
		


func _physics_process(delta: float):
	pIndicator.text = "Current Player: " + str(activePlr)

func _on_end_turn_pressed() -> void:
	print("received")
