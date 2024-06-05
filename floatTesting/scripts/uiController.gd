extends CanvasLayer

#UI COMPONENTS
@onready var scoreLabel : RichTextLabel = $score
@onready var levelLabel : RichTextLabel = $level

var score : int = 0
var level : int = 0
var region : int = 1

# Dialouge stuff
var talking : bool = false
var currentTalk : Dictionary = {"..." : "player",
								".." : "player",
								"im done. FEZ II is canceled. goodbye" : "Phill fish",
								":(" : "player",
								"I'm josh" : "josh" }
var breath : float = 0.1
var advanceDelay : float = 0.5

var colorDict : Dictionary = {} # store the dialouge colors of all the people we've met along the way 
var starterColors : Array = [Color.GOLD, Color.FIREBRICK, Color.LIGHT_GREEN, Color.AQUA, Color.CHOCOLATE,
							Color.BLUE_VIOLET, Color.DARK_TURQUOISE, Color.PALE_VIOLET_RED]
var colorCount : int = 0

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
	if !talking:
		var interactions : int = 0 # dialouge counter
		if currentTalk != null:
			speak(currentTalk, interactions) 
	else:
		talking = false
		cleanUpLabels(speakerLabel, dialougeLabel)
		currentTalk = {}
		dialougeBox.visible = false

# func -- speak
# args -- conversation dictionary, start index (prob 0)
#
# Begin, progress, and end dialouge. Can change word and pause speed.
func speak(conversation : Dictionary, interactions : int):
	if currentTalk != {}:
		if interactions == 0:
			assignColors(conversation)
		talking = true # set talking true
		dialougeBox.visible = true # enable the ui component
		
		var actor : String = conversation.values()[interactions]
		speakerLabel.push_color(colorDict[actor])
		speakerLabel.append_text(actor + " :") # grab the speaker from conversation dict
		
		await get_tree().create_timer(advanceDelay).timeout # pause once done 
		
		for letter in conversation.keys()[interactions]: # iterate through each letter of the dialouge
			if talking:
				dialougeLabel.append_text(letter)
				await get_tree().create_timer(breath).timeout # timer for typeout effect 
			else:
				return # kill if talking is false 
				
		await get_tree().create_timer(advanceDelay).timeout # pause once done
		
		if conversation.size() - 1 > interactions: # if there are more dialouges
			interactions = interactions + 1 # increment interaction counter
			cleanUpLabels(speakerLabel, dialougeLabel)
			speak(currentTalk, interactions) # start next one 
		else:
			cleanUpLabels(speakerLabel, dialougeLabel)
			toggleDialouge() # otherwise turn it all off
	else:
		pass
		print('no words')

# func -- assignColors
# args -- conversation dictionary to assign name colors to
#
# Take a dictionary, assigns a unique color to each speaker 
func assignColors(conversation : Dictionary):
	for name in conversation.values():
		if !colorDict.has(name):
			if colorCount <= starterColors.size():
				colorDict[name] = starterColors[colorCount]
				colorCount += 1
			# TODO -- if exceeding current size of color array, make a new Color(randint(0,256),(0,256),(0,256)) something like that
			else:
				colorDict[name] = Color.WHITE_SMOKE # placeholder  
	#print(colorDict)

# func -- cleanUpLabels
# args -- speaker richtextlabel and body text richtextlabel
#
# Pops previous color off and clears dialouge for next line and speaker
func cleanUpLabels(speaker : RichTextLabel, body : RichTextLabel):
	speaker.pop() # pop current color off the stack for next assignment
	speaker.remove_paragraph(0) # clean speaker
	body.remove_paragraph(0) # clean body text
