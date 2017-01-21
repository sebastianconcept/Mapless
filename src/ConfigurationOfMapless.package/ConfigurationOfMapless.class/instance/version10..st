versions
version10: spec
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
