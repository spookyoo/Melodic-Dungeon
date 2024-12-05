extends Node
class_name AttackQueue

var activeEnemy : Enemy = null
var queue: Array = []  # queue the enemies waiting to attack

func reqAttack(enemy: Enemy) -> bool:
	if enemy.isAttacking == false:
		enemy.startAttack()
		return true      # enemy can then attack immediately
	else:
		queue.append(enemy)
		return false
		
func finishAttack(enemy: Enemy):
	#if activeEnemy == enemy:
		## ensure its valdi before we continue
		#activeEnemy = null
		#queue = queue.filter(is_instance_valid)
		
	if queue.size() > 0:
		var nextEnemy = queue.pop_front() # next enemy shAould be active
		if is_instance_valid(activeEnemy):
			nextEnemy.startAttack()
