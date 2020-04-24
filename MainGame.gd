extends Panel

# Main script for running the game.

var timeBegin = 0
var timeDelay = 0
var songPlayer = AudioStreamPlayer.new()
var fileIO = File.new()
var timer = Timer.new()
var counter = 0
var notesOnScreen = []
var hitNodes = {}
var playedForwards = false
var noteGridStatus = false
var NoteSprite = load('NoteSprite.gd')

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gameState = 'GAME_UNPAUSED'	
	get_node('QuitGameDialog').get_cancel().connect('pressed', self, '_cancelQuitGame')
	get_node('QuitGameDialog').get_ok().connect('pressed', self, '_confirmQuitGame')
	_readJSONData()
	_loadSong()
	_fillInChartInfo()
	_setUpTimer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Manually restart the video if it finishes, since there is no looping setting.
	if not get_node('BGA').is_playing():
		get_node('BGA').play()
		
	# Update note grid status variable.
	noteGridStatus = get_node('NoteGridCold').visible

	# Update note visibility and y-position if the game is not paused.
	if Global.gameState == 'GAME_UNPAUSED':
		get_node('PauseOverlay').visible = false
		get_node('PauseLabel').visible = false
		for note in notesOnScreen:
			if note.position.y < 20:
				_removeNote(note)
				Global.missCount += 1
				get_node('MissCountLabel').text = str(int(get_node('MissCountLabel').text) + 1)
			note.position.y -= Global.noteSpeed
	# Display 'PAUSED' text if game is paused.
	else:
		get_node('PauseOverlay').visible = true
		get_node('PauseLabel').visible = true
		for note in notesOnScreen:
			note.visible = false
			
	# Check for hit nodes and hide them if they have been visible for the specified duration.
	for hit in hitNodes:
		if hitNodes[hit] == Global.HIT_FLASH_DURATION_FRAMES:
			hit.visible = false
		hitNodes[hit] += 1


# Handle user inputs.
func _input(event):
	# Handle standard keyboard presses.
	if event is InputEventKey:
		if event.is_action_pressed('ui_page_up') and event.scancode == KEY_SHIFT:
			get_parent().get_node('ShiftForwards').play()
			get_node('NoteGridCold').visible = true
		elif event.is_action_released('ui_page_up') and event.scancode == KEY_SHIFT:
			get_parent().get_node('ShiftBackwards').play()
			get_node('NoteGridCold').visible = false
		elif event.pressed:
			# Quit game dialog.
			if event.scancode == KEY_ESCAPE:
				Global.gameState = 'GAME_PAUSED'
				songPlayer.stream_paused = true
				get_node('BGA').paused = true
				get_node('QuitGameDialog').visible = true
			# Handle pressing the Shift key.
			
			# Check for key presses to hit notes.	
			elif event.scancode == KEY_Q:
				_handleHitEffects(1)
				_checkForHitNotes(1)
			elif event.scancode == KEY_W:
				_handleHitEffects(2)
				_checkForHitNotes(2)
			elif event.scancode == KEY_SPACE:
				get_node('Hit3').visible = true
				hitNodes[get_node('Hit3')] = 0
				get_node('Hit3b').visible = true
				hitNodes[get_node('Hit3b')] = 0
				_checkForHitNotes(3)
			elif event.scancode == KEY_O:
				_handleHitEffects(4)
				_checkForHitNotes(4)
			elif event.scancode == KEY_P:
				_handleHitEffects(5)
				_checkForHitNotes(5)
			# Check for key presses to pause or unpause the game.
			elif event.scancode == KEY_MINUS:
				Global.gameState = 'GAME_PAUSED'
				songPlayer.stream_paused = true
				get_node('BGA').paused = true
			elif event.scancode == KEY_EQUAL:
				Global.gameState = 'GAME_UNPAUSED'
				songPlayer.stream_paused = false
				get_node('BGA').paused = false
		
	
# Cancel quitting the game.	
func _cancelQuitGame():
	Global.cancelQuitGameGame(get_node('HitSound').get_parent())
	

# Confirm quitting the game.
func _confirmQuitGame():
	Global.confirmQuitGame(get_node('HitSound').get_parent())


# Read data from the selected JSON file.	
func _readJSONData():
	# Open the file requested on the title screen. Parse the data into a global dict.
	fileIO.open(Global.selectedChartPath, File.READ)
	Global.chartData = JSON.parse(fileIO.get_as_text()).result
	# Update the global chart data variable.
	Global.chartData['notes'] += '************'


# Start playing the chart's corresponding song.
func _loadSong():
	self.add_child(songPlayer)
	songPlayer.stream = load('res://Assets/music/' + Global.chartData['song'])
	songPlayer.play()
	
	
# Update the info at the top of the screen.
func _fillInChartInfo():
	get_node('ChartInfoLabel').text = \
		Global.chartData['title'] + ' - ' + Global.chartData['author'] + \
		'\nBPM ' + str(Global.chartData['BPM']) + \
		'\nDifficulty: ' + Global.chartData['difficulty'] + '/7'
	

# Set up the timer to create notes according to the chart's BPM.
func _setUpTimer():
	add_child(timer)
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = Global.bpmToNoteSpeed()
	timer.connect('timeout', self, '_createNote')
	timer.start()
	
	
# Create a note.
# Called repeatedly, when the timer times out.
func _createNote():
	# Handle what happens when the program runs out of characters.
	if counter >= len(Global.chartData['notes']):
		# Stop the timer and the music.
		timer.stop()
		songPlayer.stop()
		# Skip to results screen.
		get_tree().change_scene('res://ResultsScreen.tscn')
	else:
		# Process notes like normal if the game has not run out of notes yet.
		var character = Global.chartData['notes'][counter]
		if Global.gameState == 'GAME_UNPAUSED':
			# Generate the right sprite corresponding to the character, and add it to the scene.
			if character != '*':
				var noteSpritesToAdd = _generateSprite(Global.LETTER_TO_NOTES[character])
				for sprite in noteSpritesToAdd:
					add_child(sprite)
					notesOnScreen.append(sprite)
			counter += 1
	
	
# Given a character in the note string, generate the corresponding Sprite object.
func _generateSprite(characters):
	var noteSpritesToAdd = []
	if Global.gameState == 'GAME_UNPAUSED':
		for character in characters:
			Global.totalNoteCount += 1
			var noteSprite = NoteSprite.new()
			noteSprite.position.x = Global.NOTE_X_POS[character]
			# Calculate the starting y position of the notes based on the note velocity.
			noteSprite.position.y = \
			Global.SCREEN_SIZE[1] + \
			((Global.SCREEN_SIZE[1] - Global.PERFECT_Y) * \
			((Global.noteVelocity - 100) / 100.0))
			noteSprite.texture = load('res://Assets/img/Note' + str(character) + '.png')
			noteSprite.noteIndex = character
			noteSpritesToAdd.append(noteSprite)
	return noteSpritesToAdd
	
	
# Remove a note from the list of notes on screen.
func _removeNote(note):
	remove_child(note)
	notesOnScreen.remove(notesOnScreen.find(note))
	
	
# Handle the visual effects from hitting a note.
func _handleHitEffects(num):
	num = 'Hit' + str(num)
	get_node(num).visible = true
	hitNodes[get_node(num)] = 0
	get_node(num + 'b').visible = !noteGridStatus
	get_node(num + 'c').visible = noteGridStatus
	if not noteGridStatus:
		hitNodes[get_node(num + 'b')] = 0
	else:
		hitNodes[get_node(num + 'c')] = 0
	
	
# Check for notes to hit upon pressing a note key.
func _checkForHitNotes(noteIndex):
	for note in notesOnScreen:
		if note.position.x == Global.NOTE_X_POS[noteIndex]:
			var posDifference = abs(note.position.y - Global.PERFECT_Y)
			# If the note is close enough to be hit (Perfect, Good, or Okay)
			if posDifference <= 90:
				# Process the middle note which never changes.
				if note.noteIndex == 3:
					get_node('Particles3').emitting = true
					get_node('HitSound').play()
					_removeNote(note)
				# If shift is held and we're processing a cold note.
				# Make sure that when shift is held, only the cold notes are hittable.		
				elif note.noteIndex > 5 and noteGridStatus:
					if note.noteIndex == 6 or note.noteIndex == 7:
						get_node('Particles' + str(note.noteIndex % 5)).emitting = true
					elif note.noteIndex == 8 or note.noteIndex == 9:
						get_node('Particles' + str(note.noteIndex - 4)).emitting = true
					get_node('HitSound').play()
					_removeNote(note)
				# If shift is not held and we're processing a warm note.
				# Make sure that when shift isn't held, only the warm notes are hittable.				
				elif note.noteIndex <= 5 and not noteGridStatus:
					get_node('Particles' + str(noteIndex)).emitting = true
					get_node('HitSound').play()
					_removeNote(note)
				else:
					return
				_incrementScore(posDifference)
				


func _incrementScore(posDifference):
	# Perfect
	if posDifference <= 30:
		Global.totalScore += 100
		get_node('TotalScoreLabel').text = str(int(get_node('TotalScoreLabel').text) + 100)
		Global.perfectCount += 1
		get_node('PerfectCountLabel').text = str(int(get_node('PerfectCountLabel').text) + 1)
	# Good
	elif posDifference <= 60:
		Global.totalScore += 70
		get_node('TotalScoreLabel').text = str(int(get_node('TotalScoreLabel').text) + 75)			
		Global.goodCount += 1
		get_node('GoodCountLabel').text = str(int(get_node('GoodCountLabel').text) + 1)
	# Okay
	else:
		Global.totalScore += 30
		get_node('TotalScoreLabel').text = str(int(get_node('TotalScoreLabel').text) + 40)
		Global.okayCount += 1
		get_node('OkayCountLabel').text = str(int(get_node('OkayCountLabel').text) + 1)
