"
Cover basic functionality
"
Class {
	#name : #MaplessUnQLiteTest,
	#superclass : #AnObsoleteMaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-UnQLite-Tests-Tests'
}

{ #category : #history }
MaplessUnQLiteTest class >> maplessClasses [
	^ {SamplePerson.
	SampleUser.
	SampleTag}
]

{ #category : #actions }
MaplessUnQLiteTest >> dropDatabase: aDatabaseFileName [
	aDatabaseFileName asFileReference deleteIfAbsent: [  ]
]

{ #category : #actions }
MaplessUnQLiteTest >> savePersonNamed: aString [
	repository
		save:
			(SamplePerson new
				firstName: aString;
				yourself)
]

{ #category : #'setUp-tearDown' }
MaplessUnQLiteTest >> setUp [
	| dbFilename |
	super setUp.
	dbFilename := FileSystem workingDirectory / 'Mapless-Tests.db'.
	self dropDatabase: dbFilename.
	repository := MaplessUnQLiteRepository for: dbFilename pathString
]

{ #category : #'setUp-tearDown' }
MaplessUnQLiteTest >> tearDown [
	super tearDown.
	repository ifNotNil: [ repository shutDown ].
	repository := nil
]

{ #category : #tests }
MaplessUnQLiteTest >> testComposedAccess [
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
MaplessUnQLiteTest >> testComposedDelete [
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
MaplessUnQLiteTest >> testComposedDestroy [
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
MaplessUnQLiteTest >> testComposedSave [
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
MaplessUnQLiteTest >> testComposedSaveAndLoad [
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
MaplessUnQLiteTest >> testComposition [
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
MaplessUnQLiteTest >> testCursorDoEach [
	| people found |
	people := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			people
				add:
					(SamplePerson new
						firstName: char asString;
						yourself) ].
	people do: [ :guy | repository save: guy ].
	repository
		withCursorDo: [ :cursor | 
			cursor
				doEach: [ :each | 
					self assert: each isMapless.
					self assert: each class equals: SamplePerson.
					found := people detect: [ :e | e id = each id ] ifNone: [ nil ].
					self deny: found equals: nil.
					self assert: found firstName equals: each firstName ] ].

]

{ #category : #tests }
MaplessUnQLiteTest >> testCursorDoEachFollowsSortingOrder [
	| people i |
	people := OrderedCollection new.
	1 to: 10 do: [ :index | 
		people
			add:
				(SamplePerson new
					id: index;
					firstName: 'guy-' , index asString;
					yourself) ].
	people do: [ :guy | repository save: guy ].
	repository
		withCursorDo: [ :cursor | 
			cursor first.
			i := 10.
			cursor
				fromCurrentDoEach: [ :each | 
					"Transcript crShow: 'guy-' , i asString."					
					self assert: each firstName equals: 'guy-' , i asString.
					i := i - 1 ] ].
	repository
		withCursorDo: [ :cursor | 
			cursor last.
			i := 1.
			cursor
				fromCurrentReverseDoEach: [ :each | 
					"Transcript crShow: 'guy-' , i asString."
					self assert: each firstName equals: 'guy-' , i asString.
					i := i + 1 ] ]
]

{ #category : #tests }
MaplessUnQLiteTest >> testDelete [
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
MaplessUnQLiteTest >> testDestroy [
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
	self
		assert:
			(people
				allSatisfy: [ :guy | (repository findOne: SamplePerson atId: guy id) notNil ]).
	people do: [ :guy | repository destroy: guy ].
	self
		assert:
			(people
				allSatisfy: [ :guy | (repository findOne: SamplePerson atId: guy id) isNil ])
]

{ #category : #tests }
MaplessUnQLiteTest >> testExists [
	| guy loaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (repository existsId: guy id of: SamplePerson)
]

{ #category : #tests }
MaplessUnQLiteTest >> testIsUnsaved [
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
MaplessUnQLiteTest >> testMultipleComposedComposables [
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
MaplessUnQLiteTest >> testMultipleComposedMixedSaveAndLoad [
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
MaplessUnQLiteTest >> testMultipleComposedSaveAndLoad [
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
MaplessUnQLiteTest >> testSaveSetsID [
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
MaplessUnQLiteTest >> testSeekGreaterThan [
	| people i |
	people := OrderedCollection new.
	1 to: 10 do: [ :index | 
		people
			add:
				(SamplePerson new
					id: index;
					firstName: 'guy-' , index asString;
					yourself) ].
	people do: [ :guy | repository save: guy ].
	repository
		withCursorDo: [ :cursor | 
			| key |
			key := repository namespaced: 'id' of: SamplePerson valued: 7.
			cursor seekGreaterThan: key.
			i := 7.
			cursor
				fromCurrentReverseDoEach: [ :each | 
					self assert: each firstName equals: 'guy-' , i asString.
					i := i + 1 ] ]
]

{ #category : #tests }
MaplessUnQLiteTest >> testSeekLessThan [
| people i |
	people := OrderedCollection new.
	1 to: 10 do: [ :index | 
		people
			add:
				(SamplePerson new
					id: index;
					firstName: 'guy-' , index asString;
					yourself) ].
	people do: [ :guy | repository save: guy ].
	repository
		withCursorDo: [ :cursor | 
			| key |
			key := repository namespaced: 'id' of: SamplePerson valued: 7.
			cursor seekGreaterThan: key.
			i := 7.
			cursor
				fromCurrentDoEach: [ :each | 
					self assert: each firstName equals: 'guy-' , i asString.
					i := i - 1 ] ]
]

{ #category : #tests }
MaplessUnQLiteTest >> testSimpleSave [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessUnQLiteTest >> testSimpleSaveAndLoad [
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
MaplessUnQLiteTest >> testSimpleSaveAndLoadInMemory [
	| guy loaded memoryRepository |
	memoryRepository := MaplessUnQLiteRepository inMemory.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	memoryRepository save: guy.
	loaded := memoryRepository findOne: SamplePerson atId: guy id.
	self assert: loaded notNil.
	loaded modifiedOn: nil.
	guy modifiedOn: nil.
	loaded maplessData
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessUnQLiteTest >> testSimpleSaveAndUpdate [
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
MaplessUnQLiteTest >> testSubModelsFromReifiedJSON [
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
