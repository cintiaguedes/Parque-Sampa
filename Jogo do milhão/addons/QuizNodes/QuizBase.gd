extends Node

class_name QuizBase

export (bool) var debug := true

func debug(message, something1 = "", something2 = ""):
	if debug:
		print("[QuizNodes] ", message, " ", something1, " ", something2)
