extends Object

var transition_dict = {}


func register_transitions(from: int, to: int, number_of_alive: int, subject: Array = []):
  var count: int = subject.size()
  var new_subjects_list = []
  if count < number_of_alive:
    for new_bit_position in range(0, 9):
      # On réserve la position pour le status de la case en cours
      if new_bit_position == 4: continue
      
      # On élimine les positions déjà occupées
      if count != 0 && subject[count - 1] >= new_bit_position: continue
        
      var new_subject = subject.duplicate()
      new_subject.append(new_bit_position)
      register_transitions(from, to, number_of_alive, new_subject)
    return new_subjects_list
  else:
    var identifier: int = from << 4
    for bit_position in subject:
      identifier += 1 << bit_position
    transition_dict[identifier] = to

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
  register_transitions(0, 1, 3)
  for i in [0, 1, 4, 5, 6, 7, 8]:
    register_transitions(1, 0, i)

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func transition_to(transition_identifier: int) -> int:
  return transition_dict.get(transition_identifier)
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
