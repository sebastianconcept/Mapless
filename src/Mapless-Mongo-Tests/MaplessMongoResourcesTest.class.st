Class {
	#name : #MaplessMongoResourcesTest,
	#superclass : #MaplessResourcesTest,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #tests }
MaplessMongoResourcesTest >> mongoUrlAsKey: aMongoUrl [
	^ '{1}:{2}'
		format:
			{aMongoUrl host.
			aMongoUrl port asString}
]

{ #category : #'setUp-tearDown' }
MaplessMongoResourcesTest >> setUp [
	Smalltalk vm maxExternalSemaphoresSilently: 32 * 1024
]

{ #category : #tests }
MaplessMongoResourcesTest >> testEqualChanceWithoutWeightSpecification [
	| someMongoUrls counters client repeats lowerBound upperBound |
	someMongoUrls := {'127.0.0.1:27017' . '127.0.0.1:27019'.
	'127.0.0.1:27020' . '127.0.0.1:27021' . '127.0.0.1:27022'}.
	counters := Dictionary new.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with:
			(MaplessMongoReplicaSetPool
				mongoUrls: someMongoUrls
				database: 'Mapless-Test').
	repository accessor
		minReadOnlyClients: 10;
		minReadWriteClients: 10;
		start.
	someMongoUrls do: [ :url | counters at: url asMongoUrl put: 0 ].
	counters
		removeKey: repository accessor getIdleReadWriteClient asMongoUrl.
	repeats := 1000.
	repeats
		timesRepeat: [ client := repository accessor getIdleReadOnlyClient.
			counters
				at: client asMongoUrl
				put: (counters at: client asMongoUrl) + 1 ].
	lowerBound := (repeats / counters size) - (repeats * 0.05).
	upperBound := (repeats / counters size) + (repeats * 0.05).
	counters values
		do: [ :each | 
			self assert: each > lowerBound.
			self assert: upperBound > each ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testHalf25Half50WeightSpecification [
	| someMongoUrls counters client repeats lowerBound upperBound mongoUrlString toRemove balancedNodes weight nodeUrl occurrences reference hostAndPort key |
	mongoUrlString := '25@127.0.0.1:27017,25@127.0.0.1:27019,25@127.0.0.1:27020,50@127.0.0.1:27021,50@127.0.0.1:27022'.
	counters := Dictionary new.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with:
			(MaplessMongoReplicaSetPool
				fromString: mongoUrlString
				database: 'Mapless-Test').
	repository accessor
		minReadOnlyClients: 10;
		minReadWriteClients: 10;
		start.
	someMongoUrls := (mongoUrlString substrings: ',') asOrderedCollection.
	toRemove := someMongoUrls
		detect: [ :each | 
			(each substrings: '@') second asMongoUrl
				= repository accessor getIdleReadWriteClient asMongoUrl ].
	someMongoUrls remove: toRemove.
	someMongoUrls
		do: [ :url | 
			hostAndPort := (url substrings: '@') second.
			counters at: hostAndPort put: 0 ].
	repeats := 1000.
	repeats
		timesRepeat: [ client := repository accessor getIdleReadOnlyClient.
			key := self mongoUrlAsKey: client asMongoUrl.
			counters at: key put: (counters at: key) + 1 ].
	balancedNodes := someMongoUrls
		collect: [ :each | each substrings: '@' ].
	balancedNodes
		do: [ :balancedNode | 
			weight := balancedNode first asNumber.
			nodeUrl := balancedNode second.
			occurrences := counters
				at: (self mongoUrlAsKey: nodeUrl asMongoUrl).
			reference := weight * repeats
				/ repository accessor loadBalancer totalWeight.
			lowerBound := reference - (repeats * 0.03).
			upperBound := reference + (repeats * 0.03).
			self assert: occurrences > lowerBound.
			self assert: upperBound > occurrences ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testMongoUrlWithWeigths [
	| mongoUrlString someMongoUrls counters repeats client hostAndPort balancedNodes nodeUrl weight toRemove key lowerBound upperBound occurrences reference |
	mongoUrlString := '33@127.0.0.1:27017,33@127.0.0.1:27019,33@127.0.0.1:27020,80@127.0.0.1:27021,80@127.0.0.1:27022'.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with:
			(MaplessMongoReplicaSetPool
				fromString: mongoUrlString
				database: 'Mapless-Test').
	repository accessor
		minReadOnlyClients: 10;
		minReadWriteClients: 10;
		start.
	someMongoUrls := (mongoUrlString substrings: ',') asOrderedCollection.
	toRemove := someMongoUrls
		detect: [ :each | 
			(each substrings: '@') second asMongoUrl
				= repository accessor getIdleReadWriteClient asMongoUrl ].
	someMongoUrls remove: toRemove.
	counters := Dictionary new.
	someMongoUrls
		do: [ :url | 
			hostAndPort := (url substrings: '@') second.
			counters at: hostAndPort put: 0 ].
	toRemove := repository accessor getIdleReadWriteClient asMongoUrl.
	toRemove := self mongoUrlAsKey: toRemove.
	repeats := 1000.
	repeats
		timesRepeat: [ client := repository accessor getIdleReadOnlyClient.
			key := self mongoUrlAsKey: client asMongoUrl.
			counters at: key put: (counters at: key) + 1 ].
	balancedNodes := someMongoUrls
		collect: [ :each | each substrings: '@' ].
	balancedNodes
		do: [ :balancedNode | 
			weight := balancedNode first asNumber.
			nodeUrl := balancedNode second.
			occurrences := counters
				at: (self mongoUrlAsKey: nodeUrl asMongoUrl).
			reference := weight * repeats
				/ repository accessor loadBalancer totalWeight.
			lowerBound := reference - (repeats * 0.03).
			upperBound := reference + (repeats * 0.03).
			self assert: occurrences > lowerBound.
			self assert: upperBound > occurrences ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testMongoUrlWithoutWeigths [
	| mongoUrlString repeats client counters lowerBound upperBound someMongoUrls |
	mongoUrlString := '127.0.0.1:27017,127.0.0.1:27019,127.0.0.1:27020,127.0.0.1:27021,127.0.0.1:27022'.
	counters := Dictionary new.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with:
			(MaplessMongoReplicaSetPool
				fromString: mongoUrlString
				database: 'Mapless-Test').
	repository accessor
		minReadOnlyClients: 10;
		minReadWriteClients: 10;
		start.
	someMongoUrls := mongoUrlString substrings: ','.
	someMongoUrls do: [ :url | counters at: url asMongoUrl put: 0 ].
	counters
		removeKey: repository accessor getIdleReadWriteClient asMongoUrl.
	repeats := 1000.
	repeats
		timesRepeat: [ client := repository accessor getIdleReadOnlyClient.
			counters
				at: client asMongoUrl
				put: (counters at: client asMongoUrl) + 1 ].
	lowerBound := repeats / counters size - (repeats * 0.05).
	upperBound := repeats / counters size + (repeats * 0.05).
	counters values
		do: [ :each | 
			self assert: each > lowerBound.
			self assert: upperBound > each ]
]
