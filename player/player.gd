extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var notes = $NoteManager
@onready var mark = $Head/Camera3D/Weapon
@onready var area = $Area3D
@onready var audioManager = $AudioManager
var lastCollided : Enemy = null
var maxHealth = 100
var playerHealth = 100
var score = 0
var currentKeyIdx = 0

signal hpUpdate
signal comboUpdate
signal scoreUpdate

var walk_speed = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.001
# Bob variables
const BOB_FREQ = 2.0
const BOB_AMP= 0.08
# FOV Variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
# Combo Variables
var currentWeapon = ""
var comboStreak = 0
var perfectComboActivated = false
var comboFirstEnemyContact = false
# Infusion
var infusionSpeedBoost = 4
var healingAmount = 18
var invicible = false
# Music
var currentNoteIdx = 0
var ascending = true
var correctSounds = []


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalPlayer.player = self
	GlobalPlayer.update.connect(self.applyInstrument)
	GlobalPlayer.instantiate()

func _input(event):
	if event.is_action_pressed("ui_cancel") || event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handleCamera(event)

func _physics_process(delta: float) -> void:
	handleJumping(delta)
	applyMovement(delta)
	applyCamEffects(delta)
	move_and_slide()
	performRaycast()
	checkCollision()
	handleInput()

func handleCamera(event):
	"""
	Handles camera rotation based on mouse movement
	
	Rotates player's head horizontally and the camera vertically based on the mouse's relative movement
	
	Args:
		event (InputEventMouseMotion): Event containing mouse motion data
	"""
	if event is InputEventMouse:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -40, 60)

func handleJumping(delta):
	"""
	Applies gravity and handles jump input
	
	If player is grounded and presses jump they will jump, otherwise gravity is applied to pull down
	
	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func applyMovement(delta):
	"""
	Calculate and apply player movement based on input and sprinting

	Determines direction based on input (WASD keys), then adjusts velocity for walking/sprinting
	Also interpolates movement when player is airborne

	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	var speed = walk_speed
	
	#if Input.is_action_pressed("sprint"):
		#speed = SPRINT_SPEED

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	playWalkingSFX(input_dir)
	
	if is_on_floor():
		velocity.x = direction.x * speed if direction else 0.0
		velocity.z = direction.z * speed if direction else 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

func playWalkingSFX(input_dir: Vector2):
	if is_on_floor():
		if input_dir:
			if !audioManager.get_node("WalkingSound").playing:
				audioManager.get_node("WalkingSound").play()
		if !input_dir:
			audioManager.get_node("WalkingSound").stop()

func applyCamEffects(delta):
	"""
	Applies cam effects such as head bobbing and field of view (FOV)
	
	Function calculates and applies head bobbing effect based on movement speed then adjusts FOV dynamically depending on player velocity
	
	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	# Head Bob
	var t_bob = 0.0
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = calcHeadbob(t_bob)
	
	# FOV:
	var velocityClamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var targetFOV = BASE_FOV + FOV_CHANGE * velocityClamped
	camera.fov = lerp(camera.fov, targetFOV, delta * 8.0)

func calcHeadbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func performRaycast():
	if lastCollided:
		var lastLabel = lastCollided.get_node("Label")
		lastLabel.visible = false
		lastCollided = null
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider is Enemy and not collider.isFreed:
			var enemyLabel = collider.get_node("Label")
			enemyLabel.visible = true
			lastCollided = collider

func checkCollision():
	if invicible:
		return
	for body in area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			takeDamage(body.damage)

func handleInput():
	"""
	What will happen when we look at the LABEL (STACK VARIATION)
	"""
	if lastCollided && lastCollided.keyQueue.size() > 0 && (not lastCollided.has_method("isRandomizing") or not lastCollided.isRandomizing):
		#print("current key stackqueue: ", lastCollided.keyQueue)
		var expectedKey = lastCollided.keyQueue.front()     # GET THE LAST KEY FROM THE STACK
		
		if Input.is_action_just_pressed(expectedKey):
			#print("CORRECT KEY PRESSED: ", expectedKey)
			lastCollided.keyQueue.pop_front() # remove first key from queue
			playCorrect()
			updateKeyLabel()
			notes.correct(mark,lastCollided)
			
			comboStreak += 1
			#print("Combo Streak:", comboStreak)
			comboUpdate.emit(comboStreak)
			
			var currentWeaponData = GlobalInstruments.instruments[GlobalPlayer.instrument]
			if comboStreak >= currentWeaponData["comboThreshold"] && not perfectComboActivated:
				activatePerfectCombo()
			
			# call takedamage on the boss
			if lastCollided is Boss:
				lastCollided.damageBoss()
			
			# check if queue is empty (handles killing enemies)
			if lastCollided.keyQueue.size() == 0:
				lastCollided.die()
				score += 100
				scoreUpdate.emit(score)
				lastCollided = null
		else:
			for key in lastCollided.keys.split(" "):
				if Input.is_action_just_pressed(key):
					resetCombo()
					#print("Wrong key pressed: ", key)
					playIncorrect()
					takeDamage(10)
					print(playerHealth)
					notes.incorrect()
					break
					
func updateKeyLabel():
	lastCollided.label.text = " ".join(lastCollided.keyQueue)
	#label.text = " ".join(keyQueue)
	#var completedKeys = lastCollided.keyQueue.slice(0, currentKeyIdx)
	#var remainingKeys = lastCollided.keyQueue.slice(currentKeyIdx, lastCollided.keyQueue.size())

func takeDamage(amount: int):
	playerHealth -= amount
	hpUpdate.emit(playerHealth)
	if playerHealth <= 0:
		die()
	else:
		invicible = true
		$Invicibility.start()
	
func die():
	velocity = Vector3.ZERO
	set_process(false)
	
func activatePerfectCombo():
	perfectComboActivated = true
	
	# activate the current weapon's active ability
	var currentWeaponData = GlobalInstruments.instruments[GlobalPlayer.instrument]
	if currentWeaponData && currentWeaponData["active"]:
		#currentWeaponData["infusion"].call()
		score += 500
		activateInfusion()
		
		print("perfect combo activated with", currentWeaponData)
	resetCombo()

func resetCombo():
	print("RESETTED")
	comboStreak = 0
	comboFirstEnemyContact = false
	perfectComboActivated = false

func applyInstrument():
	match GlobalPlayer.instrument:
		"lute":
			%Sprite3D.texture = load(GlobalInstruments.instruments["lute"]["icon"]) as Texture
			%Instrument.transform.origin = Vector3(0.26,-0.018,-0.359)
			raycast.target_position -= Vector3(0, GlobalInstruments.instruments["lute"]["passive"], 0)
			correctSounds = GlobalInstruments.instrumentSounds["lute"]
		"drum":
			%Sprite3D.texture = load(GlobalInstruments.instruments["drum"]["icon"]) as Texture
			%Instrument.transform.origin = Vector3(0.26,-0.176,-0.359)
			walk_speed += GlobalInstruments.instruments["drum"]["passive"]
			correctSounds = GlobalInstruments.instrumentSounds["drum"]
		"recorder":
			%Sprite3D.texture = load(GlobalInstruments.instruments["recorder"]["icon"]) as Texture
			%Instrument.transform.origin = Vector3(0.26,-0.018,-0.359)
			maxHealth += GlobalInstruments.instruments["recorder"]["passive"]
			correctSounds = GlobalInstruments.instrumentSounds["recorder"]
		_:
			%Sprite3D.texture = null
			correctSounds = []
	audioManager.get_node("Incorrect").stream = load(correctSounds[-1])

func playCorrect():
	audioManager.get_node("Correct").stream = load(correctSounds[currentNoteIdx])
	audioManager.get_node("Correct").play()
	await get_tree().create_timer(1.0).timeout
	audioManager.get_node("Correct").stop
	
	if ascending:
		currentNoteIdx += 1
		if currentNoteIdx >= 8:
			ascending = false
			currentNoteIdx = 7
	else:
		currentNoteIdx -= 1
		if currentNoteIdx < 0:
			ascending = true
			currentNoteIdx = 1

func playIncorrect():
	audioManager.get_node("Incorrect").play()
	await get_tree().create_timer(1.0).timeout
	audioManager.get_node("Incorrect").stop

func playInfusion():
	audioManager.get_node("Infusion").stream = load(correctSounds[currentNoteIdx])
	audioManager.get_node("Infusion").pitch_scale = 1.5
	audioManager.get_node("Infusion").play()
	await get_tree().create_timer(1.0).timeout
	audioManager.get_node("Infusion").stop()
	audioManager.get_node("Infusion").pitch_scale = 1.0
	
	if ascending:
		currentNoteIdx += 1
		if currentNoteIdx >= 8:
			ascending = false
			currentNoteIdx = 7
	else:
		currentNoteIdx -= 1
		if currentNoteIdx < 0:
			ascending = true
			currentNoteIdx = 1

func activateInfusion():
	match GlobalPlayer.instrument:
		"lute":
			if lastCollided and lastCollided.keyQueue.size() > 0:
				lastCollided.keyQueue.pop_front()
				updateKeyLabel()
		"drum":
			walk_speed += infusionSpeedBoost
			$SpeedBoost.start()
			print("Infusion started. Speedboosted by", infusionSpeedBoost)
				
		"recorder":
			playerHealth = min(playerHealth + healingAmount, maxHealth)
			hpUpdate.emit(playerHealth)
			# could have a healing effect animation
		_:
			pass
	playInfusion()

func _on_speed_boost_timeout() -> void:
	walk_speed -= infusionSpeedBoost
	print("Infusion Ended, Speed Reverted")

func _on_invicibility_timeout() -> void:
	invicible = false
	print("Invincibility Over!")
