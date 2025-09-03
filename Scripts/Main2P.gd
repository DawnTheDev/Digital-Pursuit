extends Node2D

@onready var tilemap = $TileMapLayer
@onready var pIndicator = $TileMapLayer/Control/ColorRect/Label

@onready var virusNodes = [$Virus, $Virus2, $Virus3]
@onready var virusSprites = [$Virus/Sprite2D, $Virus2/Sprite2D, $Virus3/Sprite2D]
@onready var dataNodes = [$DataNode, $DataNode2]
@onready var pNodes = [$Player, $Player2]
@onready var ScoreLabels = [
	$TileMapLayer/Control/ColorRect/Control/Label/Player1,
	$TileMapLayer/Control/ColorRect/Control/Label/Player2
	]

var GameoverScene = "res://Scenes/Game over.tscn"
var WinScene = "res://Scenes/Winning screen.tscn"

var Plr1Movement = PlayerMovement
var Plr2Movement = PlayerMovement

var VControllers: Array[PlayerMovement] = []

var id: Array

var debounce: bool
var End: bool
var inArea: bool

var buttonCD: bool

var activePlr = 1
var DisplayPlr = 1
var PlayerScores = [0, 0]

signal UpdateScore(Index: int)

func _ready():
	Singleton.PlayerScores = [0, 0, 0, 0]
	
	Plr1Movement = await PlayerMovement.new(tilemap, $Player)
	Plr1Movement._init(tilemap, $Player)
	add_child(Plr1Movement)
	Plr1Movement.setturn(true)
	
	Plr2Movement = await PlayerMovement.new(tilemap, $Player2)
	Plr2Movement._init(tilemap, $Player2)
	add_child(Plr2Movement)
	Plr2Movement.setturn(false)
	
	for nodes in range(virusNodes.size()):
		print("Registering " + str(virusNodes[nodes]))
		var controllers = await PlayerMovement.new(tilemap, virusNodes[nodes])
		add_child(controllers)
		controllers._init(tilemap, virusNodes[nodes])
		controllers.setVirus(dataNodes, virusSprites[nodes])
		controllers.setplayers(pNodes)
		VControllers.append(controllers)
	
	for nodes in dataNodes:
		var controller = await PlayerMovement.new(tilemap, nodes)
		add_child(controller)
		controller._init(tilemap, nodes)
	
	

func _input(event):
	if event.is_action_pressed("click") and not debounce and not End:
		if not inArea:
			print("Not in area")
			return
		
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
			DisplayPlr = 2
			
			debounce = false
			
		else:
			print("PLAYER 2")
			debounce = true
			id = Plr2Movement.setpathid(
				tilemap.local_to_map($Player2.global_position),
				tilemap.local_to_map(get_global_mouse_position())
				)
		 	
			Plr2Movement.calpath(id)
			
			# MAKE VIRUS MOVE HERE
			await get_tree().create_timer(.75).timeout
			activePlr = 3
			DisplayPlr = "Viruses"
			
			for i in range(3):
				VControllers[i].setturn(true)
				
				var VID = VControllers[i].setpathid(
					tilemap.local_to_map(virusNodes[i].global_position),
					tilemap.local_to_map(VControllers[i].CVTarget.global_position)
					)
				
				VControllers[i].calpath(VID)
			
			await get_tree().create_timer(1).timeout
			for i in range(3):
				VControllers[i].setturn(false)
			
			Plr2Movement.setturn(false)
			Plr1Movement.setturn(true)
			activePlr = 1
			DisplayPlr = 1
			
			debounce = false
		
		


func _physics_process(delta: float):
	if End: return
	
	for i in range(ScoreLabels.size()):
		ScoreLabels[i].text = "Player " + str(i + 1) + ":  " + str(Singleton.PlayerScores[i])
	
	pIndicator.text = "Current Player: " + str(DisplayPlr)
	
	if not VControllers[0].Alive and not VControllers[1].Alive and not VControllers[2].Alive:
		EndGame(WinScene)
	
	if not dataNodes[0].visible and not dataNodes[1].visible:
		EndGame(GameoverScene)

func _on_end_turn_pressed() -> void:
	if buttonCD: return
	
	if activePlr == 1:
		Plr1Movement.setturn(false)
		Plr2Movement.setturn(true)
		activePlr = 2
		DisplayPlr = 2
		
	elif activePlr == 2:
		
		await get_tree().create_timer(.75).timeout
		activePlr = 3
		DisplayPlr = "Viruses"
		
		for i in range(3):
			VControllers[i].setturn(true)
			
			var VID = VControllers[i].setpathid(
				tilemap.local_to_map(virusNodes[i].global_position),
				tilemap.local_to_map(VControllers[i].CVTarget.global_position)
				)
				
			VControllers[i].calpath(VID)
		
		await get_tree().create_timer(1).timeout
		Plr1Movement.setturn(true)
		Plr2Movement.setturn(false)
		activePlr = 1
		DisplayPlr = 1
	
	await get_tree().create_timer(.5).timeout
	buttonCD = false

func EndGame(scene):
	for i in VControllers:
		i.setdeb(true)
	
	Plr1Movement.setdeb(true)
	Plr2Movement.setdeb(true)
	
	End = true
	
	if get_tree():
		await get_tree().create_timer(.5).timeout
		get_tree().change_scene_to_file(scene)


func _on_area_2d_mouse_entered() -> void:
	inArea = true
	print("mouse entered")

func _on_area_2d_mouse_exited() -> void:
	inArea = false
	print("mouse exitted")


func _on_update_score(Index: int) -> void:
	PlayerScores[Index] += 1
	ScoreLabels[Index].text = "PLAYER " + str(Index + 1) + ": " + str(PlayerScores[Index])
