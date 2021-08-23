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
		do: [ spec blessing: #release.
			self dependencies: spec.
			self projectPackages: spec.
			spec
				group: 'Core' with: #('Mapless-Core' 'Mapless-Models' 'Mapless-Errors');
				group: 'Mongo' with: #('Mapless-Mongo Mapless-Mongo-Errors' 'Mapless-Mongo-Tests' );
				group: 'Postgres'
					with: #('Mapless-Postgres' 'Mapless-Postgres-Tests');
				group: 'Benchmark' with: #('Mapless-Benchmark');
				group: 'default' with: #('Core' 'Mongo') ]
]

{ #category : #baseline }
BaselineOfMapless >> dependencies: spec [
	spec
		baseline: 'JSONExtensions'
		with: [ spec repository: 'github://sebastianconcept/JSONExtensions/src' ].
	spec
		baseline: 'MongoTalk'
		with:
			[ spec repository: 'github://pharo-nosql/mongotalk/mc' ].
		
	"TODO: Postgres new supported client" 
]

{ #category : #baseline }
BaselineOfMapless >> projectPackages: spec [
	spec package: 'Mapless'
]
