extends Node2D

@export var title = "FPP V0.0" 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	DisplayServer.window_set_title(title + " | fps: " + str(1/delta)) # fps and title in window title 
