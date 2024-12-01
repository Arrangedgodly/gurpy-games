extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var background: TileMapLayer = $Background
@onready var detail: TileMapLayer = $Detail
@onready var main_layer: TileMapLayer = $MainLayer

func _ready() -> void:
	camera.zoom = Vector2(2, 2)
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(.15, .15), 3)
