
extends Node2D
var world

func _ready():	
	world = MapGEN.new()

class MapGEN:
	var height = 50
	var width = 100
	var _seed = '1469442477'
	var randomFeelPercent = 45
	var smooth = 5
	var map = []
	func _init():
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
	
	func turn(a):
		var ar = []
		var x = 0 
		while x < height: 
			var y = 0
			var tmp = []
			while y < width: 
				tmp.append(0)
				y+=1
			ar.append(tmp)
			x+=1
			
		var i = 0
		while i < height:
			var j = 0
			while j < width:
				ar[i][j] = a[j][i]
				j+=1
			i+=1
		var tmp = height
		height = width
		width = tmp
		return ar


class PriorityQueue:
    var queue
    func _init():
        queue = []
        pass

    func sort_priority(v1,v2):
        return v1[1] < v2[1]

    func empty():
        return queue.empty()

    func put(priority, vect):
        var pv = [[int(vect[0]),int(vect[1])],int(priority)]
        queue.append(pv)
        queue.sort_custom(self,"sort_priority")

    func get():
        var vect = queue[0][0]
        var pr = queue[0][1]
        queue.pop_front()
        return [pr,[vect[0],vect[1]]]

class mSet:
	var set
	var _hash_tbl
	func _init():
		set = []
		_hash_tbl = {}
	func add(v):
		if !_hash_tbl.has(v):
			_hash_tbl[v]=v
			set.append(v)

class FindPath_AStar:
	func heuristic(a, b):
		return pow((b[0] - a[0]), 2) + pow((b[1] - a[1]), 2)
	
	func _init():
		pass
		
	func astar(array, start, goal):
		var pq = PriorityQueue.new()
		var neighbors = [[0,1],[0,-1],[1,0],[-1,0],[1,1],[1,-1],[-1,1],[-1,-1]]
		var close_set = mSet.new()
		var came_from = {}
		var gscore = {start:0}
		var fscore = {start:heuristic(start, goal)}
		var oheap = []
		pq.put(fscore[start], start)
		while pq.queue!=[]:
			var current = pq.get()[1]
			if current == goal:
				var data = []
				while current in came_from:
					data.append(current)
					current = came_from[current]
				return data
				
			close_set.add(current)
			for ij in neighbors:
				var i = ij[0]
				var j = ij[1]
				var neighbor = [current[0] + i, current[1] + j]            
				var tentative_g_score = gscore[current] + heuristic(current, neighbor)
				if 0 <= neighbor[0] < array.size():
					if 0 <= neighbor[1] < array[0].size():                
						if array[neighbor[0]][neighbor[1]] == 1:
							continue
					else:
						continue
				else:
					continue
				var safe_gscore
				if gscore.has(neighbor):
					safe_gscore = gscore[neighbor] 
				else:
					safe_gscore = 0
				if neighbor in close_set.set and tentative_g_score >= safe_gscore:
					continue
				var v = []
				for ii in pq.queue:
					v.append(ii[1])
				if gscore.has(neighbor):
					safe_gscore = gscore[neighbor] 
				else:
					safe_gscore = 0
				if  tentative_g_score < safe_gscore or not(neighbor in v):
					came_from[neighbor] = current
					gscore[neighbor] = tentative_g_score
					fscore[neighbor] = tentative_g_score + heuristic(neighbor, goal)
					pq.put(fscore[neighbor], neighbor)        
		return false

							
func _draw():
	var colors = {1:Color(0,0,0), 0:Color(1,1,1),2:Color(0,1,0),3:Color(1,0,0),4:Color(0,0,1)}
	var SIZE_RECT = 10
	var i = 0 
	#map = turn(map)
	if  world._seed == '1469442477':
		world.map[20][20] = 2
		var fp = FindPath_AStar.new()
		var path = fp.astar(world.map, [20,20], [80,15])
		for coord in path:
			world.map[coord[0]][coord[1]]=4
		world.map[80][15] = 3
	while (i <  world.width): 
		var j = 0
		while (j < world.height): 	
			draw_rect(Rect2(Vector2(i*SIZE_RECT,j*SIZE_RECT),Vector2(SIZE_RECT,SIZE_RECT)),colors[world.map[i][j]])
			j+=1
		i+=1



