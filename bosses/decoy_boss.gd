extends Node3D

var isDecoy: bool = false
var decoyInstances: Array = []
var realBoss: Node3D = null # the real boss intance
var currentWave: int = 1
var maxwave: int = 3
var waveDecoyCount: int = 5 # starting number of decoys per wave
var bossHealth: int =  30     # 30 number of keystrokes
var decoyHealth: int = 10   # change this later to a random number of keystrokes
var particleEffect: Node3D = null # change this for flickering effect or other visuals later

func intializeForBoss1():
	print("Intializing Boss 1: Decoy Boss")
	bossHealth = 30
	currentWave = 1
	waveDecoycount = 5
	
	#particleEffect = $ParticleEffect
	#particleEffect.visible = false      <- can be toggled during boss phase
	
func startBossFight():
	while currentWave <= maxWaves:
		var decoys = spawnDecoysForWave(currentWave):
		await get_tree().create_timer(1.0).timeout
		spawnWave(currentWave)
		currentWave += 1
		await get_tree().create_timer(3.0).timeout   # wait before starting next wave
		
	# final phase wafter the wave ends
	startFinalPhase()

func spawnDecoysForWave(wave: int):
	var decoys = []
	for i in range(waveDecoyCount * wave): # increase decoys each wave
		var decoy = spawnBossInstance()          # spawn a new boss-like decoy XD
		decoy.isDecoy = true
		decoy.position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
		decoys.append(decoy)
	return decoys

# spawn single instance of the boss or decoy
func spawnBossInstance():
	var bossInstance = preload("")

func createDecoys(x, z):
	var decoys = []
	for i in range(5):
		var decoy = instantiate()
		decoy.position = Vector2
