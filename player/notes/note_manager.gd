extends Node3D

@export var note : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func correct(mark,enemy):
	var newNote = note.instantiate()
	newNote.origin = mark
	newNote.destination = enemy
	newNote.calculate()
	add_child(newNote)

func incorrect():
	print("INCORRECT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
