extends Node

func route_to_Chat_bus(_audio: RaytracedAudioPlayer3D):
	var idx := AudioServer.get_bus_index(_audio.bus)
	if idx != -1:
		AudioServer.set_bus_send(idx, "Chat")

func route_to_SFX_bus(_audio: RaytracedAudioPlayer3D):
	var idx := AudioServer.get_bus_index(_audio.bus)
	if idx != -1:
		AudioServer.set_bus_send(idx, "SFX")
