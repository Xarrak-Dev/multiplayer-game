extends Control

var text

func _on_ip_label_text_changed() -> void:
	text = $JoinButton.text
	MultiplayerManager.serverIP = text

func _on_join_button_pressed() -> void:
	MultiplayerManager.becomeJoin()
	
