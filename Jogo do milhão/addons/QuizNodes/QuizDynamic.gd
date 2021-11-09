extends QuizBase

class_name QuizDynamic, "QuizDynamic.png"

#um questionário dinâmico que pode ser lido de um arquivo, json
# ou mesmo criptografado. Para isso, é preciso um plugin PersistenceNode
# que está incluído.

# Esta constante armazena o nome do arquivo de teste
const QUESTION_TEST = "QuestionTest"

#Acesso ao node para  armazenar e carregar os dados
onready var persistence = Persistence.new()

# Dicionário com dados atuais
var current_data
# Perguntas
var questions := []
# Numero da pergunta atual, começa com 0
var current_question := 0

signal get_question(question_num)
signal correct_answer
signal incorrect_answer


# Ficheiro de onde as perguntas e respostas são lidas
func read_from(file_name, category, sub_category, random := true):
	if not category:
		.debug("Invalid category")
		return
		
	if not sub_category:
		.debug("Invalid sub_category")
		return
	
	for question in current_data[file_name][category][sub_category].keys():
		questions.append(current_data[file_name][category][sub_category][question])
	
	if random:
		randomize()
		questions.shuffle()


# Segue para a pergunta atual ou segue um parametro (ainda para implementar)
func get_question(num = null):
	if num:
		emit_signal("get_question", num)
		return questions[num]["Question"]
		
	emit_signal("get_question", current_question)
	return questions[current_question]["Question"]


# Ordem para a proxima pergunta
func next_question():
	if current_question + 1 < questions.size():
		current_question += 1


# Confere a quantidade de respostas sob a variavel answer_num
func get_answer(answer_num):
	return questions[current_question]["OpcoesdeRespostas"][answer_num]


# Se a resposta answer_num esta correta ou não
func is_correct(answer_num):
	if questions[current_question]["CorrectAnswers"].has(answer_num):
		emit_signal("correct_answer")
		return true
		
	emit_signal("incorrect_answer")
	return false


# Mostra a quantidade de respostas disponíveis para a pergunta
func get_answer_amount():
	return questions[current_question]["OpcoesdeRespostas"].size()


# Mostra quantas perguntas são
func get_question_amount():
	return questions.size()


# Pergunta se é a ultima pergunta ou não (importante para finalizar)
func is_last_question():
	return questions.size() == current_question + 1


# Para criar uma estrutura JSON com as perguntas
func create_test():
	persistence.set_folder_name("Questions")
	
	if self.debug:
		persistence.mode = Persistence.Mode.TEXT
	else:
		persistence.mode = Persistence.Mode.ENCRYPTED
	
	current_data = persistence.get_data(QUESTION_TEST)
	var script = load("res://Jogo do milhão/addons/QuizNodes/Dicionario.gd").new()
	current_data[QUESTION_TEST] = script.example_dict
	persistence.save_data(QUESTION_TEST)
