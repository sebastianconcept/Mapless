baselines
baselineGemStone: spec
	spec
		for: #gemstone
		do: [ 
			spec
				baseline: 'GLASS1'
					with: [ 
							spec
								loads: #('GsSqueakCommon');
								repository: 'github://glassdb/glass:master/repository' ];
				yourself.
			spec
				baseline: 'NeoJSON' with: [ spec repository: 'github://GsDevKit/NeoJSON:gs_master/repository' ];
				yourself.
			spec
				package: 'Mapless-GemStone-Core' with: [ spec requires: #('Mapless-Core-Base' 'GLASS1') ];
				package: 'Mapless-GemStone-Errors' with: [ spec requires: #('Mapless-Core-Errors') ];
				package: 'Mapless-GemStone-Models' with: [ spec requires: #('Mapless-Core-Base') ];
				package: 'Mapless-GemStone-Tests' with: [ spec requires: #('Mapless-Tests-Core' 'Mapless-GemStone-Core') ];
				package: 'JSON' with: [ spec requires: #('NeoJSON' 'GLASS1') ];
				yourself.
			spec
				group: 'all' with: #('CI');
				group: 'GemStone' with: #('Core' 'Mapless-GemStone-Core' 'Mapless-GemStone-Errors' 'Mapless-GemStone-Models');
				group: 'GemStone Tests' with: #('GemStone' 'Mapless-GemStone-Tests');
				group: 'Tests' with: #('GemStone Tests');
				group: 'CI' with: #('GemStone Tests');
				yourself ]