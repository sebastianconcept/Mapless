actions
runPrintingOn: aStream

	aStream cr; cr; nextPutAll: 'Benchmarking...'; cr; flush.

	(Delay forDuration: 1 second) wait. 
	self save1KPeopleOn: aStream.
	aStream flush.
	Smalltalk garbageCollect; garbageCollect.
	
	(Delay forDuration: 1 second) wait. 
	self save10KPeopleOn: aStream.
	aStream flush.
	Smalltalk garbageCollect; garbageCollect.

	(Delay forDuration: 1 second) wait. 
	self save1KUsersOn: aStream.
	aStream flush.
	Smalltalk garbageCollect; garbageCollect.

	(Delay forDuration: 1 second) wait. 
	self save10KUsersOn: aStream.
	aStream flush.	
	Smalltalk garbageCollect; garbageCollect.
