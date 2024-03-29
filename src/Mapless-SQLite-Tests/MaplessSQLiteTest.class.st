Class {
	#name : #MaplessSQLiteTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-SQLite-Tests'
}

{ #category : #history }
MaplessSQLiteTest class >> lastStoredRun [
	^ Dictionary new
		add:
			#passed
				->
					(Set new
						add: #testDefaultCategoryCleanUp;
						add: #testPackageCleanUp;
						add: #testSingleClassCreation;
						add: #testClassCreationInDifferentCategories;
						add: #testClassFastCreationInDifferentCategories;
						add: #testMultipleClassCreation;
						add: #testSingleClassFastCreation;
						yourself);
		add: #timeStamp -> '22 November 2008 10:11:35 pm';
		add: #failures -> Set new;
		add: #errors -> Set new;
		yourself
]

{ #category : #history }
MaplessSQLiteTest class >> maplessClasses [
	^ {SamplePerson.
	SampleUser.
	SampleTag}
]

{ #category : #accessing }
MaplessSQLiteTest class >> testDatabasePathString [

	^ (Smalltalk imageDirectory / 'MaplessSQLiteTest.db') pathString
]

{ #category : #actions }
MaplessSQLiteTest >> resetDatabase [
	"Remove all objects so the database is clean for any test to be run."

	self class maplessClasses
		do: [ :each | 
			(repository hasTableFor: each)
				ifTrue: [ repository destroyAll: each ]
				ifFalse: [ repository ensureTableFor: each ] ]
]

{ #category : #actions }
MaplessSQLiteTest >> savePersonNamed: aString [
	repository
		save:
			(SamplePerson new
				firstName: aString;
				yourself)
]

{ #category : #'setUp-tearDown' }
MaplessSQLiteTest >> setUp [

	super setUp.
	repository := MaplessSQLiteRepository
		              for: 'Mapless-Tests'
		              on: self class testDatabasePathString.
	repository ensureDatabase.
	self resetDatabase
]

{ #category : #'setUp-tearDown' }
MaplessSQLiteTest >> tearDown [
	super tearDown.
	repository ifNotNil: [ repository shutDown ].
	repository := nil
]

{ #category : #tests }
MaplessSQLiteTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	user := SampleUser new
		userame: 'johnq';
		yourself.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	repository save: guy.
	repository save: user.
	self
		assert: (repository findOne: SampleUser atId: user id) completeName
		equals: 'john q'.
	self
		assert: (repository findOne: SampleUser atId: user id) person class
		equals: MaplessReference.
	self
		assert: (repository findOne: SampleUser atId: user id) person model class
		equals: SamplePerson.
	self
		assert: (repository findOne: SampleUser atId: user id) person firstName
		equals: 'john'.
	self
		assert: (repository findOne: SampleUser atId: user id) person lastName
		equals: 'q'
]

{ #category : #tests }
MaplessSQLiteTest >> testComposedDelete [
	| users |
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(SampleUser new
						userame: char asString;
						person:
							(SamplePerson new
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
MaplessSQLiteTest >> testComposedDestroy [
	| users |
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(SampleUser new
						userame: char asString;
						person:
							(SamplePerson new
								firstName: char asString;
								yourself);
						yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self
		assert:
			(users
				allSatisfy:
					[ :user | (repository findOne: SamplePerson atId: user person id) notNil ]).
	users do: [ :user | repository destroy: user person ].
	self
		assert:
			(users
				allSatisfy:
					[ :user | (repository findOne: SamplePerson atId: user person id) isNil ]).
	self
		assert:
			(users
				allSatisfy: [ :user | (repository findOne: SampleUser atId: user id) notNil ]).
	users do: [ :user | repository destroy: user ].
	self
		assert:
			(users
				allSatisfy: [ :user | (repository findOne: SampleUser atId: user id) isNil ])
]

{ #category : #tests }
MaplessSQLiteTest >> testComposedSave [
	| user guy |
	user := SampleUser new
		userame: 'johnq';
		yourself.
	guy := SamplePerson new
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
MaplessSQLiteTest >> testComposedSaveAndLoad [
	| user guy loaded when |
	when := DateAndTime now asUTC.
	user := SampleUser new
		createdOn: when;
		username: 'johnq';
		yourself.
	guy := SamplePerson new
		createdOn: when;
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
	loaded := repository findOne: SampleUser atId: user id.
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
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded maplessData at: k) = (user maplessData at: k) ] ].
	self assert: loaded username = 'johnq'.
	self assert: loaded person firstName = 'john'.
	self assert: loaded person lastName = 'q'.
	self assert: loaded person maplessClassName = #SamplePerson.
	self assert: loaded person model class = SamplePerson
]

{ #category : #tests }
MaplessSQLiteTest >> testComposition [
	| user guy |
	user := SampleUser new
		userame: 'johnq';
		yourself.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	self
		assert: (user maplessData at: 'person') class
		equals: SamplePerson.
	self assert: user id isNil.
	self assert: (user maplessData at: 'person') id isNil.
	self assert: user completeName equals: 'john q'
]

{ #category : #tests }
MaplessSQLiteTest >> testConditionalCount [

	| users firstNames sqlCondition |
	users := OrderedCollection new.
	Character alphabet do: [ :char | 
		users add: (SampleUser new
				 username: char asString;
				 person: (SamplePerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	firstNames := { 'John'. 'Peter'. 'Alice'. 'Linda' }.
	firstNames do: [ :firstName | self savePersonNamed: firstName ].
	sqlCondition := 'json_extract(maplessData, ''$.firstName'') IN ({1})' 
		                format:
			                { (firstNames asJSONString allButFirst allButLast
				                 replaceAll: $"
				                 with: $') }.
	self
		assert: (repository count: SamplePerson where: sqlCondition)
		equals: firstNames size
]

{ #category : #tests }
MaplessSQLiteTest >> testCount [
	| users |
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(SampleUser new
						username: char asString;
						person:
							(SamplePerson new
								firstName: char asString;
								yourself);
						yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self
		assert: (repository count: SampleUser)
		equals: Character alphabet size
]

{ #category : #tests }
MaplessSQLiteTest >> testDelete [
	| people |
	people := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			people
				add:
					(SamplePerson new
						firstName: char asString;
						yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository delete: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted ])
]

{ #category : #tests }
MaplessSQLiteTest >> testDestroy [
	| people |
	people := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			people
				add:
					(SamplePerson new
						firstName: char asString;
						yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository destroy: guy ].
	self
		assert:
			(people
				allSatisfy: [ :guy | (repository findOne: SamplePerson atId: guy id) isNil ])
]

{ #category : #tests }
MaplessSQLiteTest >> testDisconnect [

	repository withClientDo: [ :client |
		self assert: client isValid.
		client close.
		self deny: client isValid ].

	repository withClientDo: [ :client |
		self assert: client getTableNames notEmpty ]
]

{ #category : #tests }
MaplessSQLiteTest >> testExists [
	| guy loaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (repository existsId: guy id of: SamplePerson)
]

{ #category : #tests }
MaplessSQLiteTest >> testIsUnsaved [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	self assert: (repository isUnsaved: guy).
	repository save: guy.
	self assert: guy hasId.
	self deny: (repository isUnsaved: guy)
]

{ #category : #tests }
MaplessSQLiteTest >> testMultipleComposedComposables [
	| tags tagsOfTags tagsOfTagsOfTags loaded |
	tags := OrderedCollection new.
	tagsOfTags := OrderedCollection new.
	tagsOfTagsOfTags := OrderedCollection new.
	tags
		add:
			(SampleTag new
				label: 'is this';
				yourself);
		add:
			(SampleTag new
				label: 'multiply';
				yourself);
		add:
			(SampleTag new
				label: 'composable?';
				yourself);
		yourself.
	tagsOfTags
		add:
			(SampleTag new
				label: 'like';
				yourself);
		add:
			(SampleTag new
				label: 'really?';
				yourself);
		yourself.
	tagsOfTagsOfTags
		add:
			(SampleTag new
				label: 'wow';
				yourself);
		add:
			(SampleTag new
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
	loaded := repository findOne: SampleTag atId: tags first id.
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
MaplessSQLiteTest >> testMultipleComposedMixedSaveAndLoad [
	| guy things loaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	guy things: OrderedCollection new.
	guy things
		add:
			(SampleTag new
				label: 'cool';
				yourself);
		add:
			(SampleTag new
				label: 'stuff';
				yourself);
		add:
			(SampleUser new
				info: 'also this';
				yourself);
		yourself.
	things := guy things.
	guy things do: [ :each | repository save: each ].
	self shouldnt: [ repository save: guy ] raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: SamplePerson atId: guy id.
	self assert: loaded notNil.
	self assert: loaded firstName = 'john'.
	self assert: loaded things isCollection.
	self assert: loaded things notEmpty.
	loaded things
		do: [ :each | self assert: (things anySatisfy: [ :t | t id = each id ]) ].
	loaded unreferenced.
	self assert: loaded things first class = SampleTag.
	self assert: loaded things second class = SampleTag.
	self assert: loaded things third class = SampleUser
]

{ #category : #tests }
MaplessSQLiteTest >> testMultipleComposedSaveAndLoad [
	| user guy tags loaded |
	user := SampleUser new
		username: 'johnq';
		yourself.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	tags := OrderedCollection new.
	tags
		add:
			(SampleTag new
				label: 'cool';
				yourself);
		add:
			(SampleTag new
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
	loaded := repository findOne: SampleUser atId: user id.
	self assert: loaded notNil.
	self assert: loaded username = 'johnq'.
	self assert: loaded tags isCollection.
	self assert: loaded tags notEmpty.
	self assert: loaded tags isCollection.
	loaded tags
		do: [ :tag | self assert: (tags anySatisfy: [ :t | t id = tag id ]) ]
]

{ #category : #tests }
MaplessSQLiteTest >> testQueryUsers [

	| users |
	users := OrderedCollection new.
	Character alphabet do: [ :char | 
		users add: (SampleUser new
				 username: char asString;
				 person: (SamplePerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self assert: (Character alphabet allSatisfy: [ :char | 
			 (repository
				  findOne: SampleUser
				  where: ('json_extract(maplessData,"$.username") = {1}' format:
						   { char asString printString })) notNil ])
]

{ #category : #tests }
MaplessSQLiteTest >> testRemoveClient [

	repository withClientDo: [ :client |
		repository accessor remove: client ].

	repository withClientDo: [ :client |
		self assert: client getTableNames notEmpty ]
]

{ #category : #tests }
MaplessSQLiteTest >> testSaveSetsID [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	repository save: guy.
	self assert: (guy maplessData at: 'id') notNil.
	self assert: guy hasId
]

{ #category : #tests }
MaplessSQLiteTest >> testSimpleSave [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessSQLiteTest >> testSimpleSaveAndLoad [
	| guy loaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: SamplePerson atId: guy id.
	self assert: loaded notNil.
	loaded modifiedOn: nil.
	guy modifiedOn: nil.
	loaded maplessData
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessSQLiteTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: SamplePerson atId: guy id.
	self assert: loaded firstName = 'john'.
	self deny: loaded remember = 'this words'.
	loaded firstName: loaded firstName capitalized.
	loaded remember: 'this words'.
	repository save: loaded.
	reloaded := repository findOne: SamplePerson atId: guy id.
	self assert: reloaded remember = 'this words'
]

{ #category : #tests }
MaplessSQLiteTest >> testSubModelsFromReifiedJSON [
	| user guy jsonString reified loaded |
	user := SampleUser new
		userame: 'johnq';
		yourself.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	repository save: guy.
	repository save: user.
	loaded := repository findOne: SampleUser atId: user id.
	jsonString := loaded unreferenced asJSONString.
	reified := SampleUser fromJSONString: jsonString in: repository.
	self assert: reified person class equals: SamplePerson.
	self assert: reified completeName equals: 'john q'
]

{ #category : #tests }
MaplessSQLiteTest >> testTruncate [

	| people |
	people := OrderedCollection new.
	Character alphabet do: [ :char | 
		people add: (SamplePerson new
				 firstName: char asString;
				 yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	self assert: (repository count: SamplePerson) equals: 26.
	repository withClientDo: [ :client | client truncateMapless: SamplePerson ].
	self assert: (repository count: SamplePerson) equals: 0.
	
]
