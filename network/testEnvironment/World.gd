extends Node3D

func _ready():
	NetworkManager.register_world($MultiplayerSpawner, $Map/PlayerSpawnPoints)
