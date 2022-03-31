extends RigidBody2D

func _on_Dismantle_timeout():
	$animplayer.play("destroy")

func _on_Bullet1_body_entered(body):
	if body.has_method("hit_by_enemy"):
		body.call("hit_by_enemy")
	$animplayer.play("destroy")
