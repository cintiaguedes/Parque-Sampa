extends Button


func _on_Iniciar_mouse_entered():
	$Sprite.modulate.r = 0.866211
	$Sprite.modulate.g = 0.328981
	$Sprite.modulate.b = 1
	pass # Replace with function body.


func _on_Iniciar_mouse_exited():
	$Sprite.modulate.r = 0.148034
	$Sprite.modulate.g = 0.835294
	$Sprite.modulate.b = 1
	pass # Replace with function body.


func _on_Iniciar_pressed():
	$Sprite.modulate.r = 255
	get_tree().quit()
	pass # Replace with function body.


#Color(0.866211, 0.148034, 0.328981, 0.835294)
