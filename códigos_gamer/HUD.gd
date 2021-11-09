extends CanvasLayer

func Mensagem(text):
	$Mensagem.text = text
	$AnimationPlayer.play("piscando")
	
func EsconderMsg()	:
	$ScoreBox.hide()
	
func MostrarMsg():
	$ScoreBox.show()
	
func Score(value):
	$ScoreBox/HBoxContainer/Score.text = str(value)
