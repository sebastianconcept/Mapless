Class {
	#name : #MaplessBehaviorSQLiteTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Behavior-Tests'
}

{ #category : #history }
MaplessBehaviorSQLiteTest class >> lastStoredRun [
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
MaplessBehaviorSQLiteTest class >> maplessClasses [
	^ {DummyPerson.
	DummyUser.
	DummyTag}
]

{ #category : #accessing }
MaplessBehaviorSQLiteTest class >> testDatabasePathString [

	^ (Smalltalk imageDirectory / 'MaplessSQLiteTest.db') pathString
]

{ #category : #actions }
MaplessBehaviorSQLiteTest >> resetDatabase [
	"Remove all objects so the database is clean for any test to be run."

	{
		ExamplePerson.
		ExampleTag.
		ExampleUser } do: [ :each |
		(repository hasTableFor: each)
			ifTrue: [ repository destroyAll: each ]
			ifFalse: [ repository ensureTableFor: each ] ]
]

{ #category : #actions }
MaplessBehaviorSQLiteTest >> savePersonNamed: aString [
	repository
		save:
			(ExamplePerson new
				firstName: aString;
				yourself)
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorSQLiteTest >> setUp [

	super setUp.
	repository := MaplessSQLiteRepository
		              for: 'Mapless-Tests'
		              on: self class testDatabasePathString.
	repository ensureDatabase.
	self resetDatabase
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorSQLiteTest >> tearDown [
	super tearDown.
	repository ifNotNil: [ repository shutDown ].
	repository := nil
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	user := ExampleUser new
		        userame: 'johnq';
		        yourself.
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	user person: guy.
	repository save: guy.
	repository save: user.
	self
		assert: (repository findOne: ExampleUser atId: user id) completeName
		equals: 'john q'.
	self
		assert: (repository findOne: ExampleUser atId: user id) person class
		equals: MaplessReference.
	self
		assert:
		(repository findOne: ExampleUser atId: user id) person model class
		equals: ExamplePerson.
	self
		assert:
		(repository findOne: ExampleUser atId: user id) person firstName
		equals: 'john'.
	self
		assert:
		(repository findOne: ExampleUser atId: user id) person lastName
		equals: 'q'
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testComposedDelete [
	| users |
	users := OrderedCollection new.
	Character alphabet
		do: [ :char | 
			users
				add:
					(ExampleUser new
						userame: char asString;
						person:
							(ExamplePerson new
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
MaplessBehaviorSQLiteTest >> testComposedDestroy [

	| users |
	users := OrderedCollection new.
	Character alphabet do: [ :char |
		users add: (ExampleUser new
				 userame: char asString;
				 person: (ExamplePerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self assert: (users allSatisfy: [ :user |
			 (repository findOne: ExamplePerson atId: user person id) notNil ]).
	users do: [ :user | repository destroy: user person ].
	self assert: (users allSatisfy: [ :user |
			 (repository findOne: ExamplePerson atId: user person id) isNil ]).
	self assert: (users allSatisfy: [ :user |
			 (repository findOne: ExampleUser atId: user id) notNil ]).
	users do: [ :user | repository destroy: user ].
	self assert: (users allSatisfy: [ :user |
			 (repository findOne: ExampleUser atId: user id) isNil ])
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testComposedSave [

	| user guy |
	user := ExampleUser new
		        userame: 'johnq';
		        yourself.
	guy := ExamplePerson new
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
MaplessBehaviorSQLiteTest >> testComposedSaveAndLoad [

	| user guy loaded when |
	when := DateAndTime now asUTC.
	user := ExampleUser new
		        createdOn: when;
		        username: 'johnq';
		        yourself.
	guy := ExamplePerson new
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
	loaded := repository findOne: ExampleUser atId: user id.
	self assert: loaded notNil.
	self assert: loaded createdOn notNil.
	self assert: loaded modifiedOn notNil.
	loaded
		createdOn: nil;
		modifiedOn: nil.
	user
		createdOn: nil;
		modifiedOn: nil.
	loaded data keysAndValuesDo: [ :k :v |
		((loaded data at: k) isKindOf: DateAndTime) not ifTrue: [
			self assert: (loaded maplessData at: k) = (user maplessData at: k) ] ].
	self assert: loaded username = 'johnq'.
	self assert: loaded person firstName = 'john'.
	self assert: loaded person lastName = 'q'.
	self assert: loaded person maplessClassName = #ExamplePerson.
	self assert: loaded person model class = ExamplePerson
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testComposition [

	| user guy |
	user := ExampleUser new
		        userame: 'johnq';
		        yourself.
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	user person: guy.
	self
		assert: (user maplessData at: 'person') class
		equals: ExamplePerson.
	self assert: user id isNil.
	self assert: (user maplessData at: 'person') id isNil.
	self assert: user completeName equals: 'john q'
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testConditionalCount [

	| users firstNames sqlCondition |
	users := OrderedCollection new.
	Character alphabet do: [ :char |
		users add: (ExampleUser new
				 username: char asString;
				 person: (ExamplePerson new
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
		assert: (repository count: ExamplePerson where: sqlCondition)
		equals: firstNames size
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testCount [

	| users |
	users := OrderedCollection new.
	Character alphabet do: [ :char |
		users add: (ExampleUser new
				 username: char asString;
				 person: (ExamplePerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self
		assert: (repository count: ExampleUser)
		equals: Character alphabet size
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testDelete [

	| people |
	people := OrderedCollection new.
	Character alphabet do: [ :char |
		people add: (ExamplePerson new
				 firstName: char asString;
				 yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository delete: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted ])
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testDestroy [

	| people |
	people := OrderedCollection new.
	Character alphabet do: [ :char |
		people add: (ExamplePerson new
				 firstName: char asString;
				 yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	people do: [ :guy | repository destroy: guy ].
	self assert: (people allSatisfy: [ :guy |
			 (repository findOne: ExamplePerson atId: guy id) isNil ])
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testExists [

	| guy |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	repository save: guy.
	self assert: (repository existsId: guy id of: ExamplePerson)
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testIsUnsaved [

	| guy |
	guy := ExamplePerson new
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
MaplessBehaviorSQLiteTest >> testMultipleComposedComposables [

	| tags tagsOfTags tagsOfTagsOfTags loaded |
	tags := OrderedCollection new.
	tagsOfTags := OrderedCollection new.
	tagsOfTagsOfTags := OrderedCollection new.
	tags
		add: (ExampleTag new
				 label: 'is this';
				 yourself);
		add: (ExampleTag new
				 label: 'multiply';
				 yourself);
		add: (ExampleTag new
				 label: 'composable?';
				 yourself);
		yourself.
	tagsOfTags
		add: (ExampleTag new
				 label: 'like';
				 yourself);
		add: (ExampleTag new
				 label: 'really?';
				 yourself);
		yourself.
	tagsOfTagsOfTags
		add: (ExampleTag new
				 label: 'wow';
				 yourself);
		add: (ExampleTag new
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
	loaded := repository findOne: ExampleTag atId: tags first id.
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
MaplessBehaviorSQLiteTest >> testMultipleComposedMixedSaveAndLoad [

	| guy things loaded |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	guy things: OrderedCollection new.
	guy things
		add: (ExampleTag new
				 label: 'cool';
				 yourself);
		add: (ExampleTag new
				 label: 'stuff';
				 yourself);
		add: (ExampleUser new
				 info: 'also this';
				 yourself);
		yourself.
	things := guy things.
	guy things do: [ :each | repository save: each ].
	self shouldnt: [ repository save: guy ] raise: MaplessUnsavedSubmodel.
	loaded := repository findOne: ExamplePerson atId: guy id.
	self assert: loaded notNil.
	self assert: loaded firstName = 'john'.
	self assert: loaded things isCollection.
	self assert: loaded things notEmpty.
	loaded things do: [ :each |
		self assert: (things anySatisfy: [ :t | t id = each id ]) ].
	loaded unreferenced.
	self assert: loaded things first class = ExampleTag.
	self assert: loaded things second class = ExampleTag.
	self assert: loaded things third class = ExampleUser
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testMultipleComposedSaveAndLoad [

	| user guy tags loaded |
	user := ExampleUser new
		        username: 'johnq';
		        yourself.
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	tags := OrderedCollection new.
	tags
		add: (ExampleTag new
				 label: 'cool';
				 yourself);
		add: (ExampleTag new
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
	loaded := repository findOne: ExampleUser atId: user id.
	self assert: loaded notNil.
	self assert: loaded username = 'johnq'.
	self assert: loaded tags isCollection.
	self assert: loaded tags notEmpty.
	self assert: loaded tags isCollection.
	loaded tags do: [ :tag |
		self assert: (tags anySatisfy: [ :t | t id = tag id ]) ]
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testQueryUsers [

	| users |
	users := OrderedCollection new.
	Character alphabet do: [ :char |
		users add: (ExampleUser new
				 username: char asString;
				 person: (ExamplePerson new
						  firstName: char asString;
						  yourself);
				 yourself) ].
	users do: [ :user | repository save: user person ].
	users do: [ :user | repository save: user ].
	self assert: (Character alphabet allSatisfy: [ :char |
			 (repository
				  findOne: ExampleUser
				  where: ('json_extract(maplessData,"$.username") = {1}' format:
						   { char asString printString })) notNil ])
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testSaveSetsID [

	| guy |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self deny: guy hasId.
	repository save: guy.
	self assert: (guy maplessData at: 'id') notNil.
	self assert: guy hasId
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testSimpleSave [

	| guy |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testSimpleSaveAndLoad [

	| guy loaded |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	repository save: guy.
	loaded := repository findOne: ExamplePerson atId: guy id.
	self assert: loaded notNil.
	loaded modifiedOn: nil.
	guy modifiedOn: nil.
	loaded maplessData keysAndValuesDo: [ :k :v |
		((loaded data at: k) isKindOf: DateAndTime) not ifTrue: [
			self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testSimpleSaveAndUpdate [

	| guy loaded reloaded |
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	repository save: guy.
	loaded := repository findOne: ExamplePerson atId: guy id.
	self assert: loaded firstName = 'john'.
	self deny: loaded remember = 'this words'.
	loaded firstName: loaded firstName capitalized.
	loaded remember: 'this words'.
	repository save: loaded.
	reloaded := repository findOne: ExamplePerson atId: guy id.
	self assert: reloaded remember = 'this words'
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testSubModelsFromReifiedJSON [

	| user guy jsonString reified loaded |
	user := ExampleUser new
		        userame: 'johnq';
		        yourself.
	guy := ExamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	user person: guy.
	repository save: guy.
	repository save: user.
	loaded := repository findOne: ExampleUser atId: user id.
	jsonString := loaded unreferenced asJSONString.
	reified := ExampleUser fromJSONString: jsonString in: repository.
	self assert: reified person class equals: ExamplePerson.
	self assert: reified completeName equals: 'john q'
]

{ #category : #tests }
MaplessBehaviorSQLiteTest >> testTruncate [

	| people |
	people := OrderedCollection new.
	Character alphabet do: [ :char |
		people add: (ExamplePerson new
				 firstName: char asString;
				 yourself) ].
	people do: [ :guy | repository save: guy ].
	self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
	self assert: (repository count: ExamplePerson) equals: 26.
	repository withClientDo: [ :client |
		client truncateMapless: ExamplePerson ].
	self assert: (repository count: ExamplePerson) equals: 0
]
