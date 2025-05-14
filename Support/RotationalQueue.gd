class_name RotationalQueue

var _data: Array[House]

func append(house: House):
	_data.push_back(house)

func remove(house: House):
	for i in len(_data):
		if _data[i] == house:
			_data.remove_at(i)
			return

func next() -> House:
	var turn = _data.pop_front()
	_data.push_back(turn)
	return turn

func peek(n: int) -> Array[House]:
	var l = _data.size()
	if l == 0 or n == 0:
		return []
		
	# peek considers case when queue has less elements than requested.
	# In this case it will just rotate element as it would occur in next method .
	var array: Array[House] = []
	for ni in range(n):
		var di = ni % l
		array.append(_data.get(di))
	return array
