baseline
baseline: spec
	<baseline>
	
	spec for: #common do: [
		spec blessing: #release.
		spec package: 'Mapless' with: [  
			spec repository: 'github://sebastianconcept/Mapless/src' ].

		spec group: 'default' with: #('ALL') 
	]