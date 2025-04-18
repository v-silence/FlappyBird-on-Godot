extends Node2D

@export var pipe_scene : PackedScene

var game_running
var game_over
var scroll
var score
const SCROLL_SPEED = 250
var screen_size: Vector2i
var ground_height
var pipes : Array
const PIPE_DELAY = 100
const PIPE_RANGE = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	for pipe in pipes:
		pipe.queue_free()
	$ScoreLabel.text = "SCORE: " + str(score)
	pipes.clear()
	generate_pipes()
	$Bird.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()

func start_game():
	$GameOver.hide()
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED * delta
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED * delta
	

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true
	$GameOver.show()

func _on_ground_hit() -> void:
	$Bird.falling = false
	stop_game()



func _on_pipe_timer_timeout() -> void:
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.score.connect(score_incr)
	add_child(pipe)
	pipes.append(pipe)

func bird_hit():
	$Bird.falling = true
	stop_game()

func score_incr():
	score+=1
	$ScoreLabel.text = "SCORE: " + str(score)


func _on_game_over_restart() -> void:
	new_game()
	$GameOver.hide()
