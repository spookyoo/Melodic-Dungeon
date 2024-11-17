extends Node3D

var origin = null
var destination = null

var lifetime = 0.8
var velocity = Vector3.ZERO
var time = 0.0
var sinHeight = 0.0
var randomHeight = 0.0
var randomNote

@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.w
func _ready():
	self.global_transform.origin = origin.global_transform.origin
	
	sinHeight = randf_range(0.1,0.5)
	randomHeight = randf() * 2 * PI
	
	chooseSprite()
	lifeExpire(lifetime)

func calculate():
	self.position = origin.position
	velocity = (destination.global_transform.origin - origin.global_transform.origin)
	velocity.y = 0
	velocity = velocity.normalized() * 1

func chooseSprite():
	randomNote = randi_range(1,3)
	match randomNote:
		1:
			sprite.texture = load("res://player/notes/assets/crochet.png")
		2:
			sprite.texture = load("res://player/notes/assets/beam.png")
		3:
			sprite.texture = load("res://player/notes/assets/quaver.png")
			
func lifeExpire(life):
	await get_tree().create_timer(life).timeout
	self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform.origin += velocity * delta
	
	time += delta
	global_transform.origin.y += sin(time * 3 * PI + randomHeight) * sinHeight * delta
