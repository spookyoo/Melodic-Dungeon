extends Node

# Used to manage global states, like changing scenes, restarting game, and etc.

func change_scene(scene_path: String):
	get_tree().call_deferred("change_scene_to_file", scene_path)
