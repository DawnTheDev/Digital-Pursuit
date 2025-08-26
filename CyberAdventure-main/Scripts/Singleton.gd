extends Node

var maxplrcount: int
var currentaction = "atk"
var healbuff = 25

var CurrentEnemy

var Characters = {
	"DPS": {
		"name": "DPS",
		
		"stats": {
			"maxhp": 75,
			"hp" : 75,
			"atkmod" : 30,
			"healmod": -30,
			"spellmod": 0,
			"atkchancemod": 10,
			"spellstartchance": 100,
			"critmulti": 1.5,
			"critchance": 3,
			"lifestealchance": 2,
			"lifestealpercent": 0.3
		}
	},
	
	"Tank": {
		"name": "Tank",
		
		"stats": {
			"maxhp": 150,
			"hp" : 150,
			"atkmod" : -15,
			"healmod": -30,
			"spellmod": 0,
		}
	},
	
	"Healer": {
		"name": "Healer",
		
		"stats": {
			"maxhp": 100,
			"hp" : 100,
			"atkmod" : -10,
			"healmod": 30,
			"spellmod": 0,
		}
	},
	
	"Mage": {
		"name": "Mage",
		
		"stats": {
			"maxhp": 100,
			"hp" : 100,
			"atkmod" : 0,
			"healmod": -20,
			"spellmod": 10,
		}
	},
}

# DICE CONFIGS
var successchance = 60
var failchance = 40

var effectivenessinterval = 30
var effectiveness = ["LOW", "MEDIUM", "HIGH"]
