"
This class provides some basic performance test for Mapless on UnQLite.

Convenience to run it logging to the terminal:

dbFilename := FileSystem workingDirectory / 'Mapless-Tests.db'.
repository := MaplessUnQLiteRepository for: dbFilename pathString.
MaplessUnQLiteBenchmark runOn: repository.

Convenience to run it logging to SomeLogFile.log:

'SomeLogFile.log' asFileReference writeStreamDo: [ :stream |
	MaplessUnQLiteBenchmark runOn: repository printingOn: stream ]  
"
Class {
	#name : #MaplessUnQLiteBenchmark,
	#superclass : #Object,
	#category : #'Mapless-Benchmark-Core'
}

{ #category : #actions }
MaplessUnQLiteBenchmark class >> runOn: aMaplessRepository [
	self save: 1 peopleOn: aMaplessRepository printingOn: NullStream new.
	self runOn: aMaplessRepository printingOn: Stdio stdout
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> runOn: aMaplessRepository printingOn: aStream [
	aStream
		lf;
		cr;
		lf;
		cr;
		nextPutAll: 'Benchmarking Mapless on UnQLite...';
		lf;
		cr.
	self save1KPeopleOn: aMaplessRepository printingOn: aStream.
	self save10KPeopleOn: aMaplessRepository printingOn: aStream.
	self save1KUsersOn: aMaplessRepository printingOn: aStream.
	self save10KUsersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save10KPeopleOn: aMaplessRepository printingOn: aStream [
	self save: 10000 peopleOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save10KUsersOn: aMaplessRepository printingOn: aStream [
	self save: 10000 usersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save1KPeopleOn: aMaplessRepository printingOn: aStream [
	self save: 1000 peopleOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save1KUsersOn: aStream [
	self save: 1000 usersOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save1KUsersOn: aMaplessRepository printingOn: aStream [
	self save: 1000 usersOn: aMaplessRepository printingOn: aStream
]

{ #category : #actions }
MaplessUnQLiteBenchmark class >> save: aQuantity peopleOn: aMaplessRepository printingOn: aStream [
	| firstNames lastNames delay savesPerSecond guysIds readsPerSecond guy totalDelay |
	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guysIds := OrderedCollection new.
	totalDelay := 0.
	1 to: aQuantity do: [ :i | 
		guy := DummyPerson new
			firstName: Character alphabet shuffled anyOne asString;
			lastName: Character alphabet shuffled anyOne asString;
			yourself.
		delay := Time
			microsecondsToRun: [ aMaplessRepository save: guy.
				guysIds add: guy id ].
		totalDelay := totalDelay + delay ].
	savesPerSecond := (1000000 * aQuantity / totalDelay asFloat)
		truncated.
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
	guysIds
		do: [ :guyId | 
			delay := Time
				microsecondsToRun: [ guy := aMaplessRepository findOne: DummyPerson atId: guyId ].
			totalDelay := totalDelay + delay ].
	readsPerSecond := (1000000 * aQuantity / totalDelay asFloat)
		truncated.
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
MaplessUnQLiteBenchmark class >> save: aQuantity usersOn: aMaplessRepository printingOn: aStream [
	| guy user userIds delay savesPerSecond readsPerSecond totalDelay |
	userIds := OrderedCollection new.
	totalDelay := 0.
	1 to: aQuantity do: [ :i | 
		guy := DummyPerson new
			firstName: Character alphabet shuffled anyOne asString;
			lastName: Character alphabet shuffled anyOne asString;
			yourself.
		user := DummyUser new
			username: guy firstName;
			person: guy;
			yourself.
		delay := Time
			microsecondsToRun: [ aMaplessRepository save: user person.
				aMaplessRepository save: user ].
		totalDelay := totalDelay + delay.
		userIds add: user id ].
	savesPerSecond := (1000000 * aQuantity / totalDelay asFloat) truncated.
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
	userIds
		do: [ :userId | 
			delay := Time
				microsecondsToRun: [ user := aMaplessRepository findOne: DummyUser atId: userId ].
			totalDelay := totalDelay + delay ].
	readsPerSecond := (1000000 * aQuantity / totalDelay asFloat) truncated.
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
