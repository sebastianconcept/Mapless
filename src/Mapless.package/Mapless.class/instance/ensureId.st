actions
ensureId 

	self id isNil ifTrue:[
		self id: self class makeId].