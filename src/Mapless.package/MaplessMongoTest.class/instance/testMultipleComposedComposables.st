testing
testMultipleComposedComposables

	| tags tagsOfTags tagsOfTagsOfTags loaded |

	tags := OrderedCollection new.
	tagsOfTags := OrderedCollection new.
	tagsOfTagsOfTags := OrderedCollection new.

	tags 
		add: (MaplessMongoDummyTag new label: 'is this'; yourself);	
		add: (MaplessMongoDummyTag new label: 'multiply'; yourself);	
		add: (MaplessMongoDummyTag new label: 'composable?'; yourself);	
		yourself.

	tagsOfTags 
		add: (MaplessMongoDummyTag new label: 'like'; yourself);	
		add: (MaplessMongoDummyTag new label: 'really?'; yourself);	
		yourself.

	tagsOfTagsOfTags  
		add: (MaplessMongoDummyTag new label: 'wow'; yourself);	
		add: (MaplessMongoDummyTag new label: 'nice'; yourself);	
		yourself.

	self do:[ tagsOfTagsOfTags do:[ :tag | tag save] ].
	tagsOfTags first tags: tagsOfTagsOfTags.
	tagsOfTags second tags: tagsOfTagsOfTags.
	self shouldnt: [ self do:[ tagsOfTags do:[:tag| tag save ] ]] raise: MaplessUnsavedSubmodel.

	tags first tags: tagsOfTags.
	tags second tags: tagsOfTags.
	tags third tags: tagsOfTags.
	self shouldnt: [ self do:[ tags do:[:e| e save ] ]] raise: MaplessUnsavedSubmodel.
	
	self deny: (tagsOfTagsOfTags anySatisfy: [:tag| tag isUnsaved]).	
	self deny: (tagsOfTags anySatisfy: [:tag| tag isUnsaved]).	
	self deny: (tags anySatisfy: [:tag| tag isUnsaved]).	

	self do:[ 
		loaded := MaplessMongoDummyTag findAt: tags first oid.
		self assert: loaded notNil.
		self deny: loaded isUnsaved.
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
		self assert: loaded tags first tags second label = 'nice'.
		]
