extends CanvasLayer

#UI COMPONENTS
@onready var scoreLabel : RichTextLabel = $score
@onready var levelLabel : RichTextLabel = $level

var score : int = 0
var level : int = 0
var region : int = 1

# Dialouge stuff
var talking : bool = false
var currentTalk : Dictionary = {"..." : "PLAYER",
								".." : "PLAYER",
								"im done. FEZ II is canceled. goodbye" : "Phill fish",
								":(" : "PLAYER"
								}
var breath : float = 0.1
var advanceDelay : float = 0.5

@onready var dialougeLabel : RichTextLabel = $dialouge
@onready var speakerLabel : RichTextLabel = $speaker
@onready var dialougeBox : ColorRect = $lowerMargin

# Called when the node enters the scene tree for the first time.
func _ready():
	#UI
	scoreLabel.text = "SCORE:\n %05d" % [score]
	levelLabel.text = "WORLD:\n %d - %d" % [level, region]
	
	#DIALOUGE
	dialougeBox.visible = false
	dialougeLabel.text = ""
	speakerLabel.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateUI()
	
	if Input.is_action_just_pressed("interact") and !talking: #activate out here kill it inside 
		toggleDialouge()
		
func updateUI():
	scoreLabel.text = "SCORE:\n %05d" % [score]

func toggleDialouge():
	print('begin')
	if !talking:
		var interactions : int = 0
		if currentTalk != null:
			speak(currentTalk, interactions)
	else:
		talking = false
		dialougeBox.visible = false
		dialougeLabel.text = ""
		speakerLabel.text = ""
		
func speak(conversation, interactions):
	talking = true
	dialougeBox.visible = true
	print("enter speak")
	speakerLabel.text = conversation.values()[interactions] + " :"
	await get_tree().create_timer(advanceDelay).timeout # pause once done
	for letter in conversation.keys()[interactions]:
		if talking:
			print('newletter')
			dialougeLabel.text += letter
			await get_tree().create_timer(breath).timeout
		else:
			print('escaping')
			return
	await get_tree().create_timer(advanceDelay).timeout # pause once done
	if conversation.size() - 1 > interactions:
		interactions = interactions + 1
		dialougeLabel.text = ""
		speak(currentTalk, interactions)
	else:
		toggleDialouge()
