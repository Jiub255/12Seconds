class_name HighScoreEntrySubmit
extends HBoxContainer


var submit_button : Button
var hidden_button : Button
@onready var line_edit : LineEdit = $LineEdit


func setup_entry(rank : String, score : String) -> void:
	$RankLabel.text = rank
	$ScoreLabel.text = score + "  "
	submit_button = $SubmitButton
	hidden_button = $DisabledSpacingButton


func focus() -> void:
	call_deferred("focus_deferred")


func focus_deferred() -> void:
	line_edit.grab_focus()
