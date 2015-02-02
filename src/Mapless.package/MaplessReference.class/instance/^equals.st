accessing
= anObject

	^ super = anObject or:[
	self oid = anObject oid and:[
	self modelClass = anObject modelClass ] ]