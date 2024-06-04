extends Node2D

#onready vars to be init at start 
@onready var worldSpace : Node2D = get_tree().current_scene.get_child(1) # second child is world, first is player 

#collision casts and cast arrays 
@onready var floorMark : CollisionShape2D = $Area2D/floor
@onready var wallMark : RayCast2D = $CharacterBody2D/wallCast
@onready var topCol : Node2D = $CharacterBody2D/topColliders
@onready var botCol : Node2D = $CharacterBody2D/botColliders

#sprites
@onready var sprite : AnimatedSprite2D = $CharacterBody2D/playerBody
@onready var interactionLabel : Sprite2D = $InteractionMarker

# dialouge
@onready var dialougeController : CanvasLayer = $CharacterBody2D/UiController 

#DEBUG
@onready var coordText : RichTextLabel = $CharacterBody2D/RichTextLabel

#basic traversal vars, for walking and grounding 
var dir : int = 0
var grounded : bool = false
var theGround : float = 0
var jumpReady : bool  = false

#constants 
const SPEED : float = 100.0
const GRAVITY : float = 170.0
const JUMPHEIGHT : float = 60.0 # base height
const JUMPSPEED : float = 500.0 # mult

#for upward collisions, jumpheight target, coyote time for crispy 
var topColArray : Array = []
var botColArray : Array = []

var activeCollisions : int = 0

var jumpTarget : float = JUMPHEIGHT
var coyoteTime : float = 0.1
@onready var baseCoyoteTime : float = coyoteTime

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(worldSpace) #ensure link to worldspace
	assert(wallMark) #ensure link to wall check
	assert(topCol)
	assert(botCol)
	
	if topCol:
		initializeColArray()

	#ensure raycasts are enabled 
	wallMark.enabled = true
	interactionLabel.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#jump call, # TODO move this to a handler soon
	if Input.is_action_pressed("ui_up"):
		jump(jumpTarget, delta)
	#hot reload for debung 
	if Input.is_action_just_pressed("ui_down"):
		get_tree().reload_current_scene()
	
	if !dialougeController.talking: # set interaction marker invisible if we arent enganged in a conversation
		interactionLabel.visible = false
		
func _physics_process(delta):
	move(delta) # movement handler 
	checkUpCol() # check for collisions above
	checkDownCol() #check for the floor 
	handleGravity(delta) # gravity handler 

# func -- handleGravity
# args -- delta from physics proccess
#
# uses grounded stauts to dictate coyote time reset and world movement. 
# world moves with inverse gravity for player falling 
func handleGravity(delta):
	#apply gravity 
	if !grounded:
		coyoteTime -= 0.5 * delta if coyoteTime > 0 else 0 # reduce coyote time if in air 
		worldSpace.position.y -= GRAVITY * delta # inv grav
	else:
		coyoteTime = baseCoyoteTime 
		jumpReady = true # reset jump flag (variable trigger)

# func -- move
# args -- delta from physics proccess 
#
# gets direction from horizontal axis
# moves the world inverse to the player in that direction	
func move(delta):
	coordText.text = str(position)
	# grab movement direction 
	dir = Input.get_axis("ui_left", "ui_right")
	
	if dir != 0: #dont update if zero
		wallMark.target_position.x = 16 * dir # update raycast direction
		sprite.scale.x = dir
		
	if wallMark.is_colliding():
		if wallMark.get_collider != null:
			if wallMark.get_collider().is_in_group("walls"):
				return 
		else:
			pass
	else:
		# move the world 
		worldSpace.position.x += -dir * SPEED * delta 

# func -- jump
# args -- jump position, delta from physics proccess 
#
# Moves the world inverse of the player, accounts for coyote time
# While loop for variable height 
func jump(jumpPos, delta):
	if coyoteTime > 0: # check for remaining coyote time 
		while worldSpace.position.y < worldSpace.position.y + jumpPos: # if we have space to jump
			worldSpace.position.y += JUMPSPEED * delta # offset the world and use delta because duh
			break # yes 
	else:
		return

# func -- initializeColArray
# args -- none 
#
# Looks through all children of root node for upward raycasts. 
# Adds all to raycast array, enables, and sets target position
func initializeColArray():
	# bottom colliders
	for i in range(botCol.get_child_count()):
		var currentBotRay : RayCast2D = botCol.get_child(i) # init bottom array too 
		botColArray.append(currentBotRay) # add bottom ray to array
		currentBotRay.enabled = true # and the bottom one 
		currentBotRay.target_position.y = 10
		
	# top colliders 
	for i in range(topCol.get_child_count()): # go through the raycasts that look up at the night sky 
		var currentRay : RayCast2D = topCol.get_child(i) # easy name for current one this is dumb and inefficient 
		topColArray.append(currentRay) # add it to the array of raycasts
		currentRay.enabled = true # enable it
		currentRay.target_position.y = -JUMPHEIGHT * 3 # set the target position to be arbitrarily big because i decided so?

# func -- checkUpCol
# args -- none
#
# Checks all upward facing rays for collisions
# corrects jump height based on upward contact 
func checkUpCol():
	for i in range(topColArray.size()):
		var checkRay : RayCast2D = topColArray[i]
		if checkRay.is_colliding() and checkRay.get_collider().is_in_group("walls"): # check for raycast collision
			var distance = floor(position.y - checkRay.get_collision_point().y) # get the distance 
			if distance <= floor(JUMPHEIGHT * JUMPSPEED): # if the distance is the same as or less than jumpheight
				jumpTarget = distance - 16 # jump to distance with - 16 as a buffer 
			else: #in either of these other cases use standard jump height 
				jumpTarget = floor(JUMPHEIGHT * JUMPSPEED)
		else:
			pass

# func -- checkDownCol
# args -- none 
#
# Takes the initialized downfacing raycast array and looks for and handles collision
# with the floor
func checkDownCol():
	for i in range(botColArray.size()): # go through the cast array 
		var botCheckRay : RayCast2D = botColArray[i] # local reference to current check 
		if botCheckRay.is_colliding(): # collision
			var collider = botCheckRay.get_collider()
			if collider != null:
				if collider.is_in_group("walls"): # with the walls + floor
					var distance = floor(position.y - botCheckRay.get_collision_point().y) # calculate distance to point
					
					if distance < 0: # more than 0?
						grounded = true # we are grounded 
						lerp(worldSpace.position.y, worldSpace.position.y + distance, 0.1) # quickly adjust worldspace by distance 
						distance = floor(position.y - botCheckRay.get_collision_point().y) # reset distance 
						
					if activeCollisions < botColArray.size(): # increment collision counter 
						activeCollisions += 1
						break # move to next ray
						
				elif botCheckRay.is_colliding() and collider.is_in_group("enemy"):
					worldSpace.position.y += JUMPHEIGHT
					var target = collider.get_parent().get_parent()
					target.queue_free()
					dialougeController.score += 1 #TODO -- hook this up to a score manager
					dialougeController.speak({"*poof*" : "enemy"}, 0) #TODO -- hook this up to a manager too (placeholder though)
					
		else: # not colliding 
			if activeCollisions > 0:
				activeCollisions -= 1 # remove collision status 
				break # move to next ray
				
		if activeCollisions == 0: # no active collisions?
			grounded = false # not on the ground! 

# func -- groundCollision
# args -- area (target area 2d)
#
# Toggles grounded status on based on signal from attatched area2d
func groundCollision(area): # signal from feet
	if area.is_in_group("walls"): # on ground *WOAH*
		grounded = true 

# func -- groundCollision
# args -- area (target area 2d)
#
# Toggles grounded status off based on signal from attatched area2d
func cancelCollision(area): # feet leaving signal 
	if area.is_in_group("walls"): # NOT ON THE GROUND WAH
		grounded = false 


func updateConversation(conversation : Dictionary):
	interactionLabel.visible = true
	dialougeController.currentTalk = conversation
