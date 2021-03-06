extends QuizBase

class_name QuizMultipleChoice, "QuizMultipleChoice.png" 

enum Type {TRUE_OR_FALSE = 2, THREE_OPTIONS, FOUR_OPTIONS}
export (Type) var type = Type.TRUE_OR_FALSE setget , get_type 

# Pregunta str
var question := "" setget set_question, get_question
# Array de str de las alternativas
var alternatives := []
# Array que dice que respuesta es correcta o no
var is_correct_answer := []

# Número máximo de respuestas correctas (normalmente es una respuesta correcta).
# Pero pueden existir más de una respuesta correcta.
var max_num_correct_answer := 0
# Numero actual de respuestas correctas ¿Cuántas respuestas correctas tiene
# en este momento?
var current_num_correct_answer := 0
# Como resultado de la pregunta y las respuestas, ¿Es correcto?
var result = false setget , get_result

signal correct_answer
signal incorrect_answer

# Opcional
var points

func _ready():
	randomize()
	
	if self.debug:
		connect("correct_answer", self, "_on_correct_answer")
	
# Métodos Públicos
#

func select_answer(num_answer):
	if is_correct_answer[num_answer]:
		current_num_correct_answer += 1
	else:
		current_num_correct_answer -= 1
	
	# Ver si en este momento el resultado es correcto o no
	if max_num_correct_answer == current_num_correct_answer:
		result = true
	else:
		result = false
	
# Recibe un texto con la alternativa, y también si esta es correcta o no.
func add_alternative(alternative, is_correct):
	alternatives.append(alternative)
	is_correct_answer.append(is_correct)
	
	if is_correct:
		max_num_correct_answer += 1
	
	match alternatives.size():
		3:
			type = Type.THREE_OPTIONS
		4:
			type = Type.FOUR_OPTIONS
	
func disarray_alternatves():
	var old_order_alternatives = alternatives.duplicate()
	alternatives.shuffle()
	
	var old_order_is_correct_answer = is_correct_answer.duplicate()
	
	for i in range(0, alternatives.size()):
		var pos_old = alternatives.find(old_order_alternatives[i]) 
		is_correct_answer[pos_old] = old_order_is_correct_answer[i]

# Setters/Getters
#

func set_question(_question):
	question = _question
	
func get_question():
	return question

func get_type():
	return type
	
func get_alternative(index):
	return alternatives[index]

func get_result():
	return result

# Métodos "Privados"
#

# Eventos
#

func _on_correct_answer():
	debug("_on_correct_answer")
