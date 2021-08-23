Class {
	#name : #BaselineOfMapless,
	#superclass : #BaselineOf,
	#category : #BaselineOfMapless
}

{ #category : #baseline }
BaselineOfMapless >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self setUpDependencies: spec.
			self setUpPackages: spec.
			spec
				group: 'Core' with: #('Mapless-Base-Core');
				group: 'Mongo' with: #('Mapless-Mongo-Core' 'Mapless-Mongo-Tests');
				group: 'Postgres' with: #('Mapless-Postgres-Core' 'Mapless-Postgres-Tests');
				group: 'Benchmark' with: #('Mapless-Benchmark-Core');
				group: 'default' with: #('Mongo' 'Benchmark') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpDependencies: spec [

	spec
		baseline: 'JSONExtensions'
		with: [ spec repository: 'github://sebastianconcept/JSONExtensions/src' ].
	spec
		baseline: 'MongoTalk'
		with:
			[ spec repository: 'github://pharo-nosql/mongotalk/mc:1.25' ].
]

{ #category : #baseline }
BaselineOfMapless >> setUpPackages: spec [
	spec package: 'Mapless-Base-Core'.
	spec
		package: 'Mapless-Benchmark-Core'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Tests-Base'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Mongo-Core'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Mongo-Tests'
		with: [ spec requires: #('Mapless-Mongo-Core' 'Mapless-Tests-Base') ].
	spec
		package: 'Mapless-Postgres-Core'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Postgres-Tests'
		with: [ spec requires: #('Mapless-Postgres-Core' 'Mapless-Tests-Base') ]
]
