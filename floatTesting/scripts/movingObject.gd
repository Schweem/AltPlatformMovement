extends Node2D

@onready var dirRay : RayCast2D = $CharacterBody2D/wallCast
@onready var groundCheck : Area2D = $CharacterBody2D/feet

const MOVESPEED : float = 50.0
const GRAV : float = 140.0

var facing : int = 1
var canFlip : bool = true 
var grounded : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	dirRay.target_position.x = 16 * facing 

func _physics_process(delta):
	handleDir(delta)
	move(delta)
	handleGravity(delta)

# func -- handleDir 
# args -- delta from physics proccess
#
# Used to flip the moving body on wall collisions  
func handleDir(delta):
	if dirRay != null:
		if dirRay.is_colliding():
			if dirRay.get_collider() != null:
				if dirRay.get_collider().is_in_group("walls") and canFlip:
					facing = -facing
					dirRay.target_position = -dirRay.target_position
					canFlip = false
				else:
					pass
		else:
			pass

# func -- move 
# args -- delta from physics proccess 
#
# Used to move the body across the world space 
func move(delta):
	position.x += MOVESPEED * facing * delta
	if !dirRay == null:
		if !dirRay.is_colliding():
			canFlip = true

# func -- handleGravity
# args -- delta from physics proccess
#
# Pulls the body down to earth or wherever they are 
func handleGravity(delta):
	if !grounded:
		position.y += GRAV * delta
	
func onGround(area):
	if area.is_in_group("walls"):
		grounded = true 

func offGround(area):
	#print('fuck colliders')
	if area.is_in_group("walls"):
		grounded = false 


func onSolidGround(body):
	if body.is_in_group("walls"):
		grounded = true 


func offSolidGround(body):
	#print('fuck tilesets')
	if body.is_in_group("walls"):
		grounded = false 
