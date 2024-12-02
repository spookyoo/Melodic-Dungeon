extends Node2D

# Timing Circle
@export var perfectWindow: float = 0.2
@export var goodWindow: float = 0.4
@export var maxRadius: float = 200.0
@export var circleColor: Color = Color(1, 1, 1, 0.5)

var isActive: bool = false
var startTime: float = 0.0
var currentTime: float = 0.0
var timingDuration: float = 1.0 #total duration for the timing window

enum HitResult {
	MISS,
	GOOD,
	PERFECT
}

func _ready():
	visible = false
	
func startTimingCircle(duration: float):
	"""
	Starts the timing circle when given a specific duration
	
	Args:
		duration (float) : How long the player has to hit the target key
	"""
	timingDuration = duration
	startTime = Time.get_time_dict_from_system().second + Time.get_time_dict_from_system().microsecond / 1000000.0
	isActive = true
	visible = true
	
func _process(delta):
	if not isActive:
		return
		
	currentTime = Time.get_time_dict_from_system().second + Time.get_time_dict_from_system().microsecond / 1000000.0
	var elapsedTime = currentTime - startTime
	
	# Has timing window expired?
	if elapsedTime > timingDuration:
		stopTimingCircle(HitResult.MISS)
		
	queue_redraw()
	
func _draw():
	if not isActive:
		return
		
	var currentTimeProgress = (Time.get_time_dict_from_system().second + Time.get_time_dict_from_system().microsecond / 1000000.0 - startTime) / timingDuration
	var currentRadius = maxRadius * (1 - currentTimeProgress)
	
	# Draw the outer circle
	draw_arc(Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2), 
			 currentRadius, 
			 0, 
			 2 * PI, 
			 50, 
			 circleColor, 
			 2.0)
			
func stopTimingCircle(result: HitResult):
	"""
	Stops the timing circle and returns the hit result
	
	Args:
		result (HitResult): The result of the player's timing
	"""
	isActive = false
	visible = false
	
	match result:
		HitResult.PERFECT:
			print("Perfect hit!")
			return 1.5
		HitResult.GOOD:
			print("Perfect hit!")
			return 1
		HitResult.MISS:
			print("Perfect hit!")
			return 0.5
			
func checkTiming() -> HitResult:
	"""
	Checks the timing of the player's given input
	Returns:
		HitResult: Accuracy of the player's timing
	"""
	var elapsedTime = currentTime - startTime
	var normalizedTime = elapsedTime / timingDuration
	
	if normalizedTime <= perfectWindow:
		return HitResult.PERFECT
	elif normalizedTime <= goodWindow:
		return HitResult.GOOD
	else:
		return HitResult.MISS
