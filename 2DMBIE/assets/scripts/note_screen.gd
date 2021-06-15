
extends Control

var storytext = ["We lived in harmony", "We shared our life", "We shared our home", "Why....?", "Does killing us...", "Make you happy...?", "We can't even die", "We would just reappear at our tombstones", "You realize this, don't you...", "Does this have to do with the Explosion", "That must be it...", "But Why...?", "We don't want to kill our friends", "But you leave us no choice", "You are making us suffer", "You confuse us...", "Where do the weapons that you hold come from?", "Why can't you walk through the open doors...", "Because you powers have been amplified..", "It's like they say, Human imagination is the strongest thing there is." ]
var pickedNotes = 0 #  1                            2                3                  4             5                     6                         7                8                                              9                             10                                            11                       12     13                                     14                          15                                  16           17                                                    18                                              19                                              20                                                                      

signal pauseGame()

func onNoteRead():
	if Global.noteCount >= Global.neededNotes:
		$popupNode/StoryLabel.text = "We thought the humans slaughtered without reason. But it seems their brains have been infected. They think the zombies must die for this thing called ‘score’. And with this ‘score’ they could open doors and access new weapons. It truly is weird, because the doors are already open, but they refuse to walk through them until they use their score to ‘open’ the door. But there is something even weirder. Sometimes, they just get a new weapon, or a buff, or more bullets. And we don’t know why. Maybe they use their score for it, is it something we cannot see? Well it seems there is nothing we can do, all we can do is aimlessly throw ourselves at the humans and hope they might die."
	else:
		$popupNode/StoryLabel.text = storytext[pickedNotes]
	$popupNode.popup()
	pickedNotes += 1
	Global.noteCount += 1
	emit_signal("pauseGame")

func CloseNote():
	$popupNode.visible = false


