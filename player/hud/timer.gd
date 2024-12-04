extends Panel

var time : float = 0.0
var hour : int = 0
var mins : int = 0
var secs : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	hour = fmod(time, 3600) / 24
	mins = fmod(time, 60) / 60
	secs = fmod(time, 60)
	
	$hour.text = "%02d:" % hour
	$min.text = "%02d:" % mins
	$sec.text = "%02d" % secs
