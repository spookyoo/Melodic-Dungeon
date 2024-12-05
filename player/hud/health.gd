extends Control

@onready var player = get_tree().get_current_scene().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.hpUpdate.connect(self.update)
	instantiate()
	pass

func instantiate():
	$hpBar.max_value = player.maxHealth
	$hpBar.value = $hpBar.max_value

func update(newHp):
	$hpBar.value = newHp
