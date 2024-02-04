Class {
	#name : #MaplessRedisTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Redis-Tests'
}

{ #category : #'as yet unclassified' }
MaplessRedisTest class >> databaseIndex [
	"Out of the box, a Redis instance supports 16 logical databases. These databases are effectively siloed off from one another, and when you run a command in one database it doesn’t affect any of the data stored in other databases in your Redis instance.

Redis databases are numbered from 0 to 15 and, by default, you connect to database 0 when you connect to your Redis instance. However, you can change the database you’re using with the select command after you connect."

	^ 2
]

{ #category : #actions }
MaplessRedisTest >> basicNewRepository [
	^ MaplessRedisRepository
		for: self class databaseIndex
		with: MaplessRedisPool local
		using: MaplessTrivialResolver new
]

{ #category : #tests }
MaplessRedisTest >> newDummyPersonNamed: aString [
	^ DummyPerson new
		firstName: aString;
		yourself
]

{ #category : #actions }
MaplessRedisTest >> newRepository [
	| accessor |
	accessor := MaplessRedisPool local.
	accessor start.
	^ MaplessRedisRepository
		for: self class databaseIndex
		with: accessor
		using: MaplessTrivialResolver new
]

{ #category : #'setUp-tearDown' }
MaplessRedisTest >> setUp [
	super setUp.


]

{ #category : #'setUp-tearDown' }
MaplessRedisTest >> tearDown [
	super tearDown.
	repository
		ifNotNil: [ repository drop.
			repository accessor stop ]
]

{ #category : #tests }
MaplessRedisTest >> testAndGetInfo [
	| info |
	repository := self basicNewRepository.
	repository auth: 'my_password'.
	self
		shouldnt: [ info := repository accessor info ]
		raise: RsGenericError.
	self assert: info notNil
]

{ #category : #tests }
MaplessRedisTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	repository := self newRepository.
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	repository save: guy.
	repository save: user.
	self
		assert: (repository findOne: DummyPerson atId: guy id) firstName
		equals: 'john'.
	self
		assert: (repository findOne: DummyUser atId: user id) person class
		equals: MaplessReference.
	self
		assert: (repository findOne: DummyUser atId: user id) completeName
		equals: 'john q'.
	self
		assert: (repository findOne: DummyUser atId: user id) person model class
		equals: DummyPerson.
	self
		assert: (repository findOne: DummyUser atId: user id) person firstName
		equals: 'john'.
	self
		assert: (repository findOne: DummyUser atId: user id) person lastName
		equals: 'q'
]

{ #category : #tests }
MaplessRedisTest >> testComposedDelete [
	| users |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(DummyUser new
						userame: char asString;
						person:
							(DummyPerson new
								firstName: char asString;
								yourself);
						yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self assert: (users allSatisfy: [ :user | user isDeleted not ]).
	self
		assert: (users allSatisfy: [ :user | user person isDeleted not ]).
	users do: [ :user | repository delete: user person ].
	self assert: (users allSatisfy: [ :user | user person isDeleted ]).
	self assert: (users allSatisfy: [ :user | user isDeleted not ]).
	users do: [ :user | repository delete: user ].
	self assert: (users allSatisfy: [ :user | user person isDeleted ]).
	self assert: (users allSatisfy: [ :user | user isDeleted ])
]

{ #category : #tests }
MaplessRedisTest >> testComposedDestroy [
	| users |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(DummyUser new
						userame: char asString;
						person:
							(DummyPerson new
								firstName: char asString;
								yourself);
						yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	users do: [ :user | repository destroy: user person ].
	self
		assert:
			(users
				allSatisfy: [ :user | (repository existsId: user person id of: DummyPerson) not ]).
	self
		assert:
			(users
				allSatisfy: [ :user | repository existsId: user id of: DummyUser ]).
	users do: [ :user | repository destroy: user ].
	self
		assert:
			(users
				allSatisfy: [ :user | (repository existsId: user id of: DummyUser) not ])
]

{ #category : #tests }
MaplessRedisTest >> testComposedResaveAndLoad [
	| user guy loaded |
	repository := self newRepository.
	user := DummyUser new
		username: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'John';
		lastName: 'W';
		yourself.
	user person: guy.
	self should: [ repository save: user ] raise: MaplessUnsavedSubmodel.
	repository save: guy.
	self
		shouldnt: [ repository save: user ]
		raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded person firstName equals: 'John'.
	loaded person lastName: 'wayne'.
	repository save: loaded person.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded person lastName equals: 'wayne'.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded person firstName equals: 'John'.
	loaded person lastName: 'Wayne'.
	repository save: loaded person.
	loaded username: 'johnw'.
	repository save: loaded.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded username equals: 'johnw'.
	self assert: loaded person firstName equals: 'John'
]

{ #category : #tests }
MaplessRedisTest >> testComposedSave [
	| user guy |
	repository := self newRepository.
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.

	"Whithout saving a submodel"
	self should: [ repository save: user ] raise: MaplessUnsavedSubmodel.

	"After saving that submodel"
	repository save: guy.
	self
		shouldnt: [ repository save: user ]
		raise: MaplessUnsavedSubmodel
]

{ #category : #tests }
MaplessRedisTest >> testComposedSaveAndLoad [
	| user guy loaded |
	repository := self newRepository.
	user := DummyUser new
		createdOn: DateAndTime now;
		username: 'johnq';
		yourself.
	guy := DummyPerson new
		createdOn: DateAndTime now;
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.

	"Whithout saving a submodel"
	self should: [ repository save: user ] raise: MaplessUnsavedSubmodel.

	"After saving that submodel"
	repository save: guy.
	self
		shouldnt: [ repository save: user ]
		raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded notNil.
	self assert: loaded createdOn notNil.
	self assert: loaded modifiedOn notNil.
	loaded
		createdOn: nil;
		modifiedOn: nil.
	user
		createdOn: nil;
		modifiedOn: nil.
	loaded data
		keysAndValuesDo: [ :k :v | self assert: v equals: (user data at: k) ].
	self assert: loaded username = 'johnq'.
	self assert: loaded person firstName = 'john'.
	self assert: loaded person lastName = 'q'.
	self assert: loaded person maplessClassName = DummyPerson name.
	self assert: loaded person model class = DummyPerson
]

{ #category : #tests }
MaplessRedisTest >> testComposition [
	| user guy |
	repository := self newRepository.
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	self assert: (user data at: 'person') class equals: DummyPerson.
	self assert: (user data at: 'person') _c equals: #DummyPerson.
	self assert: user id isNil.
	self assert: (user data at: 'person') id isNil.
	self assert: user completeName equals: 'john q'
]

{ #category : #tests }
MaplessRedisTest >> testCountAll [

	| users count |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet do: [ :char | 
		users add: (DummyUser new
				 username: char asString;
				 person: (DummyPerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	count := repository count: DummyUser.
	self assert: count equals: 0.

	count := repository count: DummyPerson.
	self assert: count equals: 0.

	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	count := repository count: DummyUser.

	count := repository count: DummyUser.
	self assert: count equals: 26.

	count := repository count: DummyPerson.
	self assert: count equals: 26
]

{ #category : #tests }
MaplessRedisTest >> testCountSome [

	| users count |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet do: [ :char | 
		users add: (DummyUser new
				 username: char asString;
				 person: (DummyPerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	count := repository count: DummyUser where: 'id:123'.
	self assert: count equals: 0.

	count := repository count: DummyPerson where: 'id:123'.
	self assert: count equals: 0.

	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	count := repository count: DummyUser where: 'id:' , users first id.
	self assert: count equals: 1.

	count := repository
		         count: DummyPerson
		         where: 'id:' , users first person id.
	self assert: count equals: 1
]

{ #category : #tests }
MaplessRedisTest >> testDateAndTime [
	| when guy loaded |
	repository := self newRepository.
	when := DateAndTime now asUTC.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		createdOn: when;
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded createdOn asDate asString = when asDate asString.
	self assert: loaded createdOn asTime hour = when asTime hour.
	self assert: loaded createdOn asTime minutes = when asTime minutes.
	self assert: loaded createdOn asTime seconds = when asTime seconds
]

{ #category : #tests }
MaplessRedisTest >> testDelete [
	| people |
	repository := self newRepository.
	people := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			people
				add:
					(DummyPerson new
						firstName: char asString;
						yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository delete: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted ])
]

{ #category : #tests }
MaplessRedisTest >> testDestroy [
	| people |
	repository := self newRepository.
	people := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			people
				add:
					(DummyPerson new
						firstName: char asString;
						yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository destroy: guy ].
	self
		assert:
			(people
				allSatisfy: [ :guy | (repository existsId: guy id of: DummyPerson) not ])
]

{ #category : #tests }
MaplessRedisTest >> testFindAll [
	| users all |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(DummyUser new
						username: char asString;
						person:
							(DummyPerson new
								firstName: char asString;
								yourself);
						yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	all := repository findAll: DummyUser.
	self assert: users size equals: all size.
	self
		assert:
			(Character alphabet
				allSatisfy:
					[ :char | all anySatisfy: [ :user | user person firstName = char asString ] ])
]

{ #category : #tests }
MaplessRedisTest >> testFindOne [

	| users found |
	repository := self newRepository.
	users := OrderedCollection new.
	Character alphabet do: [ :char | 
		users add: (DummyUser new
				 username: char asString;
				 person: (DummyPerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].

	users do: [ :user | 
		found := repository findOne: DummyUser atId: user id.
		self assert: found isNil ].

	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].

	users do: [ :user | 
		found := repository findOne: DummyUser atId: user id.
		self assert: found id equals: user id.
		self assert: found username equals: user username.
		found := repository findOne: DummyPerson atId: user person id.
		self assert: found id equals: user person id.
		self assert: found firstName equals: user person firstName ]
]

{ #category : #tests }
MaplessRedisTest >> testIsUnsaved [
	| guy |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self assert: (repository isUnsaved: guy)
]

{ #category : #tests }
MaplessRedisTest >> testMultipleComposedComposables [
	| tags tagsOfTags tagsOfTagsOfTags loaded |
	repository := self newRepository.
	tags := OrderedCollection new.
	tagsOfTags := OrderedCollection new.
	tagsOfTagsOfTags := OrderedCollection new.
	tags
		add:
			(DummyTag new
				label: 'is this';
				yourself);
		add:
			(DummyTag new
				label: 'multiply';
				yourself);
		add:
			(DummyTag new
				label: 'composable?';
				yourself);
		yourself.
	tagsOfTags
		add:
			(DummyTag new
				label: 'like';
				yourself);
		add:
			(DummyTag new
				label: 'really?';
				yourself);
		yourself.
	tagsOfTagsOfTags
		add:
			(DummyTag new
				label: 'wow';
				yourself);
		add:
			(DummyTag new
				label: 'nice';
				yourself);
		yourself.
	tagsOfTagsOfTags do: [ :tag | repository save: tag ].
	tagsOfTags first tags: tagsOfTagsOfTags.
	tagsOfTags second tags: tagsOfTagsOfTags.
	self
		shouldnt: [ tagsOfTags do: [ :tag | repository save: tag ] ]
		raise: MaplessUnsavedSubmodel.
	tags first tags: tagsOfTags.
	tags second tags: tagsOfTags.
	tags third tags: tagsOfTags.
	self
		shouldnt: [ tags do: [ :e | repository save: e ] ]
		raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: DummyTag atId: tags first id.
	self assert: loaded notNil.
	self assert: loaded label = 'is this'.
	self assert: loaded tags isCollection.
	self assert: loaded tags notEmpty.
	self assert: loaded tags isCollection.
	self deny: loaded tags first tags isEmpty.
	self assert: loaded tags first label = 'like'.
	self assert: loaded tags second label = 'really?'.
	self assert: loaded tags size = 2.
	self deny: loaded tags first tags isEmpty.
	self assert: loaded tags first tags size = 2.
	self assert: loaded tags first tags first label = 'wow'.
	self assert: loaded tags first tags second label = 'nice'
]

{ #category : #tests }
MaplessRedisTest >> testMultipleComposedMixedSaveAndLoad [
	| guy loaded things |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	guy things: OrderedCollection new.
	guy things
		add:
			(DummyTag new
				label: 'cool';
				yourself);
		add:
			(DummyTag new
				label: 'stuff';
				yourself);
		add:
			(DummyUser new
				info: 'also this';
				yourself);
		yourself.
	things := guy things.
	guy things do: [ :each | repository save: each ].
	self shouldnt: [ repository save: guy ] raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded notNil.
	self assert: loaded firstName = 'john'.
	self assert: loaded things isCollection.
	self assert: loaded things notEmpty.
	loaded things
		do: [ :each | self assert: (things anySatisfy: [ :t | t id = each id ]) ].
	loaded unreferenced.
	self assert: loaded things first class = DummyTag.
	self assert: loaded things second class = DummyTag.
	self assert: loaded things third class = DummyUser
]

{ #category : #tests }
MaplessRedisTest >> testMultipleComposedSaveAndLoad [
	| user guy tags loaded |
	repository := self newRepository.
	user := DummyUser new
		username: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	tags := OrderedCollection new.
	tags
		add:
			(DummyTag new
				label: 'cool';
				yourself);
		add:
			(DummyTag new
				label: 'stuff';
				yourself);
		yourself.
	user
		person: guy;
		tags: tags;
		yourself.
	tags do: [ :tag | repository save: tag ].
	repository save: guy.
	self
		shouldnt: [ repository save: user ]
		raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: DummyUser atId: user id.
	self assert: loaded notNil.
	self assert: loaded username = 'johnq'.
	self assert: loaded tags isCollection.
	self assert: loaded tags notEmpty.
	self assert: loaded tags isCollection.
	loaded tags
		do: [ :tag | self assert: (tags anySatisfy: [ :t | t id = tag id ]) ]
]

{ #category : #tests }
MaplessRedisTest >> testRemovingExpire [
	| guy found howMuchWillItBeThere |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	found := repository findOne: DummyPerson atId: guy id.
	self assert: found notNil.
	repository expires: guy in: 900.
	howMuchWillItBeThere := repository ttlFor: guy.
	self assert: howMuchWillItBeThere > 0.
	repository removeExpireFor: guy.
	howMuchWillItBeThere := repository ttlFor: guy.
	self
		assert: (howMuchWillItBeThere = -1 or: [ howMuchWillItBeThere = -2 ]).
	100 milliSeconds wait.
	found := repository findOne: DummyPerson atId: guy id.
	self assert: found notNil.

]

{ #category : #tests }
MaplessRedisTest >> testSaveSetsID [
	| guy |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	repository save: guy.
	self assert: guy hasId
]

{ #category : #tests }
MaplessRedisTest >> testSetCurrentDatabase [
	repository := self newRepository.
	self shouldnt: [ repository setDatabase: 1 ] raise: Error
]

{ #category : #tests }
MaplessRedisTest >> testSimpleExpire [
	| guy found |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	found := repository findOne: DummyPerson atId: guy id.
	self assert: found notNil.
	repository expires: guy in: 50.
	60 milliSeconds wait.
	found := repository findOne: DummyPerson atId: guy id.
	self assert: found isNil.
		 
]

{ #category : #tests }
MaplessRedisTest >> testSimpleSave [
	| guy |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessRedisTest >> testSimpleSaveAndLoad [
	| guy loaded |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded notNil.
	loaded data
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessRedisTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded firstName equals: 'john'.
	self deny: loaded remember equals: 'this words'.
	loaded remember: 'this words'.
	repository save: loaded.
	reloaded := repository findOne: DummyPerson atId: guy id.
	self assert: reloaded remember = 'this words'
]

{ #category : #tests }
MaplessRedisTest >> testSimpleSaveWithAByteSymbol [
	| guy |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		value: #thisByteSymbol;
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessRedisTest >> testSubModelsFromReifiedJSON [
	| user guy jsonString reified |
	repository := self newRepository.
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	jsonString := user unreferenced asJSONString.
	reified := DummyUser fromJSONString: jsonString in: repository.
	self assert: reified person class equals: DummyPerson.
	self assert: reified completeName equals: 'john q'
]

{ #category : #tests }
MaplessRedisTest >> testUpdatingExpire [
	| guy found howMuchWillItBeThere newerTTL answer |
	repository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	found := repository findOne: DummyPerson atId: guy id.
	self assert: found notNil.
	repository expires: guy in: 900.
	30 milliSeconds wait.
	howMuchWillItBeThere := repository ttlFor: guy.
	self assert: howMuchWillItBeThere > 0.
	answer := repository expires: guy in: 2500.
	newerTTL := repository ttlFor: guy.
	self assert: newerTTL > 1200
]
