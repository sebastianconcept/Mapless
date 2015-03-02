baselines
baselinePharo: spec
	spec
		for: #pharo
		do: [ 
			spec
				project: 'MongoTalk'
				with: [ 
					spec
						className: 'ConfigurationOfMongoTalk';
						file: 'ConfigurationOfMongoTalk';
						versionString: #bleedingEdge;
						repository: 'http://smalltalkhub.com/mc/francois/MongoTalk/main' ].
			spec
				project: 'Xtreams'
				with: [ 
					spec
						className: 'ConfigurationOfXtreams';
						file: 'ConfigurationOfXtreams';
						repository: 'http://www.squeaksource.com/Xtreams' ].
			spec package: 'Redis-Client' with: [ spec repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main' ].
			spec package: 'Redis-Queue' with: [ spec repository: 'http://smalltalkhub.com/mc/mlhales/RedisClient/main' ].
			spec
				project: 'PostgresV2'
				with: [ 
					spec
						className: 'ConfigurationOfPostgresV2';
						file: 'ConfigurationOfPostgresV2';
						versionString: #stable;
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main' ].
			spec
				package: 'Mapless-Mongo-Core' with: [ spec requires: #('Mapless-Core' 'Xtreams' 'MongoTalk') ];
				package: 'Mapless-Mongo-Errors' with: [ spec requires: #('Mapless-Mongo-Core') ];
				package: 'Mapless-Mongo-Tests' with: [ spec requires: #('Mapless-Tests-Core' 'Mapless-Mongo-Core') ];
				package: 'Mapless-Redis-Core' with: [ spec requires: #('Mapless-Core' 'Xtreams' 'Redis-Client' 'Redis-Queue') ];
				package: 'Mapless-Redis-Errors' with: [ spec requires: #('Mapless-Redis-Core') ];
				package: 'Mapless-Redis-Tests' with: [ spec requires: #('Mapless-Tests-Core' 'Mapless-Redis-Core') ];
				package: 'Mapless-Postgres-Core' with: [ spec requires: #('Mapless-Core' 'PostgresV2') ];
				package: 'Mapless-Postgres-Tests' with: [ spec requires: #('Mapless-Tests-Core' 'Mapless-Postgres-Core') ].
			spec
				group: 'all' with: #('Mongo Tests' 'Redis Tests' 'Postgres Tests');
				group: 'Mongo' with: #('Core' 'Mapless-Mongo-Core' 'Mapless-Mongo-Errors' 'Mapless-Mongo-Tests');
				group: 'Redis' with: #('Core' 'Mapless-Redis-Core' 'Mapless-Redis-Errors' 'Mapless-Redis-Tests');
				group: 'Postgres' with: #('Core' 'Mapless-Postgres-Core' 'Mapless-Postgres-Tests');
				group: 'Tests' with: #('Mapless-Tests-Core' 'Mongo Tests' 'Redis Tests' 'Postgres Tests');
				group: 'Mongo Tests' with: #('Mongo' 'Mapless-Mongo-Tests');
				group: 'Redis Tests' with: #('Redis' 'Mapless-Redis-Tests');
				group: 'Postgres Tests' with: #('Postgres' 'Mapless-Redis-Tests');
				yourself ]