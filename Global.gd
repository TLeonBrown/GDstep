extends Node2D

# Top-level script that holds global data.


# VARIABLES --------------------------------------------------------------------


# Static global variables.
var NOTE_X_POS = {1: 102, 2: 216, 3: 426.5, 4: 637, 5: 751, 6: 102, 7: 216, 8: 637, 9: 751}
var PERFECT_Y = 220
var SCREEN_SIZE = [1920, 1080]
var HIT_FLASH_DURATION_FRAMES = 3
var LETTER_TO_NOTES = {
	'1': [1], '2': [2], '3': [3], '4': [4], '5': [5],
	'A': [1, 2], 'B': [1, 3], 'C': [1, 4], 'D': [1, 5],
	'E': [2, 3], 'F': [2, 4], 'G': [2, 5],
	'H': [3, 4], 'I': [3, 5],
	'J': [4, 5],
	'K': [1, 2, 3], 'L': [1, 2, 4], 'M': [1, 2, 5], 'N': [1, 3, 4], 'O': [1, 3, 5], 'P': [1, 4, 5],
	'Q': [2, 3, 4], 'R': [2, 3, 5], 'S': [2, 4, 5],
	'T': [3, 4, 5],
	'U': [1, 2, 3, 4], 'V': [1, 2, 3, 5], 'W': [1, 2, 4, 5], 'X': [1, 3, 4, 5],
	'Y': [2, 3, 4, 5],
	'Z': [1, 2, 3, 4, 5],
	'6': [6], '7': [7], '8': [8], '9': [9],
	'a': [6, 7], 'b': [6, 3], 'c': [6, 8], 'd': [6, 9],
	'e': [7, 3], 'f': [7, 8], 'g': [7, 9],
	'h': [3, 8], 'i': [3, 9],
	'j': [8, 9],
	'k': [6, 7, 3], 'l': [6, 7, 8], 'm': [6, 7, 9], 'n': [6, 3, 8], 'o': [6, 3, 9], 'p': [6, 8, 9],
	'q': [7, 3, 8], 'r': [7, 3, 9], 's': [7, 8, 9],
	't': [3, 8, 9],
	'u': [6, 7, 3, 8], 'v': [6, 7, 3, 9], 'w': [6, 7, 8, 9], 'x': [6, 3, 8, 9],
	'y': [7, 3, 8, 9],
	'z': [6, 7, 3, 8, 9],
}

# Dynamic global variables.
var gameState = 'TITLE'

var chartData = {}
var selectedChartPath = ""

var noteVelocity = 100
var noteSpeed = 0

var totalScore = 0
var perfectCount = 0
var goodCount = 0
var okayCount = 0
var missCount = 0
var totalNoteCount = 0



# FUNCTIONS --------------------------------------------------------------------



# Cancel quitting the game from the title screen.
func cancelQuitGameTitle(sceneNode):
	sceneNode.get_node('HitSound').play()
	sceneNode.get_node('QuitGameDialog').visible = false
	

# Cancel quitting the game from the main game.
func cancelQuitGameGame(sceneNode):
	Global.gameState = 'GAME_UNPAUSED'
	sceneNode.songPlayer.stream_paused = false
	sceneNode.get_node('BGA').paused = false
	
	
# Confirm quitting the game.
func confirmQuitGame(sceneNode):
	sceneNode.get_node('HitSound').play()	
	OS.delay_msec(250)
	get_tree().quit()
	

# Calculate how many times a second a new character should be read, based on the chart's BPM.
func bpmToNoteSpeed():
	return 1 / ((chartData['BPM'] * chartData['BPM_Mod']) / 60)
