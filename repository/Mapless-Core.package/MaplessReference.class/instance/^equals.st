accessing
= anObject

	^ super = anObject or:[
	self id = anObject id and:[
	self modelClass = anObject modelClass ] ]