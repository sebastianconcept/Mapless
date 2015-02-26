actions
printOn: aStream

	super printOn: aStream.
	
	aStream 
		nextPutAll: '(',self busyClients size asString,' busy, ',self idleClients size asString, ' idle)'