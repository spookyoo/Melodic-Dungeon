extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://environment/gen_test.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menus/options/options.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://menus/credits/credits.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
