Class {
	#name : #MaplessMongoBenchmark,
	#superclass : #Object,
	#category : #'Mapless-Mongo-Tests'
}

{ #category : #actions }
MaplessMongoBenchmark class >> run [

	self runPrintingOn: Transcript 
]

{ #category : #actions }
MaplessMongoBenchmark class >> runPrintingOn: aStream [

	aStream cr;cr; nextPutAll: 'Benchmarking...'; cr; flush.

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

	| firstNames lastNames delay savesPerSecond guys readsPerSecond mongoRepository |

	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guys := OrderedCollection new.
	mongoRepository := MaplessMongoRepository on: (MongoPool instance databaseAt: 'flow').
	
	1 to: aQuantity do:[ :i |
		firstNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		lastNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		guys add: (DummyPerson new
					firstName: (firstNames at: i);
					lastName: (lastNames at: i);	
					yourself)].	

	mongoRepository do:[ 
		delay := Time millisecondsToRun: [
			1 to: aQuantity do:[ :i | 
				 (guys at: i) save]]].
	
	savesPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',savesPerSecond asString,' saves per second)';
		flush.
		
	mongoRepository do:[ 
		delay := Time millisecondsToRun: [
				guys do:[ :guy | 
					DummyUser findId: guy id]]].
	
	readsPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',readsPerSecond asString,' reads per second)';
		flush.	
]

{ #category : #actions }
MaplessMongoBenchmark class >> save: aQuantity usersOn: aStream [ 

	| guy user firstNames lastNames users delay savesPerSecond readsPerSecond mongoRepository |

	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	users := OrderedCollection new.
	mongoRepository := MaplessMongoRepository on: (MongoPool instance databaseAt: 'flow').
	
	
	1 to: aQuantity do:[ :i |
		firstNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		lastNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i | 
		guy := DummyPerson new
				firstName: (firstNames at: i);
				lastName: (lastNames at: i);
				yourself.
		user := DummyUser new
					username: guy firstName;
					person: guy;
					yourself.
		users add: user].

	mongoRepository do:[ 
		delay := Time millisecondsToRun: [
				users do:[ :usr | 
					usr person save.
					usr save]]].
	
	savesPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',savesPerSecond asString,' saves per second)';
		flush.
		
	mongoRepository do:[ 
		delay := Time millisecondsToRun: [
				users do:[ :usr | 
					user := DummyUser findId: usr id]]].
	
	readsPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
			
	aStream cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson and MaplessDummyUser in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',readsPerSecond asString,' reads per second)';
		flush	

]
