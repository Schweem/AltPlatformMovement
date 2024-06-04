extends Node2D

@export var myDialouge : Dictionary = {} #TODO -- do this better pls 

@onready var speechCheck : RayCast2D = $speechCast

signal new_conversation(conversation : Dictionary)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if speechCheck.is_colliding():
		if speechCheck.get_collider().is_in_group("player"):
			new_conversation.emit(myDialouge)
		else:
			pass
	else:
		pass
