#Plugin como base JSON

# Plugin desenvolvido por Matías Muñoz Espinoza disponível em https://github.innominds.com/MatiasVME/Persistence#readme
# Com Copyright (c) 2018-2020
# A permissão é concedida gratuitamente a qualquer pessoa que obtenha uma cópia
# deste software e arquivos de documentação associados (o "Software"), para lidar
# no Software sem restrição, incluindo, sem limitação, os direitos
# para usar, copiar, modificar, mesclar, publicar, distribuir, sublicenciar e / ou vender
# cópias do Software, e para permitir as pessoas a quem o Software é
# fornecido para fazê-lo, sujeito às seguintes condições:
#
# O aviso de direitos autorais acima e este aviso de permissão devem ser incluídos em todos
# cópias ou partes substanciais do Software.
#
# O SOFTWARE É FORNECIDO "COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU
# IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO ÀS GARANTIAS DE COMERCIALIZAÇÃO,
# ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA E NÃO VIOLAÇÃO. EM NENHUMA HIPÓTESE O
# AUTORES OU TITULARES DOS DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUALQUER RECLAMAÇÃO, DANOS OU OUTROS
# RESPONSABILIDADE, SEJA EM AÇÃO DE CONTRATO, DELITO OU DE OUTRA FORMA, DECORRENTE DE,
# FORA DE OU EM CONEXÃO COM O SOFTWARE OU O USO OU OUTRAS NEGOCIAÇÕES NO
# PROGRAMAS.

extends Node

class_name Persistence, "icon.png"

enum Mode {ENCRYPTED, TEXT}
export (Mode) var mode : int = Mode.ENCRYPTED setget set_mode, get_mode
export (String) var password := "" setget set_password, get_password
export (String) var folder_name := "PersistenceNode" setget set_folder_name, get_folder_name
export (Array) var no_valid_names := ["default", "example"] setget _private_set, get_no_valid_names
export (bool) var debug_on := false setget set_debug, get_debug

var beautifier setget _private_set, _private_get
export (bool) var beautifier_active := true setget set_beautifier_active, get_beautifier_active

export (int) var profile_name_min_size := 3 setget set_profile_name_min_size, get_profile_name_min_size
export (int) var profile_name_max_size := 15 setget set_profile_name_max_size, get_profile_name_max_size

# Dados do perfil atual que poderia ser salvo usando o comando save_data() - porem não foi explicado e não busquei na documentação
var data := {} setget _private_set

signal saved
signal loaded

func _init() -> void:
	if beautifier_active:
		beautifier = JSONBeautifier.new()

func _ready() -> void:
	connect("saved", self, "_on_saved")
	connect("loaded", self, "_on_loaded")

func _on_saved() -> void:
	# Mostra os dados na tela depois de salvo
	if beautifier_active and mode == Mode.TEXT:
		debug("_on_saved()")
		print_json(to_json(data))

func _on_loaded() -> void:
	#  Mostra os dados na tela depois de salvo.
	if beautifier_active and mode == Mode.TEXT:
		debug("_on_loaded()")
		print_json(to_json(data))

func _private_set(val = null) -> void:
	debug("Set access is private")

func _private_get() -> void:
	debug("Get access is private")



func debug(message, something1 = "", something2 = "") -> void:
	if debug_on:
		print("[PersistenceNode] ", message, " ", something1, " ", something2)

 # Tentativa COM BUGS de salvar usando uma string + comandos booleanos 
func save_data(profile_name : String = "") -> bool:
	var result
	
	# Cria uma pasta se não houver 
	create_main_folder()
	
	# Cria um perfil genérico inicial por padrão
	if profile_name == "":
		if save_profile_default():
			emit_signal("saved")
			debug("save_profile_default() retorna true")
			return true
		else:
			debug("save_profile_default() retorna falso")
			return false
	
	if validate_profile(profile_name):
		match mode:
			Mode.ENCRYPTED:
				result = save_profile_encripted(profile_name)
			Mode.TEXT:
				result = save_profile_text(profile_name)
	else:
		debug("Não foi possível validar seus dados")
		result = false
	
	if result:
		emit_signal("Salvo")
	
	return result

# Excluir perfil usando set_mode().
func remove_profile(profile_name : String) -> bool:
	var dir = Directory.new()
	var path
	
	match mode:
		Mode.ENCRYPTED:
			path = str("user://", folder_name, "/", profile_name, ".save")
		Mode.TEXT:
			path = str("user://", folder_name, "/", profile_name, ".txt")
	
	var err = dir.remove(path)
	
	if err != OK:
		debug("Erro ao remover o perfil: ", err)
		return false
	else:
		data = {}
	
	return true

# Exclui todos os dados dentro da pasta "folder_name" sem necessidade de checagem
# de criptografia.

func remove_all_data() -> bool:
	var dir = Directory.new()
	var profiles = get_profiles(true)
	
	if profiles != null:
		var path = "user://" + folder_name + "/"
		var err
		
		for i in range(profiles.size()):
			err = dir.remove(str(path + profiles[i]))
			
			if err != OK:
				debug("Ocorreu um erro ao remover o aquivo: ", err)
				return false
		
		data = {}
		
		return true
	else:
		debug("Sem arquivos para excluir.")
		return false

# Setters/Getters
#

# Mode.TEXT : Salva os dados em formato json
# Mode.ENCRYPTED : Guarda os dados de forma encriptado
func set_mode(_mode) -> void:
	mode = _mode

func get_mode() -> int:
	return mode

# Se houver dados salvos, eles devem estar disponíveis para serem altarados com save_data()
# Usando perfis, a informaçao pode ser buscada usando o nome deles né, mais fácil
func get_data(profile_name : String = "") -> Dictionary:
	data = {}
	load_data(profile_name)
	return data

# Exibe os perfis existentes. 
# PROCURAR COMO COLOCAR A EXTENSÃO QUANDO EXIBIR 
func get_profiles(with_extension : bool = false) -> Array:
	var dir = Directory.new()
	var profiles = []
	
	if dir.open("user://" + folder_name) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while (file_name != ""):
			if file_name != "." and file_name != "..":
				if not with_extension:
					profiles.append(file_name.get_basename())
				else:
					profiles.append(file_name)
		
			file_name = dir.get_next()
	else:
		debug("Ocorreu um erro ao acesso o path.")
	
	return profiles

# Exibe nomes inválidos
func get_no_valid_names() -> Array:
	return no_valid_names

func set_password(_password : String) -> void:
	password = _password
	
func get_password() -> String:
	return password

func set_folder_name(_folder_name : String) -> void:
	folder_name = _folder_name
	
func get_folder_name() -> String:
	return folder_name

func set_debug(_debug : bool) -> void:
	debug_on = _debug
	
func get_debug() -> bool:
	return debug_on

func set_beautifier_active(_beautifier_active : bool) -> void:
	beautifier_active = _beautifier_active
	
func get_beautifier_active() -> bool:
	return beautifier_active
	
func set_profile_name_min_size(_profile_name_min_size : int) -> void:
	profile_name_min_size = _profile_name_min_size
	
func get_profile_name_min_size() -> int:
	return profile_name_min_size
	
func set_profile_name_max_size(_profile_name_max_size : int) -> void:
	profile_name_max_size = _profile_name_max_size
	
func get_profile_name_max_size() -> int:
	return profile_name_max_size


# Nomes considerados invalidos 
# 1) no_valid_names[]
# 2) O noe não pode ser "perfil"
# 3) Dentro dos caracteres mínimos e máximos.
func validate_profile(profile_name : String) -> bool:
	var profiles = get_profiles()
	
	# 1)
	if no_valid_names != null and no_valid_names.has(profile_name):
		debug("Nome invalido: ", profile_name)
		return false
	
	# 2)
	if profile_name == "perfil":
		debug("Nao pode salvar um perfi com nome pefil")
		return false
	
	# 3)
	if profile_name.length() < profile_name_min_size or profile_name.length() > profile_name_max_size:
		debug("O profile_name não tem a extensão permitida de caracteres. Corrija esse erro")
		return false
	
	return true
	
func save_profile_default() -> bool:
	match mode:
		Mode.ENCRYPTED:
			return save_profile_encripted("default")
		Mode.TEXT:
			return save_profile_text("default")
	
	return false

func load_profile_default() -> bool:
	match mode:
		Mode.ENCRYPTED:
			return load_profile_encripted("default")
		Mode.TEXT:
			return load_profile_text("default")
	
	return false
			
func save_profile_encripted(profile_name : String) -> bool:
	var file_path
	file_path = str("user://" + folder_name + "/" + profile_name + ".save")
	
	erase_profile_encripted(profile_name, file_path)
	
	var file = File.new()
	var err = file.open_encrypted_with_pass(file_path, File.WRITE, password)
	
	if err == OK:
		file.store_var(data)
		file.close()
		
		return true
	else:
		debug("Erro ao criar o arquivo: ", err)
		debug("Endereço Path: ", file_path)
		return false
	
func save_profile_text(profile_name : String) -> bool:
	var file_path
	file_path = str("user://" + folder_name + "/" + profile_name + ".txt")
	
	var file = File.new()
	var err = file.open(file_path, File.WRITE_READ)
	
	if err == OK:
		file.get_line() # Borrar la data anterior
		file.store_string(beautifier.beautify_json(to_json(data)))
		file.close()
		
		return true
	else:
		debug("Erro ao criar o arquivo: ", err)
		return false

func load_profile_encripted(profile_name : String) -> bool:
	var file_path
	file_path = str("user://" + folder_name + "/" + profile_name + ".save")
	
	var file = File.new()
	
	if not file.file_exists(file_path):
		debug("Erro ao criar o arquivo: " + file_path)
		return false
	
	var err = file.open_encrypted_with_pass(file_path, File.READ, password)
	
	if err == OK:
		data = file.get_var()
		file.close()
		
		save_profile_encripted(profile_name)
		
		debug("Carregado o arquiuivo com sucesso: ")
		return true
	else:
		debug("Erro ao ler o arquivo: ", err)
		return false
	
func load_profile_text(profile_name : String) -> bool:
	var file_path = str("user://" + folder_name + "/" + profile_name + ".txt")
	var file = File.new()
	
	if not file.file_exists(file_path):
		debug("O arquvo não existe: " + file_path)
		return false
	
	var err = file.open(file_path, File.READ)
	
	if err == OK:
		var data_str := ""
		
	
		while not file.eof_reached():
			
			data_str = data_str + file.get_line()
		data = parse_json(data_str)
		
		file.close()
		
		save_profile_text(profile_name)

		return true
	else:
		debug("Erro ao ler o arquivo: ", err)
		return false

func erase_profile_encripted(profile_name : String, file_path : String) -> void:
	var file = File.new()
	var err = file.open_encrypted_with_pass(file_path, File.READ, password)
	
	if err == OK:
		file.get_var()
		file.close()
	else:
		debug("Erro ao reparar o arquivo: ", err)


func create_main_folder() -> void:
	var dir = Directory.new()
	
	if not dir.dir_exists(str("user://" + folder_name)):
		dir.make_dir(str("user://" + folder_name))
		debug("Foi criado uma pasta ", folder_name)


func load_data(profile_name : String = "") -> bool:
	var result
	
	if profile_name == "":
		if load_profile_default():
			emit_signal("loaded")
			return true
		else:
			debug("load_profile_default retorna false.")
			return false
	
	if validate_profile(profile_name): 
		match mode:
			Mode.ENCRYPTED:
				result = load_profile_encripted(profile_name)
			Mode.TEXT:
				result = load_profile_text(profile_name)
	else:
		debug("Erro de validação bebê")
		result = false
	
	if result:
		emit_signal("loaded")
	
	return result

func print_json(json : String) -> void:
	if beautifier != null:
		print("______________- JSON -______________")
		print(beautifier.beautify_json(json))
		print("____________________________________")
	
