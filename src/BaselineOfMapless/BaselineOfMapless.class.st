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
			self projectPackages: spec ]
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

		spec
			repository: 'github://sebastianconcept/Mapless/src';
			package: 'Mapless'.
]
