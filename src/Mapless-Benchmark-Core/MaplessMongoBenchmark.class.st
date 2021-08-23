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
	#category : #'Mapless-Benchmark-Core-Mapless-Benchmark-Core'
}

{ #category : #actions }
MaplessMongoBenchmark class >> run [

	self runPrintingOn: Transcript 
]

{ #category : #actions }
MaplessMongoBenchmark class >> runPrintingOn: aStream [
	aStream
		cr;
		cr;
		nextPutAll: 'Benchmarking...';
		cr.
	self save1KPeopleOn: aStream.
	self save10KPeopleOn: aStream.
	self save1KUsersOn: aStream.
	self save10KUsersOn: aStream
]

{ #category : #actions }
MaplessMongoBenchmark class >> save10KPeopleOn: aStream [ 

	self save: 10000 peopleOn: aStream 
]

{ #category : #actions }
MaplessMongoBenchmark class >> save10KUsersOn: aStream [ 

	self save: 10000 usersOn: aStream 
]

{ #category : #actions }
MaplessMongoBenchmark class >> save1KPeopleOn: aStream [ 

	self save: 1000 peopleOn: aStream 
]

{ #category : #actions }
MaplessMongoBenchmark class >> save1KUsersOn: aStream [ 

	self save: 1000 usersOn: aStream 
]

{ #category : #actions }
MaplessMongoBenchmark class >> save: aQuantity peopleOn: aStream [
	| firstNames lastNames delay savesPerSecond guysIds readsPerSecond mongoRepository |
	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guysIds := OrderedCollection new.
	mongoRepository := MaplessMongoRepository for: 'Mapless-Tests'.
	delay := Time
		millisecondsToRun: [ mongoRepository
				do: [ 1 to: aQuantity do: [ :i | 
						| guy |
						guy := DummyPerson new
							firstName: Character alphabet shuffled anyOne asString;
							lastName: Character alphabet shuffled anyOne asString;
							yourself.
						guy save.
						guysIds add: guy id ] ] ].
	savesPerSecond := (1000 * aQuantity / delay asFloat) truncated.
	aStream
		cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , savesPerSecond asString , ' saves per second)';
		flush.
	mongoRepository
		do: [ delay := Time
				millisecondsToRun: [ guysIds do: [ :guyId | DummyPerson findId: guyId ] ] ].
	readsPerSecond := (1000 * aQuantity / delay asFloat) truncated.
	aStream
		cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , readsPerSecond asString , ' reads per second)';
		flush
]

{ #category : #actions }
MaplessMongoBenchmark class >> save: aQuantity usersOn: aStream [
	| guy user userIds delay savesPerSecond readsPerSecond mongoRepository |
	userIds := OrderedCollection new.
	mongoRepository := MaplessMongoRepository for: 'Mapless-Tests'.
	delay := Time
		millisecondsToRun: [ mongoRepository
				do: [ 1 to: aQuantity do: [ :i | 
						guy := DummyPerson new
							firstName: Character alphabet shuffled anyOne asString;
							lastName: Character alphabet shuffled anyOne asString;
							yourself.
						user := DummyUser new
							username: guy firstName;
							person: guy;
							yourself.
						user person save.
						user save.
						userIds add: user id ] ] ].
	savesPerSecond := (1000 * aQuantity / delay asFloat) truncated.
	aStream
		cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , savesPerSecond asString , ' saves per second)';
		flush.
	mongoRepository
		do: [ delay := Time
				millisecondsToRun: [ userIds do: [ :userId | user := DummyUser findId: userId ] ] ].
	readsPerSecond := (1000 * aQuantity / delay asFloat) truncated.
	aStream
		cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~' , readsPerSecond asString , ' reads per second)';
		flush
]
