extends Node

signal changeScore(newScore)

var Score = 0 setget setScore

func setScore(newScore):
	newScore = max(0, newScore)
	Score = newScore
	emit_signal("changeScore", Score)

