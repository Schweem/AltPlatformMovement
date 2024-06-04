extends Camera2D

@onready var target : Node2D = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	print(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
