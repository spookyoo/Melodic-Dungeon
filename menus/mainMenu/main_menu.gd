extends Control

# Buttons
@export var playButton: Button
@export var optionsButton: Button
@export var creditsButton: Button
@export var exitButton: Button
@export var tweenIntensity: float = 1.2
@export var tweenDuration: float = 0.5

var buttons: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	buttons = [playButton, optionsButton, creditsButton, exitButton]
	
	for button in buttons:
		button.pivot_offset = button.size / 2

func _process(delta: float):
	for button in buttons:
		buttonHovered(button)

func startTween(object: Object, property: String, finalVal: Variant, duration: float):
	var tween = create_tween()
	tween.tween_property(object, property, finalVal, duration)

func buttonHovered(button: Button):
	if button.is_hovered():
		startTween(button, "scale", Vector2.ONE * tweenIntensity, tweenDuration)
	else:
		startTween(button, "scale", Vector2.ONE, tweenDuration)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://environment/gen_test.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menus/options/options.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://menus/credits/credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
	
