extends Panel


var scoreTallyTimer = Timer.new()
var maxScore = Global.totalNoteCount * 100
var percentage = str(Global.totalScore * 100 / float(maxScore))
var perfectDone = false
var goodDone = false
var okayDone = false
var missDone = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gameState = 'RESULTS_TALLYING'
	get_node('QuitGameDialog').get_cancel().connect('pressed', self, '_cancelQuitGame')
	get_node('QuitGameDialog').get_ok().connect('pressed', self, '_confirmQuitGame')
	add_child(scoreTallyTimer)
	scoreTallyTimer.autostart = true
	scoreTallyTimer.one_shot = false
	scoreTallyTimer.wait_time = 0.035
	scoreTallyTimer.connect('timeout', self, '_tallyScores')
	scoreTallyTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animate text at the bottom of the screen.
	get_node('RainbowColorBar').position.x += 4
	if get_node('RainbowColorBar').position.x >= 1238:
		get_node('RainbowColorBar').position.x = 290
		

# Handle user inputs.
func _input(event):
	# Handle keyboard presses.
	if event is InputEventKey and event.pressed:
		# Quit game.
		if event.scancode == KEY_ESCAPE:
			get_node('QuitGameDialog').visible = true
		# Either skip tallying or move back to title screen.
		if event.scancode == KEY_SPACE:
			get_node('ImpactSound').play()
			if Global.gameState == 'RESULTS_TALLYING':
				scoreTallyTimer.stop()
				get_node('PerfectCount').text = str(Global.perfectCount)
				get_node('GoodCount').text = str(Global.goodCount)
				get_node('OkayCount').text = str(Global.okayCount)
				get_node('MissCount').text = str(Global.missCount)
				_displayScoreTotal()
			elif Global.gameState == 'RESULTS_FINISHED':
				# TODO: Loop back to start screen.
				self.visible = false
				yield(get_tree().create_timer(2.0), "timeout")
				get_tree().change_scene('res://TitleScreen.tscn')
			
			
# Cancel quitting the game.	
func _cancelQuitGame():
	Global.cancelQuitGameTitle(get_node('HitSound').get_parent())
	

# Confirm quitting the game.
func _confirmQuitGame():
	Global.confirmQuitGame(get_node('HitSound').get_parent())
	
		
# Animate score tallying.
func _tallyScores():
	if Global.gameState == 'RESULTS_TALLYING':
		if int(get_node('PerfectCount').text) < Global.perfectCount:
			get_node('PerfectCount').text = str(int(get_node('PerfectCount').text) + 1)
			get_node('ScoreTickSound').play()
		else:
			perfectDone = true
		if int(get_node('GoodCount').text) < Global.goodCount:
			get_node('GoodCount').text = str(int(get_node('GoodCount').text) + 1)
			get_node('ScoreTickSound').play()		
		else:
			goodDone = true
		if int(get_node('OkayCount').text) < Global.okayCount:
			get_node('OkayCount').text = str(int(get_node('OkayCount').text) + 1)
			get_node('ScoreTickSound').play()		
		else:
			okayDone = true
		if int(get_node('MissCount').text) < Global.missCount:
			get_node('MissCount').text = str(int(get_node('MissCount').text) + 1)
			get_node('ScoreTickSound').play()		
		else:
			missDone = true
		if perfectDone and okayDone and goodDone and missDone:
			scoreTallyTimer.stop()
			yield(get_tree().create_timer(1.25), "timeout")
			_displayScoreTotal()


# Fill in the total score.
func _displayScoreTotal():
	get_node('ImpactSound').play()
	get_node('TotalScoreAndPercentage').text = str(Global.totalScore) + ' / ' + str(maxScore) + ' (' + percentage.left(5) + '%)'
	Global.gameState = 'RESULTS_FINISHED'

