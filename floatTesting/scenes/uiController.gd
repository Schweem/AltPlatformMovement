extends CanvasLayer

#UI COMPONENTS
@onready var scoreLabel : RichTextLabel = $score
@onready var levelLabel : RichTextLabel = $level

var score : int = 0
var level : int = 0
var region : int = 1

# Dialouge stuff
var talking : bool = false
var currentTalk : Dictionary = {"LOREM IPSUM DOLOR SIT AMET." : "PLAYER",
								"" : ""
								}
var breath : float = 0.1

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
	if Input.is_action_just_pressed("interact"):
		toggleDialouge()

func toggleDialouge():
	if !talking:
		talking = true
		if currentTalk != null:
			dialougeBox.visible = true
			var interactions : int = 0
			speakerLabel.text = currentTalk.values()[interactions] + " :"
			for letter in currentTalk.keys()[interactions]:
				if talking:
					dialougeLabel.text += letter
					await get_tree().create_timer(breath).timeout
				else:
					return
	else:
		talking = false
		dialougeBox.visible = false
		dialougeLabel.text = ""
		speakerLabel.text = ""
