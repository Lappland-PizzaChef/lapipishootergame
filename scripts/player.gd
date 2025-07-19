extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform
@onready var shoot_raycast = $ShootRayCast

@onready var shoot_sound = $ShootSound
@onready var death_sound = $DeathSound
@onready var laser_btnon = $LaserOn
@onready var laser_btnoff = $LaserOff


@onready var laser_line = $LaserLine2D
@onready var animplayer = $AnimationPlayer

var speed = 300.0
var laser_on := false

var can_process_input := true

func _ready():
	laser_line.visible = laser_on

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if 	Input.is_action_just_pressed("toggle_laser"):
		laser_on = !laser_on
		laser_line.visible = laser_on
		
		if laser_on:
			laser_btnon.play()
			animplayer.play("turn_laser_on")
			print("Laser turned On")
		else:
			laser_btnoff.play()
			print("Laser turned OFF")
		
	if shoot_raycast.is_colliding():
		var cp = shoot_raycast.get_collision_point()
		var local_cp = to_local(cp)
		laser_line.points[1] = local_cp
	else:
		laser_line.points[1] = Vector2(1000,0)
		
	if Input.is_action_just_pressed("shoot"):
		shoot_sound.play()
		if shoot_raycast.is_colliding():
			var collider = shoot_raycast.get_collider()
			if collider is StaticBody2D:
				print("Shot a box")
			elif collider is MafiosaKnife:
				collider.player = self
				collider.take_damage(1)

func _physics_process(delta: float) -> void:
	if not can_process_input:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var move_dir = Vector2(Input.get_axis("move_left", "move_right"),
	Input.get_axis("move_up", "move_down"))
	
	if move_dir != Vector2.ZERO:
		velocity = speed * move_dir.normalized()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		
	move_and_slide()
	

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is MafiosaKnife:
		can_process_input = false
		
		var snd = AudioStreamPlayer.new()
		snd.stream = death_sound.stream
		get_tree().current_scene.add_child(snd)
		snd.play()
		
		died.emit()
		
		await snd.finished
		
		queue_free()
