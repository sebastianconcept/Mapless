Class {
	#name : #ConfigurationOfMapless,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : 'ConfigurationOfMapless'
}

{ #category : #'development support' }
ConfigurationOfMapless class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfMapless class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #catalog }
ConfigurationOfMapless class >> catalogChangeLog [
	^ '
Date: March 5, 2014

First Mapless configuration using github

'
]

{ #category : #catalog }
ConfigurationOfMapless class >> catalogContactInfo [
	^ 'https://github.com/sebastianconcept'
]

{ #category : #catalog }
ConfigurationOfMapless class >> catalogDescription [
	^ 'Mapless is a persistance framework biased to JSON friendly backends.'
]

{ #category : #catalog }
ConfigurationOfMapless class >> catalogKeyClassesAndExample [
	^ '
Mapless


'
]

{ #category : #catalog }
ConfigurationOfMapless class >> catalogKeywords [
	^ #(#Database #Persistence)
]

{ #category : #'gitfiletree support' }
ConfigurationOfMapless class >> ensureGitFileTree [
	"And all related dependencies."

	Smalltalk
		at: #MCFileTreeGitRepository
		ifAbsent: [ 
			Gofer new
				url: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main';
				configurationOf: 'GitFileTree';
				loadDevelopment ]
]

{ #category : #private }
ConfigurationOfMapless class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfMapless class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfMapless class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfMapless class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^ self project latestVersion load
]

{ #category : #loading }
ConfigurationOfMapless class >> loadDev [

	<apiDocumentation>
	^(self project version: #dev) load
]

{ #category : #accessing }
ConfigurationOfMapless class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfMapless class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfMapless >> baseline10: spec [
    <version: '1.0-baseline'>
    
	spec for: #'pharo3.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #bleedingEdge;
				repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline11: spec [
    <version: '1.1-baseline'>
    
	spec for: #'pharo3.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #bleedingEdge;
				repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline12: spec [
    <version: '1.2-baseline'>
    
	spec for: #'pharo3.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #bleedingEdge;
				repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/sebastianconcept/ConfigurationFiles/main'.
				].			
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline13: spec [
    <version: '1.3-baseline'>
    
	spec for: #'pharo3.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #bleedingEdge;
				repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			

		spec project: 'PostgresV2' with: [ 
			spec
				className: 'ConfigurationOfPostgresV2';
				file: 'ConfigurationOfPostgresV2';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline14: spec [
    <version: '1.4-baseline'>
    
	spec for: #'pharo3.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #bleedingEdge;
				repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			

		spec project: 'PostgresV2' with: [ 
			spec
				className: 'ConfigurationOfPostgresV2';
				file: 'ConfigurationOfPostgresV2';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline15: spec [
    <version: '1.5-baseline'>
    
	spec for: #'pharo5.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			

		spec project: 'PostgresV2' with: [ 
			spec
				className: 'ConfigurationOfPostgresV2';
				file: 'ConfigurationOfPostgresV2';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
				].			
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline16: spec [
    <version: '1.6-baseline'>
    
	spec for: #'pharo5.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main'.
				].

		spec project: 'Xtreams' with: [ spec
				className: 'ConfigurationOfXtreams';
				file: 'ConfigurationOfXtreams';
				repository: 'http://www.squeaksource.com/Xtreams'.
				].
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Client'.
		spec
			repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main';
			package: 'Redis-Queue'.
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main'.
				].			

		spec project: 'PostgresV2' with: [ 
			spec
				className: 'ConfigurationOfPostgresV2';
				file: 'ConfigurationOfPostgresV2';
				versionString: '2.5';
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
				].			
		]

]

{ #category : #baselines }
ConfigurationOfMapless >> baseline17: spec [
    <version: '1.7-baseline'>
    
	spec for: #'pharo5.x' do: [
		self class ensureGitFileTree.
		spec blessing: #baseline.

		spec
			repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main';
			package: 'JSON'.

		spec
			repository: 'http://squeaksource.com/OrderPreservingDict';
			package: 'Collections-OrderPreservingDictionary'.

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main';
			package: 'JSONExtensions'.

		spec project: 'MongoTalk' with: [ 
			spec
				className: 'ConfigurationOfMongoTalk';
				file: 'ConfigurationOfMongoTalk';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main'.
				].
			
		spec project: 'ConfigurationFiles' with: [ 
			spec
				className: 'ConfigurationOfConfigurationFiles';
				file: 'ConfigurationOfConfigurationFiles';
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main'.
				].			

		spec project: 'PostgresV2' with: [ 
			spec
				className: 'ConfigurationOfPostgresV2';
				file: 'ConfigurationOfPostgresV2';
				versionString: '2.5';
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
				].			
		]

]

{ #category : #'as yet unclassified' }
ConfigurationOfMapless >> beta: spec [
	<symbolicVersion: #'beta'>

	spec for: #'pharo5.x' version: '2.10'

]

{ #category : #accessing }
ConfigurationOfMapless >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #'symbolic versions' }
ConfigurationOfMapless >> dev: spec [
	<symbolicVersion: #'dev'>

	spec for: #'pharo5.x' version: '2.10'

]

{ #category : #accessing }
ConfigurationOfMapless >> project [
	^ project
		ifNil: [ 
			| constructor |
				"Bootstrap Metacello if it is not already loaded"
			(self class baseConfigurationClassIfAbsent: [  ]) ensureMetacello.
				"Construct Metacello project"
			project := MetacelloMCProject new projectAttributes: self customProjectAttributes.
			constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
			project loadType: #linear.	"change to #atomic if desired"
			project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfMapless >> stable: spec [
	<symbolicVersion: #'stable'>

	spec for: #'pharo5.x' version: '2.10'

]

{ #category : #versions }
ConfigurationOfMapless >> version09: spec [
	<version: '0.9' imports: #('1.0-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

			spec
				blessing: #dev;
				author: 'sebastianconcept';
				repository: 'gitfiletree://github.com/sebastianconcept/Mapless.git?protocol=https&dir=src&branch=dev';
				description: 'Mapless is a small framework for storing objects in a key->data fashion (i.e.: noSQL databases) without requiring any kind of object-data map. So far only MongoDB and Redis are supported.'.

			spec package: 'Mapless'.
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version10: spec [
	<version: '1.0' imports: #('1.0-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

			spec
				blessing: #beta;
				author: 'sebastianconcept';
				repository: 'gitfiletree://github.com/sebastianconcept/Mapless.git?protocol=https&dir=src&branch=master';
				description: 'Mapless is a small framework for storing objects in a key->data fashion (i.e.: noSQL databases) without requiring any kind of object-data map. So far only MongoDB and Redis are supported.'.

			spec package: 'Mapless'.
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version11: spec [
	<version: '1.1' imports: #('1.0-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version12: spec [
	<version: '1.2' imports: #('1.1-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version210: spec [
	<version: '2.10' imports: #('1.7-baseline')>
	
	spec
		for: #'pharo5.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
		].

]

{ #category : #versions }
ConfigurationOfMapless >> version22: spec [
	<version: '2.2' imports: #('1.1-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version23: spec [
	<version: '2.3' imports: #('1.1-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version24: spec [
	<version: '2.4' imports: #('1.1-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version25: spec [
	<version: '2.5' imports: #('1.1-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version26: spec [
	<version: '2.6' imports: #('1.2-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
			
			 ].

]

{ #category : #versions }
ConfigurationOfMapless >> version27: spec [
	<version: '2.7' imports: #('1.4-baseline')>
	
	spec
		for: #'pharo3.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
		].

]

{ #category : #versions }
ConfigurationOfMapless >> version28: spec [
	<version: '2.8' imports: #('1.5-baseline')>
	
	spec
		for: #'pharo4.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
		].

]

{ #category : #versions }
ConfigurationOfMapless >> version29: spec [
	<version: '2.9' imports: #('1.6-baseline')>
	
	spec
		for: #'pharo5.x'
		do: [ 

		spec
			repository: 'http://smalltalkhub.com/mc/sebastianconcept/Mapless/main';
			package: 'Mapless'.
		].

]
