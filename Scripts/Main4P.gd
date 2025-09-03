extends Node2D

@onready var tilemap = $TileMapLayer
@onready var pIndicator = $TileMapLayer/Control/ColorRect/Label

@onready var virusNodes = [$Virus, $Virus2, $Virus3, $Virus4, $Virus5, $Virus6, $Virus7]
@onready var virusSprites = [
	$Virus/Sprite2D,
	$Virus2/Sprite2D,
	$Virus3/Sprite2D,
	$Virus4/Sprite2D,
	$Virus5/Sprite2D,
	$Virus6/Sprite2D,
	$Virus7/Sprite2D
	]
@onready var dataNodes = [$DataNode, $DataNode2]
@onready var pNodes = [$Player, $Player2, $Player3, $Player4]
@onready var ScoreLabels = [
	$TileMapLayer/Control/ColorRect/Control/Label/Player1,
	$TileMapLayer/Control/ColorRect/Control/Label/Player2,
	$TileMapLayer/Control/ColorRect/Control/Label/Player3,
	$TileMapLayer/Control/ColorRect/Control/Label/Player4,
	
]

var GameoverScene = "res://Scenes/Game over.tscn"
var WinScene = "res://Scenes/Winning screen.tscn"

var PControllers: Array[PlayerMovement] = []
var VControllers: Array[PlayerMovement] = []

var id: Array

var debounce: bool
var End: bool
var inArea: bool

var buttonCD: bool

var activePlr = 0
var DisplayPlr = 1

func _ready():
	Singleton.PlayerScores = [0, 0, 0, 0]
	
	for nodes in range(pNodes.size()):
		print("Registering " + str(nodes))
		var controller = await PlayerMovement.new(tilemap, pNodes[nodes])
		controller._init(tilemap, pNodes[nodes])
		add_child(controller)
		controller.setturn(false)
		PControllers.append(controller)
	
	for nodes in range(virusNodes.size()):
		print("Registering " + str(virusNodes[nodes]))
		var controllers = await PlayerMovement.new(tilemap, virusNodes[nodes])
		add_child(controllers)
		controllers._init(tilemap, virusNodes[nodes])
		controllers.setVirus(dataNodes, virusSprites[nodes])
		controllers.setplayers(pNodes)
		VControllers.append(controllers)
	
	for nodes in dataNodes:
		print("Registering " + str(nodes))
		var controller = await PlayerMovement.new(tilemap, nodes)
		add_child(controller)
		controller._init(tilemap, nodes)
	
	PControllers[0].setturn(true)
	

func _input(event):
	if event.is_action_pressed("click") and not debounce and not End:
		if not inArea:
			print("Not in area")
			return
		
		debounce = true
		
		id = PControllers[activePlr].setpathid(
			tilemap.local_to_map(pNodes[activePlr].global_position),
			tilemap.local_to_map(get_global_mouse_position())
		)
		
		PControllers[activePlr].calpath(id)
		
		await get_tree().create_timer(1).timeout
		
		if activePlr == 3:
			DisplayPlr = "Viruses"
			
			for i in range(virusNodes.size()):
				
				PControllers[activePlr].setturn(false)
				VControllers[i].setturn(true)
				
				var VID = VControllers[i].setpathid(
					tilemap.local_to_map(virusNodes[i].global_position),
					tilemap.local_to_map(VControllers[i].CVTarget.global_position)
					)
				
				VControllers[i].calpath(VID)
			
			await get_tree().create_timer(.75)
		
			activePlr = (activePlr + 1) % PControllers.size()
			PControllers[activePlr].setturn(true)
			DisplayPlr = activePlr + 1
			
		else:
			
			PControllers[activePlr].setturn(false)
		
			activePlr = (activePlr + 1) % PControllers.size()
			PControllers[activePlr].setturn(true)
			DisplayPlr = activePlr + 1
		
		debounce = false
		
		


func _physics_process(delta: float):
	if End: return
	pIndicator.text = "Current Player: " + str(DisplayPlr)
	
	for i in range(ScoreLabels.size()):
		ScoreLabels[i].text = "Player " + str(i + 1) + ":  " + str(Singleton.PlayerScores[i])
	
	var count = 0
	for i in range(VControllers.size()):
		if not VControllers[i].Alive:
			count += 1
	
	if count == VControllers.size():
		EndGame(WinScene)
	
	if not dataNodes[0].visible and not dataNodes[1].visible:
		EndGame(GameoverScene)

func _on_end_turn_pressed() -> void:
	if buttonCD: return
	buttonCD = true
	
	if activePlr == 3:
		DisplayPlr = "Viruses"
		
		for i in range(virusNodes.size()):
			
			PControllers[activePlr].setturn(false)
			VControllers[i].setturn(true)
			
			var VID = VControllers[i].setpathid(
				tilemap.local_to_map(virusNodes[i].global_position),
				tilemap.local_to_map(VControllers[i].CVTarget.global_position)
				)
				
			VControllers[i].calpath(VID)
		
		await get_tree().create_timer(.75)
		
		activePlr = (activePlr + 1) % PControllers.size()
		PControllers[activePlr].setturn(true)
		DisplayPlr = activePlr
		
	else:
		
		PControllers[activePlr].setturn(false)
		
		activePlr = (activePlr + 1) % PControllers.size()
		PControllers[activePlr].setturn(true)
		DisplayPlr = activePlr + 1
	
	await get_tree().create_timer(.5).timeout
	buttonCD = false

func EndGame(scene):
	for i in VControllers:
		i.setdeb(true)
	
	for i in PControllers:
		i.setdeb(true)
		
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
