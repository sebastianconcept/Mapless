baselines
baselineCommon: spec
	spec
		for: #common
		do: [ 
			spec
				package: 'Collections-OrderPreservingDictionary'
				with: [ spec repository: 'http://squeaksource.com/OrderPreservingDict' ].
			spec package: 'JSON' with: [ spec repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main' ].
			spec
				package: 'JSONExtensions'
				with: [ 
					spec
						requires: #('JSON' 'Collections-OrderPreservingDictionary');
						repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main' ].
			spec baseline: 'ConfigurationFiles' with: [ spec repository: 'github://flow-stack/ConfigurationFiles/src' ].
			spec
				package: 'Mapless-Core-Base'
					with: [ spec requires: #('JSON' 'JSONExtensions' 'ConfigurationFiles' 'Mapless-Core-Errors') ];
				package: 'Mapless-Core-Errors';
				package: 'Mapless-Core-Repository' with: [ spec requires: #('Mapless-Core-Base') ];
				package: 'Mapless-Tests-Core' with: [ spec requires: #('Mapless-Example-Models') ];
				package: 'Mapless-Example-Models' with: [ spec requires: #('Mapless-Core-Base') ];
				package: 'JSONExtensions' with: [ spec requires: #('JSON' 'Collections-OrderPreservingDictionary') ].
			spec
				group: 'default' with: #('all');
				group: 'all' with: #('Core');
				group: 'Core' with: #('Mapless-Core-Base' 'Mapless-Core-Repository');
				group: 'Tests' with: #('Mapless-Tests-Core');
				group: 'Examples' with: #('Mapless-Example-Models');
				yourself ]