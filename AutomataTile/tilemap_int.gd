extends TileMap

const INT_MAX = 9223372036854775807

var empty_mask: Array = []
var display_mask: Array = []
var process_mask: Array = []

var frame_cache setget set_frame, get_frame

var width: int = 64
var height: int = 64

func fill_with_random():
  randomize()
  for x in range(1, width - 1):
    for y in range(1, height - 1):
      var v = randi()%2
      set_cell(x, y, v)

func _ready():
  # On initialize le mask "vide", vu que Godot est pas capable d'avoir une methode "fill"
  var line = 0
  for x in range(width):
    line += 1 << x
  for y in range(height):
    empty_mask.append(0)
    # On va process et afficher toutes les lignes. Je pourrais surement jouer
    # sur ce truc pour faire un truc sympa d'une
    # manière ou d'une autre
    display_mask.append(line)
    process_mask.append(line)
  
  # Evidemment, il faudra un moyen pour fill avec autre chose que du random.
  # Au hasard du vide, ou bien un hasard pondéré.
  fill_with_random()
  
func set_frame(frame: Array) -> void:
  for y in range(0, height):
    var line: int = frame[y]
    var display_mask_line = display_mask[y]
    for x in range(0, width):
      if display_mask_line == 0: break
      if display_mask_line & 1: 
        var cell_value = (line >> x) & 1
        set_cellv(Vector2(x, y), cell_value)
      display_mask_line >>= 1
  frame_cache = frame

func get_frame() -> Array:
  if !frame_cache:
    frame_cache = []
    for y in range(0, height):
      var line: int = 0
      for x in range(0, width):
        var cell_value = get_cellv(Vector2(x, y))
        line += (cell_value) << x
      frame_cache.append(line)
  return frame_cache

func get_cell_status(position: Vector2) -> int:
  return self.frame_cache[position.y] >> position.x & 1

func get_neighbors_and_status(position: Vector2) -> int:
  var neighbors: int = 0
  var displacement: int = 0
  for ymod in range(position.y-1, position.y+2): 
    var xmod: int = position.x - 1
    neighbors += (frame_cache[ymod] >> xmod & 0b111) << (3 * displacement)
    displacement += 1
  return neighbors

# TODO prévoir un retour booléen pour annoncer la fin du processing
func process_next_frame(rules) -> void:
  var new_frame: Array = self.frame_cache.duplicate()
  
  display_mask = empty_mask.duplicate()
  var next_process_mask: Array = empty_mask.duplicate()
  
  for y in range(1, 63):
    # Le décallage est là car on fait sauter le "bord"
    var process_mask_line: int = process_mask[y] >> 1
    if process_mask_line == 0: continue
    
    var current_line: int = new_frame[y]
    var new_line: int = new_frame[y]

    for x in range(1, 63):
      if process_mask_line == 0: break
      if process_mask_line & 0b1:
        var position = Vector2(x, y)
        var tile_neighbors: int = get_neighbors_and_status(position)
        var new_status = rules.transition_to(tile_neighbors)
        if new_status == null: continue
        # On est obligé de "unset" la/les bits en question. On pourrait ^
        # pour aller plus vite mais ça nous limite à un status alive/dead
        new_line -= (tile_neighbors >> 4 & 0b1) << x
        new_line += new_status << x
        
      process_mask_line >>= 1

    var line_diff: int = current_line ^ new_line
    # Si aucune modification n'a été effectuée, on passe les assignations
    if line_diff == 0: continue
    
    var process_line_diff: int  = line_diff | (line_diff << 1) | (line_diff >> 1)
    new_frame[y] = new_line
    display_mask[y] = line_diff
    
    next_process_mask[y - 1] |= process_line_diff
    next_process_mask[y] |= process_line_diff
    next_process_mask[y + 1] = process_line_diff
  
  self.process_mask = next_process_mask
  self.frame_cache = new_frame

func clear_frame_cache() -> void:
  if frame_cache: frame_cache = null

  var line = 0
  for x in range(width):
    line += 1 << x
    
  for y in range(height):
    display_mask[y] = line
    process_mask[y] = line
