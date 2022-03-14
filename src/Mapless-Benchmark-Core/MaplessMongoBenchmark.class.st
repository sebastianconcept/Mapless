"
This class provides some basic performance test for Mapless on MongoDB.

Convenience to run it logging to the Transcript:

MaplessMongoBenchmark run

Convenience to run it logging to SomeLogFile.log:

'SomeLogFile.log' asFileReference writeStreamDo: [ :stream |
	MaplessMongoBenchmark runPrintingOn: stream ]  
"
Class {
	#name : #MaplessMongoBenchmark,
	#superclass : #Object,
	#category : #'Mapless-Benchmark-Core'
}

{ #category : #actions }
MaplessMongoBenchmark class >> runOn: aMaplessRepository [
	self runOn: aMaplessRepository printingOn: Stdio stdout
]

{ #category : #actions }
MaplessMongoBenchmark class >> runOn: aMaplessRepository printingOn: aStream [
	aStream
		lf;
		cr;
		lf;
		cr;
		nextPutAll: 'Benchmarking Mapless on MongoDB...';
		lf;
		cr.
	self save1KPeopleOn: aMaplessRepository printingOn: aStream.
	self save10KPeopleOn: aMaplessRepository printingOn: aStream.
	self save1KUsersOn: aMaplessRepository printingOn: aStream.
	self save10KUsersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> runOnLocalMongoDBReplicaSet [
	self
		runOn:
			(MaplessMongoRepository
				for: 'Mapless-Test'
				with: MaplessMongoReplicaSetPool test)
]

{ #category : #actions }
MaplessMongoBenchmark class >> runOnLocalStandaloneMongoDB [
	self
		runOn:
			(MaplessMongoRepository
				for: 'Mapless-Test'
				with: MaplessStandaloneMongoPool local)
]

{ #category : #actions }
MaplessMongoBenchmark class >> save10KPeopleOn: aMaplessRepository printingOn: aStream [
	self save: 10000 peopleOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save10KUsersOn: aMaplessRepository printingOn: aStream [
	self save: 10000 usersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save1KPeopleOn: aMaplessRepository printingOn: aStream [
	self save: 1000 peopleOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save1KUsersOn: aStream [
	self save: 1000 usersOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save1KUsersOn: aMaplessRepository printingOn: aStream [
	self save: 1000 usersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save: aQuantity peopleOn: aMaplessRepository printingOn: aStream [
	| firstNames lastNames delay savesPerSecond guysIds readsPerSecond totalDelay guy |
	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guysIds := OrderedCollection new.
	totalDelay := 0.
	aMaplessRepository
		readWriteDo: [ 1 to: aQuantity do: [ :i | 
				guy := DummyPerson new
					firstName: Character alphabet shuffled anyOne asString;
					lastName: Character alphabet shuffled anyOne asString;
					yourself.
				delay := Time microsecondsToRun: [ guy save ].
				totalDelay := totalDelay + delay.
				guysIds add: guy id ] ].
	savesPerSecond := (1000000 * aQuantity / totalDelay asFloat) rounded.
	aStream
		lf;
		cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: (totalDelay / 1000) asFloat rounded asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , savesPerSecond asString , ' saves per second)';
		flush.
	totalDelay := 0.
	aMaplessRepository
		readOnlyDo: [ guysIds
				do: [ :guyId | 
					delay := Time microsecondsToRun: [ guy := DummyPerson findId: guyId ].
					totalDelay := totalDelay + delay ] ].
	readsPerSecond := (1000000 * aQuantity / totalDelay asFloat) truncated.
	aStream
		lf;
		cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: (totalDelay / 1000) asFloat rounded asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , readsPerSecond asString , ' reads per second)';
		flush
]

{ #category : #actions }
MaplessMongoBenchmark class >> save: aQuantity usersOn: aMaplessRepository printingOn: aStream [
	| guy user userIds delay savesPerSecond readsPerSecond totalDelay |
	userIds := OrderedCollection new.
	totalDelay := 0.
	aMaplessRepository
		readWriteDo: [ 1 to: aQuantity do: [ :i | 
				guy := DummyPerson new
					firstName: Character alphabet shuffled anyOne asString;
					lastName: Character alphabet shuffled anyOne asString;
					yourself.
				user := DummyUser new
					username: guy firstName;
					person: guy;
					yourself.
				delay := Time
					microsecondsToRun: [ user person save.
						user save ].
				totalDelay := totalDelay + delay.
				userIds add: user id ] ].
	savesPerSecond := (1000000 * aQuantity / totalDelay asFloat)
		truncated.
	aStream
		lf;
		cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: (totalDelay / 1000) asFloat rounded asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , savesPerSecond asString , ' saves per second)';
		flush.
	totalDelay := 0.
	aMaplessRepository
		readOnlyDo: [ userIds
				do: [ :userId | 
					delay := Time microsecondsToRun: [ user := DummyUser findId: userId ].
					totalDelay := totalDelay + delay ] ].
	readsPerSecond := (1000 * aQuantity / delay asFloat) truncated.
	aStream
		lf;
		cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: (totalDelay / 1000) asFloat rounded asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , readsPerSecond asString , ' reads per second)';
		flush
]
