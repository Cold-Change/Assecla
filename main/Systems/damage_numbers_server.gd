extends Node2D


var font := preload("res://Meta/zekton/zekton rg.otf")

class Fast:
	var position:Vector2
	var amount:String
	var lifetime:float
	var color:Color
	var size:int = 16

var fasts : Array[Fast] = []
func _ready() -> void:
	z_index =30
	scale = Vector2(0.5,0.5)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var deleted : Array[Fast] = []
	for i in fasts:
		i.lifetime -= 0.01
		#i.position.y -= 1
		#var pos_offset : Vector2
		draw_string_outline(font, i.position, i.amount, HORIZONTAL_ALIGNMENT_LEFT, -1, i.size, 8, Color(0,0,0,1))
		draw_string(font, i.position, i.amount, HORIZONTAL_ALIGNMENT_LEFT, -1, i.size, i.color)
		
		if i.lifetime <= 0:
			deleted.push_back(i)
	
	for i in deleted:
		fasts.erase(i)

func go(text:String, pos: Vector2) -> void:
	
	var nf := Fast.new()
	nf.amount = text
	nf.position = pos*2
	nf.lifetime = 1.1
	nf.size = 18
	nf.color = Color.WHITE
	
	#nf.color = Color.RED if damage.is_crit else Color.WHITE
	#nf.size = 20 if damage.is_crit else 10
	
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(nf, "position", nf.position+Vector2(randi_range(-30,30),randi_range(-64,-128)), 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(nf, "size", nf.size+20, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	fasts.append(nf)

func go_heal(amount:int, pos:Vector2) -> void:
	if amount == 0:
		return
	var nf := Fast.new()
	nf.amount = str(amount)
	nf.position = pos*2
	nf.lifetime = 1.1
	nf.color = Color.GREEN
	nf.size = 10
	
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(nf, "position", nf.position+Vector2(randi_range(-15,15),-30), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(nf, "size", nf.size+20, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	fasts.append(nf)
	
