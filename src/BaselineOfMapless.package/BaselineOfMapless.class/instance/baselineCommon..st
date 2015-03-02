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
				with: [ spec repository: 'http://smalltalkhub.com/mc/sebastianconcept/SASExtensions/main' ].

			spec baseline: 'ConfigurationFiles' with: [ spec repository: 'github://flow-stack/ConfigurationFiles:master/src' ].

			spec
				package: 'Mapless-Core'
					with: [ spec requires: #('JSON' 'JSONExtensions' 'ConfigurationFiles' 'Mapless-Core-Errors') ];
				package: 'Mapless-Core-Models' with: [ spec requires: #('Mapless-Core' 'Mapless-Core-Errors') ];
				package: 'Mapless-Core-Errors';
				package: 'Mapless-Core-Repository' with: [ spec requires: #('Mapless-Core') ];
				package: 'Mapless-Tests-Core' with: [ spec requires: #('Mapless-Core') ];
				package: 'JSONExtensions' with: [ spec requires: #('JSON' 'Collections-OrderPreservingDictionary') ].

			spec
				group: 'default' with: #('all');
				group: 'all' with: #('Core');
				group: 'Core' with: #('Mapless-Core' 'Mapless-Core-Models' 'Mapless-Core-Repository');
				yourself ]