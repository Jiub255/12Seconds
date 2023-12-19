class_name HighScoreEntry
extends HBoxContainer


func setup_entry(rank : String, player_name : String, score : String) -> void:
	$RankLabel.text = rank
	$NameLabel.text = "  " + player_name
	$ScoreLabel.text = score + "  "
