extends Sprite2D

@onready var atkimg = load("res://images/atk-modified - Copy.png")
@onready var healimg = load("res://images/3-modified.png")
@onready var spellimg = load("res://images/4-modified.png")
@onready var nothingimg = load("res://images/2-modified.png")
@onready var nlabel = $number
@onready var chancein = $"../chanceindicator"
@onready var actionindicator = $"../actionindicator"
@onready var rolling = $"../rolling"
@onready var cplr = $"../currentplr"

@onready var SpellCDin = $"../spell/CDindicator"
@onready var healIN = $"../heal/healIndicator"

@onready var enemy = $"../enemy"
@onready var enemyhpbar = $"../enemy/ProgressBar"

@onready var phpbar = [$"../Control/player1hp", $"../Control/player2hp", $"../Control/player3hp", $"../Control/player4hp"]
@onready var plabel = [$"../Control/player1hp/Label", $"../Control/player2hp/Label2", $"../Control/player3hp/Label3", $"../Control/player4hp/Label4"]
@onready var enemyaction = $"../enemy/enemyaction"

@onready var n1 = $"../1"
@onready var n0 = $"../0"

var AllPlayers = [player1, player2, player3, player4]
var AllEnemyCD = []

var plr1preset = Vector2i(85, 97)
var plr2preset = [Vector2i(85, 71), Vector2i(85, 141)]
var plr3preset = [Vector2i(85, 27), Vector2i(85, 97), Vector2i(85, 167)]

var random = RandomNumberGenerator.new()
var inArea: bool
var valid: bool

var hacked: bool
var DOTDuration: int
var DOTDamage: int
var AllDead: int

var enemyDead: int

var success: bool
var cd: bool
var TankSpecialActive: bool
var MageSpecialActive: int
var curatkcount = 0
var hitchance = Singleton.Characters["DPS"]["stats"]["spellstartchance"]

var curplr = 1
var deb: bool

var halfdmgdebuff: bool

var inputcd: bool

func _ready():
	ResetAllVariables()
	var totalchance = Singleton.successchance + Singleton.failchance
	
	for i in Singleton.maxplrcount:
		AllPlayers[i].isDead = false
	
	if Singleton.CurrentEnemy == enemies.hacker:
		enemy.texture = enemies.hacker["img"]
		enemy.visible = true
		enemyhpbar.max_value = enemies.hacker["stats"]["hp"] * Singleton.maxplrcount
		enemyhpbar.value = enemies.hacker["stats"]["hp"] * Singleton.maxplrcount
		
		var attacks = enemies.hacker["attacks"]
		AllEnemyCD = [attacks["virus"], attacks["Firewall"]]
	
	if Singleton.CurrentEnemy == enemies.gpt:
		var multi = roundi(1.5 * Singleton.maxplrcount)
		var debuff = random.randi_range(1, 3)
		
		if debuff == 1:
			print("STUN DEBUFF")
			for i in Singleton.maxplrcount:
				if i == 0:
					var duration = random.randi_range(1, 3) - 1
					print("PLAYER " + str(i + 1) + " STUNNED FOR " + str(duration) + " TURN(S)")
					
					if duration != 0:
						AllPlayers[i].stunned = true
						AllPlayers[i].StunDuration = duration
					
						plabel[i].text = "Player " + str(i + 1) + "\n" + "(STUNNED)"
					
				else:
					var duration = random.randi_range(1, 3)
					print("PLAYER " + str(i) + " STUNNED FOR " + str(duration) + " TURN(S)")
					AllPlayers[i].stunned = true
					AllPlayers[i].StunDuration = duration
					
					plabel[i].text = "Player " + str(i + 1) + "\n" + "(STUNNED)"
			
			changecurplr()
			
		elif debuff == 2:
			print("HALF DMG DEBUFF")
			halfdmgdebuff = true
			
		elif debuff == 3:
			print("SPELL CD DEBUFF")
			for i in Singleton.maxplrcount:
				var duration = randi_range(1, 4)
				print("PLAYER " + str(i + 1) + " PLACED ON COOLDOWN FOR " + str(duration) + " TURN(S)")
				AllPlayers[i].SpellCD = true
				AllPlayers[i].SCDDuration = duration
			
			changeCDin(curplr - 1, true)
		
		enemy.texture = enemies.gpt["img"]
		enemy.visible = true
		enemyhpbar.max_value = enemies.gpt["stats"]["hp"] * multi
		enemyhpbar.value = enemies.gpt["stats"]["hp"] * multi
		
		var attacks = enemies.gpt["attacks"]
		AllEnemyCD = [attacks["rate limit"], attacks["Inject"]]
		
	if Singleton.maxplrcount == 1:
			phpbar[0].max_value = player1.character["stats"]["maxhp"]
			phpbar[0].value  = player1.character["stats"]["hp"]
			phpbar[0].position = plr1preset
			phpbar[0].visible = true
			
	elif Singleton.maxplrcount == 2:
		for i in range(2):
			phpbar[i].max_value = AllPlayers[i].character["stats"]["maxhp"]
			phpbar[i].value  = AllPlayers[i].character["stats"]["hp"]
			phpbar[i].position = plr2preset[i]
			phpbar[i].visible = true
			
	elif Singleton.maxplrcount == 3:
		for i in range(3):
			phpbar[i].max_value = AllPlayers[i].character["stats"]["maxhp"]
			phpbar[i].value  = AllPlayers[i].character["stats"]["hp"]
			phpbar[i].position = plr3preset[i]
			phpbar[i].visible = true
			
	elif Singleton.maxplrcount == 4:
		for i in range(4):
			phpbar[i].max_value = AllPlayers[i].character["stats"]["maxhp"]
			phpbar[i].value  = AllPlayers[i].character["stats"]["hp"]
			phpbar[i].visible = true
			
	
	if totalchance == 100:
		valid = true
	else:
		print("ERROR: Total percentage does not add up too 100, current percentage: " + str(totalchance))
	
	debugturn()
	
	#while true:
	#	await get_tree().create_timer(.5).timeout
	#	print(cd)

func _input(event: InputEvent) -> void:
	if event.is_action("click") and event.is_pressed() and inArea and not inputcd:
		#inputcd = true
		#print("Roll function call")
		if not valid: return
		if cd: return
		var chrdata = getcharacter(curplr)
		if curplr == Singleton.maxplrcount + 1: return
		var plr = AllPlayers[curplr - 1]
		#print("CURRENT ACTION: " + str(Singleton.currentaction))
		#damage("enemy", await DiceRoll())
		#print("INPUT RECEIVED")
		if Singleton.currentaction == "atk":
			cd = true
			#print("FROM DMG")
			var dmg = await DiceRoll()
			#print(1)
			if dmg != null:
				damage(0, dmg, 0)
		elif Singleton.currentaction == "heal":
			cd = true
			#print("FROM HEAL")
			var dmg = await DiceRoll()
			#print(2)
			if dmg == null: return
			if chrdata["name"] == "Healer":
				var target = await findLowestHP()
				print("CURRENT TARGET: " + str(target))
				damage(7, dmg, target)
			else:
				if dmg != null:
					damage(9, dmg, 0)
		elif Singleton.currentaction == "spell" and not plr.SpellCD:
			#print(3)
			cd = true
			#print("FROM SPELL")
			rotatespellcd(curplr - 1, true)
			SpellRoll()
		
		elif plr.SpellCD:
			#print("CD")
			changechancin("SPELL COOLDOWN", Color.RED, true)
			get_tree().create_timer(.5).timeout
			
		
		#await get_tree().create_timer(2).timeout
		#print("DEBUF")
		#inputcd = false
	
	if event.is_action("debug") and event.is_pressed():
		debugturn()



func _physics_process(delta: float) -> void:
	
	if player1.isDead and player2.isDead and player3.isDead and player4.isDead:
		deb = true
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://main.tscn")
	
	if enemyhpbar.value == 0:
		enemyDead = true
		for i in Singleton.maxplrcount:
			AllPlayers[i].SpellCD = false
			AllPlayers[i].SCDDuration = 0
			AllPlayers[i].stunned = false
			AllPlayers[i].StunDuration = 0
		
		await get_tree().create_timer(.25).timeout
		get_tree().change_scene_to_file("res://main.tscn")
	
	if player1.isDead and player2.isDead and player3.isDead and player4.isDead: return
	
	for i in range(Singleton.maxplrcount):
		if AllPlayers[i].character["stats"]["hp"] <= 0:
			#print(str(AllPlayers[i]) + " is dead")
			AllPlayers[i].isDead = true
			AllPlayers[i].character["stats"]["hp"] = 0
	
	for i in range(Singleton.maxplrcount):
		if AllPlayers[i].isDead:
			phpbar[i].visible = false
	
	if not hacked:
		n0.visible = false
		n1.visible = false
		return
	var rgn = random.randi_range(1, 2)
	n0.visible = true
	n1.visible = true
	if rgn == 1:
		spawnrandom(n0)
	else:
		spawnrandom(n1)
	
func _on_area_2d_mouse_entered() -> void:
	#print("Entered")
	inArea = true


func _on_area_2d_mouse_exited() -> void:
	#print("Exited")
	inArea = false

func _on_atk_pressed() -> void:
	actionChange("atk")


func _on_heal_pressed() -> void:
	actionChange("heal")


func _on_spell_pressed() -> void:
	actionChange("spell")

func actionChange(action):
	Singleton.currentaction = action
	if action == "atk":
		actionindicator.texture = atkimg
	elif action == "heal":
		actionindicator.texture = healimg
	elif action == "spell":
		actionindicator.texture = spellimg
	curplrstatchange(true, false, action, 0)
	#debugturn()

func rollintermission():
	rolling.visible = true
	rolling.text = "ROLLING."
	await get_tree().create_timer(.25).timeout
	rolling.text = "ROLLING.."
	await get_tree().create_timer(.25).timeout
	rolling.text = "ROLLING..."
	await get_tree().create_timer(.25).timeout
	rolling.visible = false

func changechancin(text, color: Color, v):
	chancein.text = text
	chancein.label_settings.font_color = color
	
	if v:
		chancein.visible = true
	else:
		chancein.visible = false

func curplrstatchange(action, value, v1, v2):
	if action:
		if curplr == 1:
			player1.action[0] = v1
		elif curplr == 2:
			player2.action[0] = v1
		elif curplr == 3:
			player3.action[0] = v1
		elif curplr == 4:
			player4.action[0] = v1
	elif value:
		if curplr == 1:
			player1.action[1] = v2
		elif curplr == 2:
			player2.action[1] = v2
		elif curplr == 3:
			player3.action[1] = v2
		elif curplr == 4:
			player4.action[1] = v2

func debugturn():
	print("---- CURRENT ACTION AND ENEMY ----")
	print(Singleton.CurrentEnemy)
	print(Singleton.currentaction)
	
	print("---- PLAYER CHARACTERS ----")
	print("PLAYER 1: " + str(player1.character))
	print("PLAYER 2: " + str(player2.character))
	print("PLAYER 3: " + str(player3.character))
	print("PLAYER 4: " + str(player4.character))
	
	print("---- PLAYER HP BAR VALUES ----")
	print("PLAYER 1: " + str(phpbar[0].value))
	print("PLAYER 2: " + str(phpbar[1].value))
	print("PLAYER 3: " + str(phpbar[2].value))
	print("PLAYER 4: " + str(phpbar[3].value))
	
	print("---- CURRRENT STATUS ----")
	print("DOT DURATION: " + str(DOTDuration))
	for i in AllPlayers:
		print(i.StunDuration)
	
	print("---- ENEMY STATUS ----")
	print("Max HP: " + str(enemyhpbar.max_value))
	print("HP: " + str(enemyhpbar.value))

func changecurplr():
	if AllDead: return
	if get_tree(): await get_tree().create_timer(.1).timeout
	cd = true
	#print("FROM CHANGING PLR")
	if curplr < Singleton.maxplrcount + 1:
		curplr = curplr + 1
		#print(Singleton.maxplrcount)
	else:
		curplr = 1
		if DOTDuration > 0:
			DOTDuration -= 1
		
			if DOTDuration == 0:
				hacked = false
	
	print("CURRENT TURN IS : " + str(curplr))
	
	if curplr != Singleton.maxplrcount + 1:
		var cdata = getcharacter(curplr)
		if AllPlayers[curplr - 1].isDead:
			changecurplr()
			#print("CURRENT PLAYER IS DEAD, ROTATING.")
			return
		cplr.text = "CURRENT TURN: " + "Player: " + str(curplr)
		
	else:
		cplr.text = "CUURENT TURN: " + str((Singleton.CurrentEnemy["name"]))
	
	if curplr == Singleton.maxplrcount + 1:
		cd = true
		#print("FROM CHANGE TO BOSS")
		
		changeCDin(curplr - 1, false)
		for i in AllEnemyCD:
			rotateenemycd(i, false)
		
		if MageSpecialActive > 0:
			MageSpecialActive -= 1
			enemyaction.text  = "STUNNED: " + str(MageSpecialActive) + " Turn(s)"
			
			if MageSpecialActive == 0:
				enemyaction.text = ""
				enemyaction.visible = false
				
			cd = false
			#print("STOPPING CD FROM ENEMY STUNNED")
			changecurplr()
			return
		else:
			await enemyatk()
			
	elif curplr == 1:
		actionChange(player1.action[0])
		rotatespellcd(0, false)
		
		if AllPlayers[curplr - 1].SpellCD:
			changeCDin(curplr - 1, true)
		else:
			changeCDin(curplr - 1, false)
		
		if DOTDuration > 0:
			#print("DOT Duration: " + str(DOTDuration))
			damage(10, DOTDamage, 0)
		
		if player1.stunned:
			player1.StunDuration -= 1
			
			plabel[0].text = "Player 1" + "\n" + "(STUNNED)"
			
			if player1.StunDuration == 0:
				player1.stunned = false
				plabel[0].text = "Player 1"
			
			changecurplr()
			return
		else: pass
		
	elif curplr == 2:
		actionChange(player2.action[0])
		rotatespellcd(1, false)
		
		if DOTDuration > 0:
			#print("DOT Duration: " + str(DOTDuration))
			damage(10, DOTDamage, 0)
			
		if AllPlayers[curplr - 1].SpellCD:
			changeCDin(curplr - 1, true)
		else:
			changeCDin(curplr - 1, false)
		
		if player2.stunned:
			player2.StunDuration -= 1
			
			plabel[1].text = "Player 2" + "\n" + "(STUNNED)"
			
			if player2.StunDuration == 0:
				player2.stunned = false
				plabel[1].text = "Player 2"
			
			changecurplr()
			return
		else: pass
		
	elif curplr == 3:
		actionChange(player3.action[0])
		rotatespellcd(2, false)
		
		if DOTDuration > 0:
			#print("DOT Duration: " + str(DOTDuration))
			damage(10, DOTDamage, 0)
			
		if AllPlayers[curplr - 1].SpellCD:
			changeCDin(curplr - 1, true)
		else:
			changeCDin(curplr - 1, false)
		
		if player3.stunned:
			player3.StunDuration -= 1
			
			plabel[2].text = "Player 3" + "\n" + "(STUNNED)"
			
			if player3.StunDuration == 0:
				player3.stunned = false
				plabel[2].text = "Player 3"
			
			changecurplr()
			return
		else: pass
		
	elif curplr == 4:
		actionChange(player4.action[0])
		rotatespellcd(3, false)
		
		if DOTDuration > 0:
			#print("DOT Duration: " + str(DOTDuration))
			damage(10, DOTDamage, 0)
			
		if AllPlayers[curplr - 1].SpellCD:
			changeCDin(curplr - 1, true)
		else:
			changeCDin(curplr - 1, false)
		
		if player4.stunned:
			player4.StunDuration -= 1
			
			plabel[3].text = "Player 4" + "\n" + "(STUNNED)"
			
			if player4.StunDuration == 0:
				player4.stunned = false
				plabel[3].text = "Player 4"
			
			changecurplr()
			return
		else: pass
		
	
	cd = false
	#print("STOPPING CD FROM CHANGE PLR")
	
func damage(target, amount, attack):
	#print("TARGET: " + str(target))
	#print("AMOUNT: " + str(amount))
	
	if target == 10:
		if curplr == Singleton.maxplrcount + 1: return
		if AllPlayers[curplr - 1].character["name"] == "Tank":
			var reduced = amount * 0.6
			#print("REDUCED: " + str(reduced))
			AllPlayers[curplr - 1].character["stats"]["hp"] -= roundi(reduced)
			phpbar[curplr - 1].value = AllPlayers[curplr - 1].character["stats"]["hp"]
			#print("Normal dmg: " + str(amount))
			#print("Reduced dmg: " + str(roundi(reduced)))
		else:
			AllPlayers[curplr - 1].character["stats"]["hp"] -= amount
			phpbar[curplr - 1].value = AllPlayers[curplr - 1].character["stats"]["hp"]
				
	elif target == 9:
		if curplr == Singleton.maxplrcount + 1: return
		AllPlayers[curplr - 1].character["stats"]["hp"] += amount
		phpbar[curplr - 1].value = AllPlayers[curplr - 1].character["stats"]["hp"]
		await changecurplr()
		
	
	elif target == 8:
		for i in Singleton.maxplrcount:
				AllPlayers[i].character["stats"]["hp"] += amount
				phpbar[i].value = AllPlayers[i].character["stats"]["hp"]
		
	elif target == 7:
		
		AllPlayers[attack].character["stats"]["hp"] += amount
		phpbar[attack].value = AllPlayers[attack].character["stats"]["hp"]
		await changecurplr()
		
		
	elif target == 6:
		
		for i in Singleton.maxplrcount:
			var dmg = (AllPlayers[i].character["stats"]["maxhp"] * 0.5)
			dmg = roundi(dmg)
			print(dmg)
			AllPlayers[i].character["stats"]["hp"] -= dmg
			phpbar[i].value = AllPlayers[i].character["stats"]["hp"]
			
			
		await changecurplr()
	elif target == 0:
		
		if halfdmgdebuff and amount > 0:
			print("DAMAGED HALVED, NORMAL DMG: " + str(amount) + ", HALVED DMG: " + str(roundi(amount / 2)))
			enemyhpbar.value -= roundi(amount / 2)
		else:
			enemyhpbar.value -= amount
		
		await changecurplr()
		
		
	else:
		#print("MAX PLR COUNT: " + str(Singleton.maxplrcount))
		
		if attack["AOE"]:
			for i in Singleton.maxplrcount:
				if AllPlayers[i].character["name"] == "Tank":
					var reduced = amount * 0.6
					#print("REDUCED: " + str(reduced))
					AllPlayers[i].character["stats"]["hp"] -= roundi(reduced)
					phpbar[i].value = AllPlayers[i].character["stats"]["hp"]
					#print("Normal dmg: " + str(amount))
					#print("Reduced dmg: " + str(roundi(reduced)))
					
				else:
					AllPlayers[i].character["stats"]["hp"] -= amount
					phpbar[i].value = AllPlayers[i].character["stats"]["hp"]
			
			await changecurplr()
		else:
			#print(str(AllPlayers[target - 1]))
			if AllPlayers[target - 1].character["name"] == "Tank":
				var reduced = amount * 0.6
				#print("REDUCED: " + str(reduced))
				AllPlayers[target - 1].character["stats"]["hp"] -= roundi(reduced)
				phpbar[target - 1].value = AllPlayers[target - 1].character["stats"]["hp"]
				#print("Normal dmg: " + str(amount))
				#print("Reduced dmg: " + str(roundi(reduced)))
				
			else:
				AllPlayers[target - 1].character["stats"]["hp"] -= amount
				phpbar[target - 1].value = AllPlayers[target - 1].character["stats"]["hp"]
			
			await changecurplr()
	
	for i in Singleton.maxplrcount:
		if AllPlayers[i].character["stats"]["hp"] <= 0:
			AllPlayers[i].character["stats"]["hp"] = 0
			AllPlayers[i].isDead = true
			
			var data = getcharacter(curplr)
			if data["name"] == AllPlayers[i].character["name"]:
				print("PLAYER IS DEAD.")
				changecurplr()
		
		elif AllPlayers[i].character["stats"]["hp"] > phpbar[i].max_value:
			print("OVERHEAL: " + str(AllPlayers[i]))
			AllPlayers[i].character["stats"]["hp"] = phpbar[i].max_value
			#print("Player " + str(AllPlayers[i]) + " died.")
	
	#await get_tree().create_timer(.3).timeout
	#if cd:
	#	print("COOLDOWN IS STILL ACTIVE. DEACTIVATING CD.")
	#	cd = false

func spawnrandom(obj):
	if not get_tree(): return
	var rng = RandomNumberGenerator.new()
	var screen_size = get_viewport().get_visible_rect().size
	var rx = rng.randi_range(0, screen_size.x)
	var ry = rng.randi_range(0, screen_size.y)
	
	obj.position = Vector2i(rx, ry)

func enemyatk():
	if Singleton.CurrentEnemy == enemies.hacker:
		var curatk = randi_range(1, 3)
		var curtg = await getvalidtarget()
		#print("CURRENT TARGET: " + str(curtg))
		if curtg == null:
			print("TARGET IS NULL")
		
		if curatk == 1 and not hacked and enemies.hacker["attacks"]["virus"]["cd"] == 0:
			rotateenemycd(enemies.hacker["attacks"]["virus"], true)
			enemyaction.visible = true
			await textintermission(enemyaction, "Deploying virus")
			enemyaction.visible = false
			damage(curtg, enemies.hacker["attacks"]["virus"]["dmg"], enemies.hacker["attacks"]["virus"])
			hacked = true
			DOTDuration = enemies.hacker["attacks"]["virus"]["DOTDuration"]
			DOTDamage = enemies.hacker["attacks"]["virus"]["DOTdmg"]
			
		elif curatk == 2 and enemies.hacker["attacks"]["hack"]["cd"] == 0:
			enemyaction.visible = true
			await textintermission(enemyaction, "Hacking " + str(curtg))
			enemyaction.visible = false
			damage(curtg, enemies.hacker["attacks"]["hack"]["dmg"], enemies.hacker["attacks"]["hack"])
			
		elif curatk == 3 and enemyhpbar.value < 100 and enemies.hacker["attacks"]["Firewall"]["cd"] == 0:
			rotateenemycd(enemies.hacker["attacks"]["Firewall"], true)
			enemyaction.visible = true
			await textintermission(enemyaction, "Deploying firewall")
			enemyaction.visible = false
			damage(0, enemies.hacker["attacks"]["Firewall"]["dmg"], enemies.hacker["attacks"]["Firewall"])
			
		else:
			print("rerolling attack")
			enemyatk()
	
	elif Singleton.CurrentEnemy == enemies.gpt:
		if AllDead: return
		var curatk = randi_range(1, 4)
		var curtg = await getvalidtarget()
		#print("CURRENT TARGET: " + str(curtg))
		if curtg == null:
			print("TARGET IS NULL")
			return
		
		if enemyhpbar.value <= enemyhpbar.max_value * 0.5:
			stunrandom()
			print("Stunning random")
		
		if enemies.gpt["attacks"]["Data recovery"]["cd"] == 0 and enemyhpbar.value < enemyhpbar.max_value * 0.2:
			rotateenemycd(enemies.gpt["attacks"]["Data recovery"], true)
			enemyaction.visible = true
			await textintermission(enemyaction, "Initiating data recovery")
			enemyaction.visible = false
			
			var recover = ((enemyhpbar.max_value * enemies.gpt["attacks"]["Data recovery"]["dmg"]) * -1) + enemyhpbar.value
			print(recover)
			damage(0, recover, enemies.gpt["attacks"]["Data recovery"])
			
		elif curatk == 1:
			enemyaction.visible = true
			await textintermission(enemyaction, "Generating response for " + str(curtg))
			enemyaction.visible = false
			damage(curtg, enemies.hacker["attacks"]["hack"]["dmg"], enemies.hacker["attacks"]["hack"])
			
		elif curatk == 2 and not hacked and enemies.gpt["attacks"]["Inject"]["cd"] == 0:
			rotateenemycd(enemies.gpt["attacks"]["Inject"], true)
			enemyaction.visible = true
			await textintermission(enemyaction, "Injecting logic decay")
			enemyaction.visible = false
			damage(curtg, enemies.gpt["attacks"]["Inject"]["dmg"], enemies.gpt["attacks"]["Inject"])
			hacked = true
			DOTDuration = enemies.gpt["attacks"]["Inject"]["DOTDuration"]
			DOTDamage = enemies.gpt["attacks"]["Inject"]["DOTdmg"]
			
		elif curatk == 3 and enemies.gpt["attacks"]["rate limit"]["cd"] == 0:
			rotateenemycd(enemies.gpt["attacks"]["rate limit"], true)
			enemyaction.visible = true
			await textintermission(enemyaction, "Rate limiting " + str(curtg))
			enemyaction.visible = false
			
			AllPlayers[curtg - 1].stunned = true
			AllPlayers[curtg - 1].StunDuration = enemies.gpt["attacks"]["rate limit"]["stunDuration"]
			
			plabel[curtg - 1].text = "Player " + str(curtg) + "\n" + "(STUNNED)"
			
			damage(curtg, enemies.gpt["attacks"]["rate limit"]["dmg"], enemies.gpt["attacks"]["rate limit"])
			
		elif curatk == 4 and enemies.gpt["attacks"]["Logic bomb"]["cd"] == 0 and enemyhpbar.value < enemyhpbar.max_value * 0.5:
			rotateenemycd(enemies.gpt["attacks"]["Logic bomb"], true)
			
			for i in Singleton.maxplrcount:
				var srng = randi_range(1, 2)
				
				if AllPlayers[i].character["name"] == "Healer":
					rotatespellcd(i, true)
					pass
				
				if srng == 1:
					
					AllPlayers[i].stunned = true
					AllPlayers[i].StunDuration = enemies.gpt["attacks"]["rate limit"]["stunDuration"]
				
					plabel[i].text = "Player " + str(i + 1) + "\n" + "(STUNNED)"
				
			
			enemyaction.visible = true
			await textintermission(enemyaction, "Deploying logic bomb")
			enemyaction.visible = false
			
			
			damage(6, enemies.gpt["attacks"]["Logic bomb"]["dmg"], enemies.gpt["attacks"]["Logic bomb"])
			
		else:
			#print("rerolling attack")
			enemyatk()

func DiceRoll():
	var rng = randi_range(1, 100)
	#print(rng)
	var chrdata = getcharacter(curplr)
	await rollintermission()
	
	if chrdata["name"] == "DPS":
		rng += chrdata["stats"]["atkchancemod"]
	else: pass
	
	if rng <= Singleton.failchance:
		nlabel.text = str(rng)
		changechancin("FAILED!", Color.RED, true)
		nlabel.label_settings.font_color = Color.RED
		await changecurplr()
		#debugturn()
		
		success = false
		await get_tree().create_timer(.5).timeout
		if curplr != Singleton.maxplrcount + 1:
			cd = false
			print("Disabling cd")
		

	elif rng > Singleton.failchance:
		nlabel.text = str(rng)
		changechancin("SUCCESS!", Color.GREEN, true)
		nlabel.label_settings.font_color = Color.GREEN
		
		success = true
	
	if success:
		await rollintermission()
		
		var rng2 = randi_range(1, Singleton.effectivenessinterval * 3)
		#print(Singleton.effectivenessinterval * 3)
		
		if Singleton.currentaction == "atk":
			rng2 = rng2 + chrdata["stats"]["atkmod"]
		elif Singleton.currentaction == "heal":
			rng2 = rng2 + chrdata["stats"]["healmod"]
		elif Singleton.currentaction == "spell":
			rng2 = rng2 + chrdata["stats"]["spellmod"]
		
		if Singleton.currentaction == "atk" and chrdata["name"] == "DPS":
			var dpscritrng = random.randi_range(1, chrdata["stats"]["critchance"])
			var dpslsrng = random.randi_range(1, chrdata["stats"]["lifestealchance"])
			print("CRIT RNG: " + str(dpscritrng))
			print("LIFESTEAL RNG: " + str(dpslsrng))
			if dpscritrng == 1:
				print("Normal damage: " + str(rng2))
				rng2 *= chrdata["stats"]["critmulti"]
				rng2 = roundi(rng2)
				print("Increased damage: " + str(rng2))
			else:
				pass
			
			if dpslsrng == 1:
				var lsamount = roundi(rng2 * chrdata["stats"]["lifestealpercent"])
				print(lsamount)
				chrdata["stats"]["hp"] += lsamount
				phpbar[curplr - 1].value = chrdata["stats"]["hp"]
		else:
			pass
		#print(rng2)
		
		if rng2 <= Singleton.effectivenessinterval:
			nlabel.text = str(rng2)
			changechancin(Singleton.effectiveness[0], Color.ORANGE_RED, true)
			nlabel.label_settings.font_color = Color.ORANGE_RED
			
			curplrstatchange(false, true, null, rng2)
			#debugturn()
			
			
		elif rng2 <= Singleton.effectivenessinterval * 2:
			nlabel.text = str(rng2)
			changechancin(Singleton.effectiveness[1], Color.YELLOW, true)
			nlabel.label_settings.font_color = Color.YELLOW
			curplrstatchange(false, true, null, rng2)
			#debugturn()
			
			
		elif rng2 <= Singleton.effectivenessinterval * 3:
			nlabel.text = str(rng2)
			changechancin(Singleton.effectiveness[2], Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			curplrstatchange(false, true, null, rng2)
			#debugturn()
			
		else:
			nlabel.text = str(rng2)
			changechancin("CRITICAL!", Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			curplrstatchange(false, true, null, rng2)
			#debugturn()
		return rng2

func getcharacter(plr):
	if plr == Singleton.maxplrcount + 1:
		return Singleton.CurrentEnemy
	elif plr == 1:
		return player1.character
	elif plr == 2:
		return player2.character
	elif plr == 3:
		return player3.character
	elif plr == 4:
		return player4.character

func textintermission(label, txt: String):
	
	if not get_tree(): return
	label.text = txt + "."
	await get_tree().create_timer(.3).timeout
	label.text = txt + ".."
	await get_tree().create_timer(.3).timeout
	label.text = txt + "..."
	await get_tree().create_timer(.3).timeout

func SpellRoll():
	var rng = randi_range(1, 100)
	#print(rng)
	var chrdata = getcharacter(curplr)
	await rollintermission()
	
	rng += chrdata["stats"]["spellmod"]
	
	if rng <= Singleton.failchance:
		nlabel.text = str(rng)
		changechancin("FAILED!", Color.RED, true)
		nlabel.label_settings.font_color = Color.RED
		#debugturn()
		
		await get_tree().create_timer(.5).timeout
		changecurplr()
		
	elif rng > Singleton.failchance:
		nlabel.text = str(rng)
		
		if chrdata["name"] == "DPS":
			
			changechancin("Cyberbully!", Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			
			DPSSpecial()
			
			#await get_tree().create_timer(.5).timeout
			#if curplr != Singleton.maxplrcount + 1: cd = false
			#changecurplr()
		
		elif chrdata["name"] == "Tank":
			TankSpecialActive = true
			
			changechancin("Force target!", Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			
			await get_tree().create_timer(.5).timeout
			changecurplr()
			
		elif chrdata["name"] == "Healer":
			damage(8, random.randi_range(25, 45), 0)
			DOTDuration = 0
			hacked = false
			
			for i in Singleton.maxplrcount:
				AllPlayers[i].stunned = false
				AllPlayers[i].StunDuration = 0
				plabel[i].text = "Player " + str(i + 1)
			
			changechancin("Healed everyone!", Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			
			await get_tree().create_timer(.5).timeout
			changecurplr()
			
		elif chrdata["name"] == "Mage":
			changechancin("Enemy stunned!", Color.GREEN, true)
			nlabel.label_settings.font_color = Color.GREEN
			
			MageSpecialActive = 2
			enemyaction.visible = true
			enemyaction.text  = "STUNNED: " + str(MageSpecialActive) + " Turn(s)"
			
			await get_tree().create_timer(.5).timeout
			changecurplr()
			

func getvalidtarget():
	
	if AllDead: return
	if TankSpecialActive:
		#print("Tank special detected")
		for i in Singleton.maxplrcount:
			var data = getcharacter(i + 1)
			if data["name"] == "Tank":
				#print("Setting active to false")
				TankSpecialActive = false
				return i + 1
	else:
		var result: int
		while true:
			if not get_tree(): return
			await get_tree().create_timer(.01).timeout
			
			result = random.randi_range(1, Singleton.maxplrcount)
			var data = AllPlayers[result - 1]
				
			#print("CURRENT: " + str(result))
			
			if not data.isDead:
				#print("FOUND VALID TARGET: " + str(result))
				break
		
		return result

func ResetAllVariables():
	valid = false
	hacked = false
	DOTDuration = 0
	DOTDamage = 0
	AllDead = false

	success = false
	cd = false
	TankSpecialActive = false
	MageSpecialActive = 0
	
	enemyDead = false
	halfdmgdebuff = false
	
	curplr = 1
	deb = false
	
	print("Resetted all variables.")

func rotatespellcd(plr, reset: bool):
	if not reset:
		if AllPlayers[plr].SCDDuration > 0:
			AllPlayers[plr].SCDDuration -= 1
			#print("Lowered CD of " + str(plr) + " to " + str(AllPlayers[plr].SCDDuration))
		
			if AllPlayers[plr].SCDDuration == 0:
				#print("CD is zero")
				AllPlayers[plr].SpellCD = false
		
		elif AllPlayers[plr].SCDDuration == 0:
			#print("CD is zero")
			AllPlayers[plr].SpellCD = false
			
	elif reset:
		var cdata = getcharacter(plr + 1)
		#print("Resetting player " + str(plr + 1))
		AllPlayers[plr].SpellCD = true
		if cdata["name"] == "DPS":
			AllPlayers[plr].SCDDuration = 5
			
		elif cdata["name"] == "Tank":
			AllPlayers[plr].SCDDuration = 2
			
		elif cdata["name"] == "Healer":
			AllPlayers[plr].SCDDuration = 3
			
		elif cdata["name"] == "Mage":
			AllPlayers[plr].SCDDuration = 4

func rotateenemycd(atk, reset):
	#print("call receieved")
	if not reset and atk["cd"] > 0:
		atk["cd"] -= 1
		#print("Lowered enemy cd")
			
	elif reset:
		atk["cd"] = atk["defcd"]
		#print("Resetted " + str(atk) + " cd to " + str(enemies.hacker["attacks"]["virus"]["cd"])) 

func changeCDin(plr, vis: bool):
	if vis:
		SpellCDin.visible = true
	else:
		SpellCDin.visible = false
		
	if plr == Singleton.maxplrcount:
		return
	else:
		SpellCDin.text = "COOLDOWN: " + str(AllPlayers[plr].SCDDuration)

func findLowestHP():
	var Lowest = 10000
	var current
	for i in Singleton.maxplrcount:
		var data = getcharacter(i + 1)
		#print("LOOPING: " + str(i))
		if data["stats"]["hp"] < Lowest and not AllPlayers[i].isDead:
			Lowest = data["stats"]["hp"]
			current = i
			#print("UPDATED CURRENT: " + str(current))
		else:
			pass
			#print("Current: " + str(Lowest) + ", data: " + str(data["stats"]["hp"]))
	#print("RETURNING: " + str(current))
	return current

func DPSSpecial():
	var rng = random.randi_range(1, 100)
	var dmg = roundi(enemyhpbar.max_value * 0.05)
	var chrdata = getcharacter(curplr)
	var lsrng = random.randi_range(1, chrdata["stats"]["lifestealchance"])
	print(lsrng)
	
	if random.randi_range(1, chrdata["stats"]["critchance"]) == 1:
		dmg *= 1.25
		dmg = roundi(dmg)
	
	
	
	if curatkcount == 0:
		nlabel.text = str(dmg)
		nlabel.label_settings.font_color = Color.AQUA
		
		enemyhpbar.value -= dmg
		curatkcount += 1
		
		if lsrng == 1:
			var lsamount = roundi(dmg * chrdata["stats"]["lifestealpercent"])
			chrdata["stats"]["hp"] += lsamount
			phpbar[curplr - 1].value = chrdata["stats"]["hp"]
			print(lsamount)
		
		changechancin("ATTACK " + str(curatkcount), Color.AQUA, true)
		
		await get_tree().create_timer(.5).timeout
		DPSSpecial()
		
	else:
		if rng <= hitchance:
			nlabel.text = str(dmg)
			nlabel.label_settings.font_color = Color.AQUA
			
			if lsrng == 1:
				var lsamount = roundi(dmg * chrdata["stats"]["lifestealpercent"])
				chrdata["stats"]["hp"] += lsamount
				phpbar[curplr - 1].value = chrdata["stats"]["hp"]
				print(lsamount)
			
			enemyhpbar.value -= dmg
			curatkcount += 1
			if hitchance > 10:
				hitchance -= 10
			
			changechancin("ATTACK " + str(curatkcount), Color.AQUA, true)
			await get_tree().create_timer(.5).timeout
			DPSSpecial()
		
		else:
			print("ATK END; MISSED")
			await get_tree().create_timer(.5).timeout
			
			curatkcount = 0
			hitchance = Singleton.Characters["DPS"]["stats"]["spellstartchance"]
			
			changecurplr()
			
	
	print("CURRENT ATTACK: " + str(curatkcount))
	print("CURRENT HIT CHANCE: " + str(hitchance))

func stunrandom():
	for i in Singleton.maxplrcount:
		var rng = random.randi_range(1, 3)
		
		if rng == 1:
			AllPlayers[i].stunned = true
			AllPlayers[i].StunDuration = 1
			
			plabel[i].text = "Player " + str(i + 1) + "\n" + "(STUNNED)"
			
