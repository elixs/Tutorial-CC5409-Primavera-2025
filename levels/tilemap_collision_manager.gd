extends Node

@export var coords: Array[Vector2i]
@export var tile_map: TileMapLayer

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	for c in coords:
		var atlas_coords = tile_map.get_cell_atlas_coords(c)
		tile_map.set_cell(c, 2, atlas_coords, 1)
	
