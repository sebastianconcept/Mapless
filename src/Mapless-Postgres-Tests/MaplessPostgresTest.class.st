Class {
	#name : #MaplessPostgresTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Postgres-Tests-Tests'
}

{ #category : #history }
MaplessPostgresTest class >> lastStoredRun [
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
MaplessPostgresTest class >> maplessClasses [
	^ {DummyPerson.
	DummyUser.
	DummyTag}
]

{ #category : #actions }
MaplessPostgresTest >> resetDatabase [
	"Remove all objects so the database is clean for any test to be run."

	self class maplessClasses
		do: [ :each | 
			(repository hasTableFor: each)
				ifTrue: [ repository destroyAll: each ]
				ifFalse: [ repository ensureTableFor: each ] ]
]

{ #category : #actions }
MaplessPostgresTest >> savePersonNamed: aString [
	repository
		save:
			(DummyPerson new
				firstName: aString;
				yourself)
]

{ #category : #'setUp-tearDown' }
MaplessPostgresTest >> setUp [
	super setUp.
	repository := MaplessPostgresRepository
		for: 'Mapless-Tests'
		with: MaplessStandalonePostgresPool local.
	repository ensureDatabase.
	self resetDatabase
]

{ #category : #'setUp-tearDown' }
MaplessPostgresTest >> tearDown [
	super tearDown.
	repository ifNotNil: [ repository shutDown ].
	repository := nil
]

{ #category : #tests }
MaplessPostgresTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
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
		assert: (repository findOne: DummyUser atId: user id) completeName
		equals: 'john q'.
	self
		assert: (repository findOne: DummyUser atId: user id) person class
		equals: MaplessReference.
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
MaplessPostgresTest >> testComposedDelete [
	| users |
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
MaplessPostgresTest >> testComposedDestroy [
	| users |
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
	self
		assert:
			(users
				allSatisfy:
					[ :user | (repository findOne: DummyPerson atId: user person id) notNil ]).
	users do: [ :user | repository destroy: user person ].
	self
		assert:
			(users
				allSatisfy:
					[ :user | (repository findOne: DummyPerson atId: user person id) isNil ]).
	self
		assert:
			(users
				allSatisfy: [ :user | (repository findOne: DummyUser atId: user id) notNil ]).
	users do: [ :user | repository destroy: user ].
	self
		assert:
			(users
				allSatisfy: [ :user | (repository findOne: DummyUser atId: user id) isNil ])
]

{ #category : #tests }
MaplessPostgresTest >> testComposedSave [
	| user guy |
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
MaplessPostgresTest >> testComposedSaveAndLoad [
	| user guy loaded when |
	when := DateAndTime now asUTC.
	user := DummyUser new
		createdOn: when;
		username: 'johnq';
		yourself.
	guy := DummyPerson new
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
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded maplessData at: k) = (user maplessData at: k) ] ].
	self assert: loaded username = 'johnq'.
	self assert: loaded person firstName = 'john'.
	self assert: loaded person lastName = 'q'.
	self assert: loaded person maplessClassName = #DummyPerson.
	self assert: loaded person model class = DummyPerson
]

{ #category : #tests }
MaplessPostgresTest >> testComposition [
	| user guy |
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	self
		assert: (user maplessData at: 'person') class
		equals: DummyPerson.
	self assert: user id isNil.
	self assert: (user maplessData at: 'person') id isNil.
	self assert: user completeName equals: 'john q'
]

{ #category : #tests }
MaplessPostgresTest >> testConditionalCount [
	| users firstNames sqlCondition |
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
	firstNames := {'John' . 'Peter' . 'Alice' . 'Linda'}.
	firstNames do: [ :firstName | self savePersonNamed: firstName ].
	sqlCondition := '{1}->>''{2}'' IN ({3})'
		format:
			{'maplessData'.
			'firstName'.
			firstNames asJSONString allButFirst allButLast replaceAll: $" with: $'}.
	self
		assert: (repository count: DummyPerson where: sqlCondition)
		equals: firstNames size
]

{ #category : #tests }
MaplessPostgresTest >> testCount [
	| users |
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
	self
		assert: (repository count: DummyUser)
		equals: Character alphabet size
]

{ #category : #tests }
MaplessPostgresTest >> testDelete [
	| people |
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
MaplessPostgresTest >> testDestroy [
	| people |
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
				allSatisfy: [ :guy | (repository findOne: DummyPerson atId: guy id) isNil ])
]

{ #category : #tests }
MaplessPostgresTest >> testIsUnsaved [
	| guy |
	guy := DummyPerson new
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
MaplessPostgresTest >> testMultipleComposedComposables [
	| tags tagsOfTags tagsOfTagsOfTags loaded |
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
MaplessPostgresTest >> testMultipleComposedMixedSaveAndLoad [
	| guy things loaded |
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
MaplessPostgresTest >> testMultipleComposedSaveAndLoad [
	| user guy tags loaded |
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
MaplessPostgresTest >> testQueryUsers [
	| users |
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
	self
		assert:
			(Character alphabet
				allSatisfy: [ :char | 
					(repository
						findOne: DummyUser
						where:
							('maplessData->>''{1}'' = ''{2}'''
								format:
									{'username'.
									char asString})) notNil ])
]

{ #category : #tests }
MaplessPostgresTest >> testSaveSetsID [
	| guy |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	repository save: guy.
	self assert: (guy maplessData at: 'id') notNil.
	self assert: guy hasId
]

{ #category : #tests }
MaplessPostgresTest >> testSimpleSave [
	| guy |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessPostgresTest >> testSimpleSaveAndLoad [
	| guy loaded |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded notNil.
	loaded modifiedOn: nil.
	guy modifiedOn: nil.
	loaded maplessData
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded firstName = 'john'.
	self deny: loaded remember = 'this words'.
	loaded firstName: loaded firstName capitalized.
	loaded remember: 'this words'.
	repository save: loaded.
	reloaded := repository findOne: DummyPerson atId: guy id.
	self assert: reloaded remember = 'this words'
]

{ #category : #tests }
MaplessPostgresTest >> testSubModelsFromReifiedJSON [
	| user guy jsonString reified loaded |
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
	loaded := repository findOne: DummyUser atId: user id.
	jsonString := loaded unreferenced asJSONString.
	reified := DummyUser fromJSONString: jsonString in: repository.
	self assert: reified person class equals: DummyPerson.
	self assert: reified completeName equals: 'john q'
]
