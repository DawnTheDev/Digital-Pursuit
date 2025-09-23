extends Node2D

@onready var tilemap = $TileMapLayer
@onready var pIndicator = $TileMapLayer/Control/ColorRect/PIn

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

@onready var ScanButton = $TileMapLayer/Control/ColorRect/Cards/Button
@onready var FirewallButton = $TileMapLayer/Control/ColorRect/Cards/Button2
@onready var OverclockButton = $TileMapLayer/Control/ColorRect/Cards/Button3

@onready var sfx_scan = $scanuse
@onready var sfx_firewall = $firewalluse
@onready var sfx_overclock = $overclockuse

@onready var ScanAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button/Amount
@onready var FirewallAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button2/Amount
@onready var OverclockAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button3/Amount

@onready var Firewallbanner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Firewallbanner/AnimationPlayer
@onready var Scanwallbanner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Scanwallbanner/AnimationPlayer
@onready var Player1banner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Player1banner/AnimationPlayer
@onready var Player2banner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Player2banner/AnimationPlayer
@onready var Player3banner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Player3banner/AnimationPlayer
@onready var Player4banner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Player4banner/AnimationPlayer
@onready var Virusbanner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Virusbanner/Virusbanneranimation
@onready var Overclockbanner = $TileMapLayer/Control/ColorRect/Control/Banneranimation/Overclockbanner/Overclockbannerani
var GameoverScene = "res://Scenes/Game over.tscn"
var WinScene = "res://Scenes/Winning screen.tscn"

var PControllers: Array[PlayerMovement] = []
var VControllers: Array[PlayerMovement] = []

var id: Array

var debounce: bool
var End: bool
var inArea: bool

var buttonCD: bool

var scanUsed: bool
var firewallUsed: bool
var OverclockUsed: bool

var OverclockActive: bool

var PouwerupCD: bool

var activePlr = 0
var DisplayPlr = 1

func _ready():
	Singleton.PlayerScores = [0, 0, 0, 0]
	Player1banner.play("Moving in")
	for i in range(Singleton.PlayerPowerUps.size()):
		Singleton.PlayerPowerUps[i] = [0, 0, 0]
	
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
	
	#while true:
		#await get_tree().create_timer(.5).timeout
		#print("ACTIVE PLR: " + str(activePlr))
		#print("DISPLAY PLR: " + str(DisplayPlr))

func _input(event):
	if event.is_action_pressed("click") and not debounce and not End:
		if not inArea:
			print("Not in area")
			return
		
		PouwerupCD = true
		debounce = true
		scanUsed = false
		firewallUsed = false
		OverclockUsed = false
		
		var amount
		if OverclockActive:
			amount = 4
			OverclockActive = false
		else:
			amount = 2
		
		id = PControllers[activePlr].setpathid(
			tilemap.local_to_map(pNodes[activePlr].global_position),
			tilemap.local_to_map(get_global_mouse_position()),
			amount
		)
		
		PControllers[activePlr].calpath(id)
		await get_tree().create_timer(1).timeout

		
		if activePlr == 3:
			DisplayPlr = 5
			Virusbanner.play("Moving in")
			for i in range(virusNodes.size()):
				
				PControllers[activePlr].setturn(false)
				VControllers[i].setturn(true)
				
				var VID = VControllers[i].setpathid(
					tilemap.local_to_map(virusNodes[i].global_position),
					tilemap.local_to_map(VControllers[i].CVTarget.global_position),
					1
					)
				
				VControllers[i].calpath(VID)
			
			await get_tree().create_timer(.75).timeout
			Player1banner.play("Moving in")
			activePlr = (activePlr + 1) % PControllers.size()
			PControllers[activePlr].setturn(true)
			DisplayPlr = activePlr + 1
			
		else:
			
			scanUsed = false
			firewallUsed = false
			OverclockUsed = false
			
			PControllers[activePlr].setturn(false)
		
			activePlr = (activePlr + 1) % PControllers.size()
			PControllers[activePlr].setturn(true)
			DisplayPlr = activePlr + 1
			
		
				
			if activePlr == 1:
				Player2banner.play("Moving in")
			elif activePlr == 2:
				Player3banner.play("Moving in")
			elif activePlr == 3:
				Player4banner.play("Moving in")
				
		
		PouwerupCD = false
		debounce = false
		
	if event.is_action_pressed("debug"):
			print(Singleton.PlayerPowerUps)
	
func _physics_process(delta: float):
	if End: return
	
	for i in range(5):
		if i == activePlr:
			
			if not scanUsed:
				
				if Singleton.PlayerPowerUps[i][0] == 1:
					ScanButton.visible = true
					ScanAmountIN.visible = false
				
				elif Singleton.PlayerPowerUps[i][0] > 0:
					ScanButton.visible = true
					ScanAmountIN.visible = true
					ScanAmountIN.text = "X" + str(Singleton.PlayerPowerUps[i][0])
				
				else:
					ScanButton.visible = false
					ScanAmountIN.visible = false
			
			if not firewallUsed:
				
				if Singleton.PlayerPowerUps[i][1] == 1:
					FirewallButton.visible = true
					FirewallAmountIN.visible = false
				
				elif Singleton.PlayerPowerUps[i][1] > 0:
					FirewallButton.visible = true
					FirewallAmountIN.visible = true
					FirewallAmountIN.text = "X" + str(Singleton.PlayerPowerUps[i][1])
				
				else:
					FirewallButton.visible = false
					FirewallAmountIN.visible = false
			
			if not OverclockUsed:
				
				if Singleton.PlayerPowerUps[i][2] == 1:
					#print(OverclockButton.visible)
					OverclockButton.visible = true
					OverclockAmountIN.visible = false
			
				elif Singleton.PlayerPowerUps[i][2] > 0:
					OverclockButton.visible = true
					OverclockAmountIN.visible = true
					OverclockAmountIN.text = "X" + str(Singleton.PlayerPowerUps[i][2])
				
				else:
					#print(2)
					OverclockButton.visible = false
					OverclockAmountIN.visible = false
	
	
	for i in range(ScoreLabels.size()):
		ScoreLabels[i].text = "Player " + str(i + 1) + ":  " + str(Singleton.PlayerScores[i])
	#can't fix help ;(
	if DisplayPlr == 1:
		pIndicator.texture = load("res://Images/character blue.png")
	
	elif DisplayPlr == 2:
		pIndicator.texture = load("res://Images/character Green.png")
	
	elif DisplayPlr == 3:
		pIndicator.texture = load("res://Images/character yellow.png")
	
	elif DisplayPlr == 4:
		pIndicator.texture = load("res://Images/Player Red.png")

	elif DisplayPlr == 5:
		pIndicator.texture = load("res://Images/Virus Digital.png")
		
	
	var count = 0
	for i in range(VControllers.size()):
		if not VControllers[i].Alive:
			count += 1
	
	if count == VControllers.size():
		EndGame(WinScene)
		MenuSoundBg.stop()
	
	if not dataNodes[0].visible and not dataNodes[1].visible:
		EndGame(GameoverScene)
		MenuSoundBg.stop()

func _on_end_turn_pressed() -> void:
	if buttonCD: return
	buttonCD = true
	
	if activePlr == 3:
		DisplayPlr = 5
		
		for i in range(virusNodes.size()):
			
			PControllers[activePlr].setturn(false)
			VControllers[i].setturn(true)
			
			var VID = VControllers[i].setpathid(
				tilemap.local_to_map(virusNodes[i].global_position),
				tilemap.local_to_map(VControllers[i].CVTarget.global_position),
				1
				)
				
			VControllers[i].calpath(VID)
		
		await get_tree().create_timer(.75).timeout
		
		activePlr = (activePlr + 1) % PControllers.size()
		PControllers[activePlr].setturn(true)
		DisplayPlr = activePlr + 1
		
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


func _on_button_pressed() -> void:
	if PouwerupCD: return
	scanUsed = true
	Singleton.PlayerPowerUps[activePlr][0] -= 1
	ScanButton.visible = false
	for nodes in VControllers:
		nodes.scanactivate()
	sfx_scan.play()
	Scanwallbanner.play("Moving in")
	


func _on_button_2_pressed() -> void:
	if PouwerupCD: return
	firewallUsed = true
	Singleton.PlayerPowerUps[activePlr][1] -= 1
	FirewallButton.visible = false
	for nodes in VControllers:
		nodes.firewallactivate()
	sfx_firewall.play()
	Firewallbanner.play("Moving in")

func _on_button_3_pressed() -> void:
	if PouwerupCD: return
	Overclockbanner.play("Moving in")
	OverclockActive = true
	OverclockUsed = true
	Singleton.PlayerPowerUps[activePlr][2] -= 1
	OverclockButton.visible = false
	sfx_overclock.play()
	
