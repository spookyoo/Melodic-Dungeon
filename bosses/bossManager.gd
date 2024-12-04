extends Node

var maxDamage: int = 30
var bossRoom: bool = false

var bossScenes = [
	preload("res://bosses/DecoyBoss.tscn"),
	preload("res://bosses/RandomizerBoss.tscn")
	## add more bosses when needed
]



func spawnAndFightBoss(x, z):
	var boss = spawnBoss(x, z)
	var decoys = spawnDecoys(x, z)
	
	# if boss is the one start has decoys create and spawn them
	if boss.has_method("create_decoys"):
		decoys = spawnDecoys
	
	
	# handle the boss phases up to a certain amount of keystrokes
	await startBossFight(boss, decoys)
	
	return
	
func spawnBoss(x, z):
	var boss = # instantiate based on x, z
	return
	
func spawnDecoys(x, z):
	var decoys = []
	for i in range(5):
		var decoy = spawnBoss(x, z)
		decoy.isDecoy = true
		decoys.append(decoy)
	return decoys

func startBossFight(boss, decoys):
	var damageTaken = 0
	var waveCount = 0
	while damageTaken < maxDamage:
		var decoyToDestroy = getNextDecoyToDestroy(decoys, wavecount)
		await handleWave(boss, decoyToDestroy, waveCount)
		waveCount += 1
		
	await handleFinalPhase(boss)
	return
		
	
