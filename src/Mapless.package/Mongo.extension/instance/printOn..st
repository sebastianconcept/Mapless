*Mapless-Mongo
printOn: aStream
	aStream
		nextPutAll: self class name,' (';
		nextPutAll: host asString;
		nextPut: $:;
		nextPutAll: port asString;
		nextPut: $)