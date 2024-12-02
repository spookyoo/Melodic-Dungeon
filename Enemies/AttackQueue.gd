extends Node
class_name AttackQueue

var activeEnemy : Enemy = null
var queue: Array = []  # queue the enemies waiting to attack

func reqAttack(enemy: Enemy) -> bool:
	if activeEnemy == null:
		activeEnemy = enemy
		return true      # enemy can then attack immediately
	else:
		queue.append(enemy)
		return false
		
func finishAttack(enemy: Enemy):
	if activeEnemy == enemy:
		if queue.size() > 0:
			activeEnemy = queue.pop_front() # next enemy shAould be active
			activeEnemy.startAttack()
		else:
			activeEnemy = null
			
		
