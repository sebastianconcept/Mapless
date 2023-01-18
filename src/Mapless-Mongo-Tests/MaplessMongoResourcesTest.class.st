Class {
	#name : #MaplessMongoResourcesTest,
	#superclass : #MaplessMongoTest,
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
	someMongoUrls := {'mongo1:27017' . 'mongo2:27018' . 'mongo3:27019'.
	'mongo4:27020'}.
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
	lowerBound := repeats / counters size - (repeats * 0.05).
	upperBound := repeats / counters size + (repeats * 0.05).
	counters values
		do: [ :each | 
			self assert: each > lowerBound.
			self assert: upperBound > each ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testHalf25Half50WeightSpecification [
	| someMongoUrls counters client repeats lowerBound upperBound mongoUrlString toRemove balancedNodes weight nodeUrl occurrences reference hostAndPort key |
	mongoUrlString := '25@mongo1:27017,25@mongo2:27018,25@mongo3:27019,50@mongo4:27020'.
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
	(balancedNodes select: [ :each | each second ~= 'mongo4:27020' ])
		do: [ :balancedNode | 
			weight := balancedNode first asNumber.
			nodeUrl := balancedNode second.
			occurrences := counters
				at: (self mongoUrlAsKey: nodeUrl asMongoUrl).
			reference := weight * repeats
				/ repository accessor loadBalancer totalWeight.
			lowerBound := reference - (repeats * 0.10).
			upperBound := reference + (repeats * 0.10).
			self assert: occurrences > lowerBound.
			self assert: upperBound > occurrences ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testMongoUrlWithWeigths [
	| mongoUrlString someMongoUrls counters repeats client hostAndPort balancedNodes nodeUrl weight toRemove key lowerBound upperBound occurrences reference |
	mongoUrlString := '25@mongo1:27017,25@mongo2:27018,50@mongo3:27019,50@mongo4:27020'.
	
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
			lowerBound := reference - (repeats * 0.10).
			upperBound := reference + (repeats * 0.10).
			self assert: occurrences > lowerBound.
			self assert: upperBound > occurrences ]
]

{ #category : #tests }
MaplessMongoResourcesTest >> testMongoUrlWithoutWeigths [
	| mongoUrlString repeats client counters lowerBound upperBound someMongoUrls |
	mongoUrlString := 'mongo1:27017,mongo2:27018,mongo3:27019,mongo4:27020'.
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
