extends Node

var hacker = {
	"name": "Hacker",
	"attacks": {
		"virus": {
			"dmg": 15,
			"AOE": true,
			"DOT": true,
			"DOTdmg": 10,
			"DOTDuration": 3,
			"SFX": "binary",
			"cd": 0,
			"defcd": 7
		},
		
		"hack": {
			"dmg": 25,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 0
		},
		
		"Firewall": {
			"dmg": -50,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 6
			
		},
	},
	"stats": {
		"hp" : 150,
		"atkmod" : 0,
		"healmod": 0,
		"spellmod": 0,
	},
	
	"img": load("res://images/hecker.png")
}

var gpt = {
	"name": "GPT",
	
	"attacks": {
		"response": {
			"dmg": 35,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 0
		},
		
		"Inject": {
			"dmg": 30,
			"AOE": true,
			"DOT": true,
			"DOTdmg": 15,
			"DOTDuration": 3,
			"cd": 0,
			"defcd": 6
		},
		
		"rate limit": {
			"dmg": 35,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 4,
			"stun": true,
			"stunDuration": 2
		},
		
		"Data recovery": {
			"dmg": 0.5,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 999
		},
		
		"Logic bomb": {
			"dmg": 0.5,
			"AOE": false,
			"DOT": false,
			"DOTdmg": 0,
			"DOTDuration": 0,
			"cd": 0,
			"defcd": 999
		}
	},
	
	"stats": {
		"hp" : 250,
		"atkmod" : 0,
		"healmod": 0,
		"spellmod": 0,
	},
	
	"img": load("res://images/gpt-removebg-preview.png")
}
