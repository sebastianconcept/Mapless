actions
fromJSONObjects: someJsonObjects

	^ someJsonObjects collect:[:e|
		self fromJSONObject: e]