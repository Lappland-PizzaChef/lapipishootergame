extends Node2D

@onready var player = $Player
@onready var main_camera = $MainCamera

@export var level_complete_ui_scene: PackedScene
var level_complete_ui: Node = null

@export var next_level_scene: PackedScene

var enemy_count: int = 0

func _ready() -> void:
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemy_count = enemies.size()
	for enemy in enemies:
		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_died)
			
	# Instance of the UI Scene for next level
	level_complete_ui = level_complete_ui_scene.instantiate()
	add_child(level_complete_ui)
	level_complete_ui.visible = false # hide at start
	
	level_complete_ui.connect("next_level_pressed", Callable(self, "_on_NextLevelButton_pressed"))
	level_complete_ui.connect("quit_pressed", Callable(self, "_on_QuitButton_pressed"))
			
func _on_enemy_died():
	enemy_count -= 1
	if enemy_count <= 0:
		_show_level_complete()
	
func _on_player_died():
	print("game over")
	
	get_tree().create_timer(3).timeout.connect(get_tree().reload_current_scene)

func _on_NextLevelButton_pressed():
	if next_level_scene:
		get_tree().change_scene_to_packed(next_level_scene)
		
func _on_QuitButton_pressed():
	get_tree().quit()

func _show_level_complete():
	print("Showing level complete UI")
	print("UI parent: ", level_complete_ui.get_parent())
	level_complete_ui.visible = true
	level_complete_ui.get_node("Complete/Panel").visible = true
	level_complete_ui.set_process(true)
	level_complete_ui.set_physics_process(true)
