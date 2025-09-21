extends Node2D

@onready var Antivirus = $"Antivirus Entrance/AnimationPlayer"
@onready var virus = $"Virus Entrance/AnimationPlayer"

func _ready():
	Antivirus.play("Entracescene")
	virus.play("Virusentrance")
