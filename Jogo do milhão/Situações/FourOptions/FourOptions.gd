extends Node

func _ready():
	
	$FourOptions.set_question("Qual é a área do parque?")
	$FourOptions.add_alternative("73 mil m²", false) # Alternativa 0
	$FourOptions.add_alternative("24 mil m²", false) # Alternativa 1
	$FourOptions.add_alternative("72 mil m²", true) # Alternativa 2
	$FourOptions.add_alternative("180 mil m²", false) # Alternativa 3
	
	# Mistura as perguntas
	$FourOptions.disarray_alternatves()
	
	$Question.text = $FourOptions.get_question()
	$Option1.text = $FourOptions.get_alternative(0)
	$Option2.text = $FourOptions.get_alternative(1)
	$Option3.text = $FourOptions.get_alternative(2)
	$Option4.text = $FourOptions.get_alternative(3)

func _on_Option1_pressed():
	$FourOptions.select_answer(0)
	$Answer.text = str("Resposta correta?: ", $FourOptions.get_result())

func _on_Option2_pressed():
	$FourOptions.select_answer(1)
	$Answer.text = str("Resposta correta?: ", $FourOptions.get_result())

func _on_Option3_pressed():
	$FourOptions.select_answer(2)
	$Answer.text = str("Resposta correta?: ", $FourOptions.get_result())

func _on_Option4_pressed():
	$FourOptions.select_answer(3)
	$Answer.text = str("Resposta correta?: ", $FourOptions.get_result())
