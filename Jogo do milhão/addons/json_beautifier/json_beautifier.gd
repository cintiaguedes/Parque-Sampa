extends Node
class_name JSONBeautifier

# Aqui o JSON precisa de ser informado a identação, do contrário o GODOT irá apenas expor como um texto plano

static func beautify_json(json : String, espacos : int = 0) -> String:
	var error_message = validate_json(json)
	if not error_message.empty():
		return error_message
	
	var indentation = ""
	if espacos > 0:
		for i in espacos:
			indentation += " "
	else:
		indentation = "\t"
	
	var char_position = 0
	var quotation_start = -1
	for i in json:
		if i == "\"":
			if quotation_start == -1:
				quotation_start = char_position
			elif json[char_position - 1] != "\\":
				quotation_start = -1
			
			char_position += 1
			
			continue
		elif quotation_start != -1:
			char_position += 1
			
			continue
		
		match i:
			# Remove as formatações originais
			" ", "\n", "\t":
				json[char_position] = ""
				char_position -= 1
			
			"{", "[", ",":
				if json[char_position + 1] != "}" and\
						json[char_position + 1] != "]":
					json = json.insert(char_position + 1, "\n")
					char_position += 1
			"}", "]":
				if json[char_position - 1] != "{" and\
						json[char_position - 1] != "[":
					json = json.insert(char_position, "\n")
					char_position += 1
			":":
				json = json.insert(char_position + 1, " ")
				char_position += 1
		
		char_position += 1
	
	var bracket_start
	var bracket_end
	var bracket_count
	for i in [["{", "}"], ["[", "]"]]:
		bracket_start = json.find(i[0])
		while bracket_start != -1:
			bracket_end = json.find("\n", bracket_start)
			bracket_count = 0
			while bracket_end != - 1:
				if json[bracket_end - 1] == i[0]:
					bracket_count += 1
				elif json[bracket_end + 1] == i[1]:
					bracket_count -= 1
				
				# Rola as informações para buscar um item correspondente
				while json[bracket_end + 1] == indentation:
					bracket_end += 1
					
					if json[bracket_end + 1] == i[1]:
						bracket_count -= 1
				
				if bracket_count <= 0:
					break
				
				bracket_end = json.find("\n", bracket_end + 1)
			
			# Pula uma linha para não perder a identaçao.
			bracket_end = json.rfind("\n", json.rfind("\n", bracket_end) - 1)
			while bracket_end > bracket_start:
				json = json.insert(bracket_end + 1, indentation)
				bracket_end = json.rfind("\n", bracket_end - 1)
			
			bracket_start = json.find(i[0], bracket_start + 1)
	
	return json

