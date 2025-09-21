extends Node2D

@onready var tilemap = $TileMapLayer
@onready var pIndicator = $TileMapLayer/Control/ColorRect/PIn

@onready var virusNodes = [$Virus, $Virus2, $Virus3]
@onready var virusSprites = [$Virus/Sprite2D, $Virus2/Sprite2D, $Virus3/Sprite2D]
@onready var dataNodes = [$DataNode, $DataNode2]
@onready var pNodes = [$Player, $Player2]
@onready var ScoreLabels = [
	$TileMapLayer/Control/ColorRect/Control/Label/Player1,
	$TileMapLayer/Control/ColorRect/Control/Label/Player2
	]

@onready var ScanButton = $TileMapLayer/Control/ColorRect/Cards/Button
@onready var FirewallButton = $TileMapLayer/Control/ColorRect/Cards/Button2
@onready var OverclockButton = $TileMapLayer/Control/ColorRect/Cards/Button3

@onready var ScanAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button/Amount
@onready var FirewallAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button2/Amount
@onready var OverclockAmountIN = $TileMapLayer/Control/ColorRect/Cards/Button3/Amount

#Banneranimation by plouis
@onready var Firewallbanner = $TileMapLayer/Control/Banneranimation/Firewallbanner/Firewallbannerani
@onready var Scanwallbanner = $TileMapLayer/Control/Banneranimation/Scanwallbanner/Scanwallbannerani
@onready var Player1banner = $TileMapLayer/Control/Banneranimation/Player1banner/AnimationPlayer
@onready var Player2banner = $TileMapLayer/Control/Banneranimation/Player2banner/AnimationPlayer2
@onready var Virusbanner = $TileMapLayer/Control/Banneranimation/Sprite2D/Virusbanneranimation
var GameoverScene = "res://Scenes/Game over.tscn"
var WinScene = "res://Scenes/Winning screen.tscn"

@onready var sfx_scan = $scanuse
@onready var sfx_firewall = $firewalluse
@onready var sfx_overclock = $overclockuse

var Plr1Movement = PlayerMovement
var Plr2Movement = PlayerMovement

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

var activePlr = 1
var DisplayPlr = 1
var PlayerScores = [0, 0]

func _ready():
	Singleton.PlayerScores = [0, 0, 0, 0]
	for i in range(Singleton.PlayerPowerUps.size()):
		Singleton.PlayerPowerUps[i] = [0, 0, 0]
	
	print(Singleton.PlayerPowerUps)
	
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
			Player2banner.play("Moving in")
			debounce = true
			firewallUsed = false
			scanUsed = false
			OverclockUsed = false
			
			var amount
			if OverclockActive:
				amount = 4
				OverclockActive = false
			else:
				amount = 2
			
			print("PLAYER 1")
			id = Plr1Movement.setpathid(
				tilemap.local_to_map($Player.global_position),
				tilemap.local_to_map(get_global_mouse_position()),
				amount
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
			firewallUsed = false
			scanUsed = false
			OverclockUsed = false
			
			var amount
			if OverclockActive:
				amount = 4
				OverclockActive = false
			else:
				amount = 2
			
			id = Plr2Movement.setpathid(
				tilemap.local_to_map($Player2.global_position),
				tilemap.local_to_map(get_global_mouse_position()),
				amount
				)
		 	
			Plr2Movement.calpath(id)
			
			# MAKE VIRUS MOVE HERE
			await get_tree().create_timer(.75).timeout
			activePlr = 3
			DisplayPlr = "Viruses"
			Virusbanner.play("Moving in")
			
			for i in range(3):
				VControllers[i].setturn(true)
				
				var VID = VControllers[i].setpathid(
					tilemap.local_to_map(virusNodes[i].global_position),
					tilemap.local_to_map(VControllers[i].CVTarget.global_position),
					1
					)
				
				VControllers[i].calpath(VID)
			
			await get_tree().create_timer(1).timeout
			for i in range(3):
				VControllers[i].setturn(false)
			
			Plr2Movement.setturn(false)
			Plr1Movement.setturn(true)
			activePlr = 1
			DisplayPlr = 1
			Player1banner.play("Moving in")
			debounce = false
		
		


func _physics_process(delta: float):
	if End: return
	
	if not scanUsed:
		if activePlr == 1:
			
			if Singleton.PlayerPowerUps[0][0] == 1:
				ScanButton.visible = true
				ScanAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[0][0] > 0:
				ScanButton.visible = true
				ScanAmountIN.visible = true
				ScanAmountIN.text = "X" + str(Singleton.PlayerPowerUps[0][0])
				
			else:
				ScanButton.visible = false
				ScanAmountIN.visible = false
			
		elif activePlr == 2:
			
			if Singleton.PlayerPowerUps[1][0] == 1:
				ScanButton.visible = true
				ScanAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[1][0] > 0:
				ScanButton.visible = true
				ScanAmountIN.visible = true
				ScanAmountIN.text = "X" + str(Singleton.PlayerPowerUps[1][0])
				
			else:
				ScanButton.visible = false
				ScanAmountIN.visible = false
		
		else:
			ScanButton.visible = false
	
	if not firewallUsed:
		if activePlr == 1:
			
			if Singleton.PlayerPowerUps[0][1] == 1:
				FirewallButton.visible = true
				FirewallAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[0][1] > 0:
				FirewallButton.visible = true
				FirewallAmountIN.visible = true
				FirewallAmountIN.text = "X" + str(Singleton.PlayerPowerUps[0][1])
				
			else:
				FirewallButton.visible = false
				FirewallAmountIN.visible = false
			
		elif activePlr == 2:
			
			if Singleton.PlayerPowerUps[1][1] == 1:
				FirewallButton.visible = true
				FirewallAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[1][1] > 0:
				FirewallButton.visible = true
				FirewallAmountIN.visible = true
				FirewallAmountIN.text = "X" + str(Singleton.PlayerPowerUps[1][1])
				
			else:
				FirewallButton.visible = false
				FirewallAmountIN.visible = false
		
		else:
			FirewallButton.visible = false
	
	if not OverclockUsed:
		if activePlr == 1:
			
			if Singleton.PlayerPowerUps[0][2] == 1:
				OverclockButton.visible = true
				OverclockAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[0][2] > 0:
				OverclockButton.visible = true
				OverclockAmountIN.visible = true
				OverclockAmountIN.text = "X" + str(Singleton.PlayerPowerUps[0][2])
				
			else:
				OverclockButton.visible = false
				OverclockAmountIN.visible = false
			
		elif activePlr == 2:
			
			if Singleton.PlayerPowerUps[1][2] == 1:
				OverclockButton.visible = true
				OverclockAmountIN.visible = false
			
			elif Singleton.PlayerPowerUps[1][2] > 0:
				OverclockButton.visible = true
				OverclockAmountIN.visible = true
				OverclockAmountIN.text = "X" + str(Singleton.PlayerPowerUps[1][2])
				
			else:
				OverclockButton.visible = false
				OverclockAmountIN.visible = false
		
		else:
			OverclockButton.visible = false
	
	for i in range(ScoreLabels.size()):
		ScoreLabels[i].text = "Player " + str(i + 1) + ":  " + str(Singleton.PlayerScores[i])
	
	if activePlr == 1:
		pIndicator.texture = load("res://Images/character blue.png")
	elif activePlr == 2:
		pIndicator.texture = load("res://Images/character Green.png")
	elif activePlr == 3:
		pIndicator.texture = load("res://Images/Virus Digital.png")
	
	if not VControllers[0].Alive and not VControllers[1].Alive and not VControllers[2].Alive:
		EndGame(WinScene)
		MenuSoundBg.stop()
	
	if not dataNodes[0].visible and not dataNodes[1].visible:
		EndGame(GameoverScene)
		MenuSoundBg.stop()

func _on_end_turn_pressed() -> void:
	if buttonCD: return
	
	if activePlr == 1:
		scanUsed = false
		firewallUsed = false
		Plr1Movement.setturn(false)
		Plr2Movement.setturn(true)
		activePlr = 2
		DisplayPlr = 2
		Player2banner.play("Moving in")
	elif activePlr == 2:
		
		await get_tree().create_timer(.75).timeout
		activePlr = 3
		DisplayPlr = "Viruses"
		
		for i in range(3):
			VControllers[i].setturn(true)
			
			var VID = VControllers[i].setpathid(
				tilemap.local_to_map(virusNodes[i].global_position),
				tilemap.local_to_map(VControllers[i].CVTarget.global_position),
				1
				)
				
			VControllers[i].calpath(VID)
		
		await get_tree().create_timer(1).timeout
		Plr1Movement.setturn(true)
		Plr2Movement.setturn(false)
		activePlr = 1
		DisplayPlr = 1
		Player1banner.play("Moving in")
		scanUsed = false
		firewallUsed = false
	
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


func _on_button_pressed() -> void:
	scanUsed = true
	Scanwallbanner.play("Moving in")
	Singleton.PlayerPowerUps[activePlr - 1][0] -= 1
	ScanButton.visible = false
	for nodes in VControllers:
		nodes.scanactivate()
	sfx_scan.play()


func _on_button_2_pressed() -> void:
	firewallUsed = true
	Singleton.PlayerPowerUps[activePlr - 1][1] -= 1
	Firewallbanner.play("Moving in")
	FirewallButton.visible = false
	for nodes in VControllers:
		nodes.firewallactivate()
	sfx_firewall.play()


func _on_button_3_pressed() -> void:
	OverclockActive = true
	OverclockUsed = true
	OverclockButton.visible = false
	Singleton.PlayerPowerUps[activePlr - 1][2] -= 1
	sfx_overclock.play()
