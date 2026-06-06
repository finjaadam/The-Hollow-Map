extends Node

func print_bus_order() -> void:
	print("=== Audio Bus Order ===")
	for i in range(AudioServer.get_bus_count()):
		var name = AudioServer.get_bus_name(i)
		var send = AudioServer.get_bus_send(i)
		var send_str = send if send != "" else "none (master)"
		print("[%d] %s  →  %s" % [i, name, send_str])
	print("=======================")
