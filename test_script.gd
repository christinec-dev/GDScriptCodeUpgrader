extends KinematicBody2D

# Signal declaration
signal player_moved(position)

var velocity = Vector2()
emit_signal("player_moved")
func _ready():
    randomize()
    set_physics_process(true)

func _physics_process(delta):
    var input_vector = Vector2()
    if Input.is_action_pressed("ui_right"):
        input_vector.x += 1
    if Input.is_action_pressed("ui_left"):
        input_vector.x -= 1
    if Input.is_action_pressed("ui_down"):
        input_vector.y += 1
    if Input.is_action_pressed("ui_up"):
        input_vector.y -= 1

    input_vector = input_vector.normalized()
    velocity = move_and_slide(input_vector * 200)

    if input_vector != Vector2():
        emit_signal("player_moved", position)

# Example of using yield with a signal
func some_function():
    yield($Timer, "timeout")
    print("Timer finished!")

# Example of connecting signals in Godot 3
func _enter_tree():
    connect("player_moved", self, "_on_Player_moved")

func _on_Player_moved(new_position):
    print("Player moved to: ", new_position)

# Example of using File.new() which should be replaced
func save_game():
    var file = File.new()
    file.open("user://savegame.save", File.WRITE)
    file.store_var(velocity)
    file.close()

# Example of using yield for a coroutine
func example_coroutine():
    yield(get_tree().create_timer(1.0), "timeout")
    print("Coroutine after 1 second")
