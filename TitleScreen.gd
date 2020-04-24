extends Panel

# Script for controlling GUI functionality and animations on the title screen.

var regex = RegEx.new()

# Called as soon as the script loads.
func _ready():
	get_node('NoteVelocityUp1').connect('pressed', self, '_changeNoteVelocity', [1])
	get_node('NoteVelocityDown1').connect('pressed', self, '_changeNoteVelocity', [-1])
	get_node('NoteVelocityUp10').connect('pressed', self, '_changeNoteVelocity', [10])
	get_node('NoteVelocityDown10').connect('pressed', self, '_changeNoteVelocity', [-10])
	get_node('SelectChartButton').connect('pressed',  self, '_openFileDialog')
	get_node('SelectChartDialog').connect('file_selected', self, '_startGame')
	get_node('QuitGameDialog').get_cancel().connect('pressed', self, '_cancelQuitGame')
	get_node('QuitGameDialog').get_ok().connect('pressed', self, '_confirmQuitGame')
	get_node('MainLogo/LogoCollision').connect('mouse_entered', self,  '_showMainLogo', [true])
	get_node('MainLogo/LogoCollision').connect('mouse_exited', self,  '_showMainLogo', [false])
	Global.selectedChartPath = 'C:/Users/Tian/Documents/Personal Projects/Godot Builds/Charts/Freedom Dive.json'
	Global.noteSpeed = (140 / 200.0) * 22
	get_tree().change_scene('res://MainGame.tscn')
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animate the text at the bottom of the screen.
	get_node('RainbowColorBar').position.x += 4
	if get_node('RainbowColorBar').position.x >= 1256:
		get_node('RainbowColorBar').position.x = 272

	
# Take user inputs.
func _input(event):
	# Handle mouse clicks.
	if event is InputEventMouseMotion:
		var mouseX = event.position[0]
		var mouseY = event.position[1]
		if mouseX > 986 and mouseX < 1329:
			if mouseY > 127 and mouseY < 326:
				get_node('ColorBorderRight2').visible = true
			elif mouseY > 354 and mouseY < 614:
				get_node('ColorBorderRight1').visible = true
			else:
				get_node('ColorBorderRight2').visible = false
				get_node('ColorBorderRight1').visible = false
		else:
				get_node('ColorBorderRight2').visible = false
				get_node('ColorBorderRight1').visible = false
		if mouseX > 212 and mouseX < 1329:
			if mouseY > 643 and mouseY < 734:
				get_node('ColorBorderWide').visible = true
			else:
				get_node('ColorBorderWide').visible = false
		else:
			get_node('ColorBorderWide').visible = false
	# Handle key presses.
	elif event is InputEventKey and event.pressed:
		# Start game.
		if event.scancode == KEY_SPACE and self.visible:
			if Global.selectedChartPath != '':
				get_node('ImpactSound').play()
				get_parent().get_node('TitleScreenMusic').stop()
				self.visible = false
				yield(get_tree().create_timer(2.0), "timeout")
				Global.noteSpeed = (Global.noteVelocity / 200.0) * 22
				get_tree().change_scene('res://MainGame.tscn')
			else:
				get_node('ErrorSound').play()
		# Quit game.
		elif event.scancode == KEY_ESCAPE:
			get_node('QuitGameDialog').visible = true
		
			
# Change the visibility status of the main color border.
func _showMainLogo(value):
	if not value:
		get_node('MainLogo').modulate.a = 0
	else:
		get_node('MainLogo').modulate.a = 1


# Change the note velocity.
func _changeNoteVelocity(amount):
	var velocity = int(get_node('NoteVelocity').text)
	if velocity >= 200 and amount > 0:
		get_node('ErrorSound').play()
	elif velocity <= 50 and amount < 0:
		get_node('ErrorSound').play()
	else:
		get_node('HitSound').play()
		get_node('NoteVelocity').text = str(int(velocity) + amount)
		Global.noteVelocity = int(velocity) + amount
		
	if int(get_node('NoteVelocity').text) < 50:
		get_node('NoteVelocity').text = '50'
		Global.noteVelocity = 50
	elif int(get_node('NoteVelocity').text) > 200:
		get_node('NoteVelocity').text = '200'
		Global.noteVelocity = 200
	

# Cancel quitting the game.	
func _cancelQuitGame():
	Global.cancelQuitGameTitle(get_node('HitSound').get_parent())
	

# Confirm quitting the game.
func _confirmQuitGame():
	Global.confirmQuitGame(get_node('HitSound').get_parent())
		

# Open the file dialog for selecting a chart.
func _openFileDialog():
	get_node('HitSound').play()	
	get_node('SelectChartDialog').visible = true
	

# Set note speed on screen and start the game.
func _startGame(path):
	Global.selectedChartPath = path
	regex.compile("[ \\w-]+\\.")
	var result = regex.search(Global.selectedChartPath)
	get_node('ChosenFile').text = result.get_string().trim_suffix('.')
