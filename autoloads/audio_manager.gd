extends Node


func play_sound(sound: AudioStream) -> void:
	if not sound:
		return
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.bus = "SFX"
	player.play()
	await player.finished
	player.queue_free()
	
