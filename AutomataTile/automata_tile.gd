extends Node2D

enum STATE { DRAW, PLAY }
const Transitions = preload('res://transitions.gd')
onready var rules = Transitions.new()
# TODO ? const BITS_PER_STATUS = 1 # 1 = 2 status, 2 = 4 statuses, 3 = 7 statuses. No more.

var state: int setget set_state

func set_state(new_state: int) -> void:
  state = new_state
  match state:
    STATE.DRAW:
      $Timer.stop()
    STATE.PLAY: 
      $TileMap.clear_frame_cache()
      $Timer.start()

func ready():
  self.state = STATE.DRAW

func _input(event: InputEvent) -> void:
  match self.state:
    STATE.PLAY:
      if Input.is_action_pressed("ui_accept") and not event.is_echo():
        self.state = STATE.DRAW
    STATE.DRAW:
      if Input.is_action_pressed("ui_accept") and not event.is_echo():
        self.state = STATE.PLAY
      elif event is InputEventMouseButton && event.button_index == BUTTON_LEFT and event.pressed:
        # On dessin à la volée sur la tilemap
        var tile_position: Vector2 = $TileMap.world_to_map(event.position)
        # On ne peux pas cliquer sur les tiles en dehors, ce sont les "snaps"
        if tile_position.x <= 0 || tile_position.x >= 63: return
        if tile_position.y <= 0 || tile_position.y >= 63: return
        # Si on est pas dessinnée, on est en dehors, donc on dessine pas
        var old_value = $TileMap.get_cellv(tile_position)
        if old_value == -1: return
        # On dessine
        var new_value = (old_value + 1) % 2
        $TileMap.set_cellv(tile_position, new_value)

func process():
  if (!rules): return
  $TileMap.process_next_frame(rules)
