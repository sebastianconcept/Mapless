baselines
baseline16: spec
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
