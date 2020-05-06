extends TileMap

var frame_cache

func set_frame(frame: Array, diff: Array = []) -> void:
  for y in range(0, 64):
    if diff != [] && diff[y] == null: continue
    var line: Array = frame[y]
    for x in range(0, 64):
      if diff[y][x] == null: continue
      var cell_value = line[x]
      set_cellv(Vector2(x, y), cell_value)
  frame_cache = frame
  
func get_frame() -> Array:
  if !frame_cache:
    frame_cache = []
    for y in range(0, 64):
      var line: Array = []
      for x in range(0, 64):
        var cell_value = get_cellv(Vector2(x, y))
        line.append(cell_value)
      frame_cache.append(line)
  return frame_cache

func get_cell_status(position: Vector2) -> int:
  return self.get_cellv(position) #return self.frame_cache[position.y][position.x]
  
func get_neighbors_and_status(position: Vector2) -> int:
  var x: int = clamp(position.x, 1, 62)
  var y: int = clamp(position.y, 1, 62)
  var neighbors: int = 0
  var displacement: int = 0
  for ymod in range(y-1, y+2): 
    for xmod in range(x-1, x+2):
      neighbors += self.get_cell_status(Vector2(xmod, ymod)) << displacement
      displacement += 1
  return neighbors
  
func clear_frame_cache() -> void:
  if frame_cache: frame_cache = null
