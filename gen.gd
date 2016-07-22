
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var height = 50
var width = 100
var _seed = ''
var randomFeelPercent = 45
var smooth = 5
var map = []

func _ready():	
	var x = 0 
	while x < width: 
		var y = 0
		var tmp = []
		while y < height: 
			tmp.append(0)
			y+=1
		map.append(tmp)
		x+=1
	GenerateMap()


func GenerateMap():
	RandomFeelMap()
	var i = 0 
	while i < smooth:
		SmoothMap()
		i+=1

func RandomFeelMap(): 
	if _seed == '': 
		randomize()
		_seed = str(OS.get_unix_time())
		seed(_seed.hash())
		print ('seed: ',_seed) 
	else:
		seed(_seed.hash())
		print ('seed: ',_seed) 
		
	var x = 0 
	while x < width: 
		var y = 0
		while y < height: 
			if ((x == 0) or (x == width - 2) or (y == 0) or (y == height - 1)):
				map[x][y] = 1
			else:
				var psevdoRandom = randi() % 100
				if psevdoRandom < randomFeelPercent:
					map[x][y]=1
				else:
					map[x][y]=0
			y+=1
		x+=1
		
func SmoothMap ():
	var x = 0 
	while (x < width):
		var y = 0
		while y < height:
			var neighbourWallTiles = GetSorroundWallCount(x, y)
			if (neighbourWallTiles > 4):
				map [x][y] = 1
			elif (neighbourWallTiles < 4):
				map [x][y] = 0 
			y+=1
		x+=1

func GetSorroundWallCount(gridX, gridY):
	var wallCount = 0
	var neighbourX = gridX - 1
	while neighbourX <= gridX + 1:
		var neighbourY = gridY - 1
		while neighbourY <= gridY + 1:
			if ((neighbourX >= 0) and (neighbourX < width) and (neighbourY >= 0) and (neighbourY < height)):
				if ((neighbourX != gridX) or (neighbourY != gridY)):
					wallCount += map[neighbourX][neighbourY]
			else:
				wallCount+=1
			neighbourY+=1
		neighbourX+=1
	return wallCount

					
func _draw():
	var colors = {1:Color(0,0,0), 0:Color(1,1,1)}
	var SIZE_RECT = 10
	var i = 0 
	while (i < width): 
		var j = 0
		while (j < height): 	
			draw_rect(Rect2(Vector2(i*SIZE_RECT,j*SIZE_RECT),Vector2(SIZE_RECT,SIZE_RECT)),colors[map[i][j]])
			j+=1
		i+=1



