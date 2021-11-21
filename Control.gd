extends Control


func _on_Button_mouse_entered() -> void:
	$Panel/AnimationPlayer.play("New Anim")


func _on_Button2_mouse_exited() -> void:
	$Panel/AnimationPlayer.play_backwards("New Anim")
	
