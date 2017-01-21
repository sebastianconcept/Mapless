baselines
baseline13: spec
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
