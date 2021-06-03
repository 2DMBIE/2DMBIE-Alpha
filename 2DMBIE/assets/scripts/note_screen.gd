
extends Control

var storytext = ["We lived in harmony", "We shared our life", "We shared our home", "Why....?", "Does killing us...", "Make you happy...?", "We can't even die", "We would just reappear at our tombstones", "You realize this, don't you...", "Does this have to do with the Explosion", "That must be it...", "But Why...?", "We don't want to kill our friends", "But you leave us no choice", "You are making us suffer", "You confuse us...", "Where do the weapons that you hold come frome", "why can't you walk through the open doors...", "Because you powers have been amplified..", "it's like they say, Human imagination is the stronges thing there is" ]
var pickedNotes = 0

func onNoteRead():
	$popupNode/StoryLabel.text = storytext[pickedNotes]
	$popupNode.popup()
	pickedNotes += 1
