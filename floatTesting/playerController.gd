extends CharacterBody2D

#onready vars to be init at start 
@onready var worldSpace : Node2D = get_tree().current_scene.get_child(1) # second child is world, first is player 
@onready var floorMark : CollisionShape2D = $Area2D/floor
@onready var wallMark : RayCast2D = $wallCast
@onready var topCol : Node2D = $topColliders
@onready var botCol : Node2D = $botColliders

# TODO -- make this an array like the one looking up
@onready var bottomCol : RayCast2D = $floorCheck

#DEBUG
@onready var coordText : RichTextLabel = $RichTextLabel

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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#jump call, # TODO move this to a handler soon
	if Input.is_action_pressed("ui_up"):
		jump(jumpTarget, delta)
	#hot reload for debung 
	if Input.is_action_just_pressed("ui_down"):
		get_tree().reload_current_scene()
		
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
	
	if wallMark.is_colliding() and wallMark.get_collider().is_in_group("walls"):
		return 
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
# TODO -- SETUP THE DOWN-FACING ARRAY IN HERE TOO 
#
# Looks through all children of root node for upward raycasts. 
# Adds all to raycast array, enables, and sets target position
func initializeColArray():
	# bottom colliders
	for i in range(botCol.get_child_count()):
		var currentBotRay : RayCast2D = botCol.get_child(i) # init bottom array too 
		botColArray.append(currentBotRay) # add bottom ray to array
		currentBotRay.enabled = true # and the bottom one 
		currentBotRay.target_position.y = position.y + 14 
		
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
			
func checkDownCol():
	for i in range(botColArray.size()):
		var botCheckRay : RayCast2D = botColArray[i]
		if botCheckRay.is_colliding() and botCheckRay.get_collider().is_in_group("walls"):
			var distance = floor(position.y - botCheckRay.get_collision_point().y)
			if distance < 0:
				grounded = true
				lerp(worldSpace.position.y, worldSpace.position.y + distance, 0.1)
				distance = floor(position.y - botCheckRay.get_collision_point().y)
				print(distance)
		else:
			grounded = false
		

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
