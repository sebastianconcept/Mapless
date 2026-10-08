Class {
	#name : #MaplessWithoutDynamicVariableTest,
	#superclass : #MaplessMongoMultiRepositoryTest,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #running }
MaplessWithoutDynamicVariableTest >> testSaveToAndReadFromTwoDatabases [
	| repo1 repo2 guy found |
	repo1 := MaplessMongoRepository
		for: 'Mapless-Test1'
		with: MaplessStandaloneMongoPool local.
	repo2 := MaplessMongoRepository
		for: 'Mapless-Test2'
		with: MaplessStandaloneMongoPool local.
	repositories at: 1 put: repo1.
	repositories at: 2 put: repo2.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	repo1 save: guy.
	self assert: guy hasId.
	found := repo1 findOne: SamplePerson atId: guy id.
	self assert: found notNil.
	self assert: found firstName equals: guy firstName.
	guy := SamplePerson new
		firstName: 'peter';
		lastName: 'e';
		yourself.
	self deny: guy hasId.
	repo2 save: guy.
	self assert: guy hasId.
	found := repo2 findOne: SamplePerson atId: guy id.
	self assert: found notNil.
	self assert: found firstName equals: guy firstName
]

{ #category : #running }
MaplessWithoutDynamicVariableTest >> testUseSubmapless [
	| repo user guy found |
	repo := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessStandaloneMongoPool local.
	repositories at: 1 put: repo.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user := SampleUser new
		uername: 'e';
		person: guy;
		yourself.
	repo save: guy.
	repo save: user.
	found := repo findOne: SampleUser atId: user id.
	self assert: found notNil.
	self assert: found person firstName equals: guy firstName.
	self assert: found completeName equals: 'john q'
]
