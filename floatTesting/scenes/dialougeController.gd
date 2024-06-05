extends Node2D

@export var myDialouge : Dictionary = {} #TODO -- do this better pls 

@onready var speechCheck : RayCast2D = $speechCast

@onready var myName : RichTextLabel = $RichTextLabel
@onready var showName : bool = false
var charName : String #TODO -- hook this up to dictionary and get color

signal new_conversation(conversation : Dictionary)
signal clear_conversation(conversation : Dictionary)


# Called when the node enters the scene tree for the first time.
func _ready():
	myName.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if speechCheck.is_colliding():
		if speechCheck.get_collider().is_in_group("player"):
			new_conversation.emit(myDialouge)
			if !showName:
				showCharName()
		else:
			pass
	else:
		clear_conversation.emit({})

func showCharName():
	findMyName()
	showName = true
	if myName.get_parent().scale.x <= 0:
		myName.scale = myName.get_parent().scale * Vector2(1,1) / myName.get_parent().scale.y
		myName.position.x = myName.position.x + 16
	myName.remove_paragraph(0)
	myName.append_text(charName)
	myName.visible = true
	
func findMyName():
	for name in myDialouge.values():
		if name != "player":
			charName = name
			break
