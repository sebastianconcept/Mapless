Class {
	#name : #MaplessResourcesTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Tests-Tests'
}

{ #category : #tests }
MaplessResourcesTest >> test11And44And44Chance [
	| wr n1 n2 i j latest k n3 |
	i := 0.
	j := 0.
	k := 0.
	wr := MaplessWeightedRandomPolicy new.
	n1 := MaplessWeightedNode new
		weight: 0.5;
		value: 'url1';
		yourself.
	n2 := MaplessWeightedNode new
		weight: 2;
		value: 'url2';
		yourself.
	n3 := MaplessWeightedNode new
		weight: 2;
		value: 'url3';
		yourself.
	wr
		addNode: n1;
		addNode: n2;
		addNode: n3.
	10000
		timesRepeat: [ latest := wr next.
			latest value = 'url1'
				ifTrue: [ i := i + 1 ].
			latest value = 'url2'
				ifTrue: [ j := j + 1 ].
			latest value = 'url3'
				ifTrue: [ k := k + 1 ] ].
	self assert: i > 1000.
	self assert: i < 1200.
	self assert: j > 4200.
	self assert: j < 4600.
	self assert: k > 4200.
	self assert: k < 4600
]

{ #category : #tests }
MaplessResourcesTest >> test30And70Chance [
	| wr n1 n2 i j latest |
	i := 0.
	j := 0.
	wr := MaplessWeightedRandomPolicy new.
	n1 := MaplessWeightedNode new
		weight: 30;
		value: 'url1';
		yourself.
	n2 := MaplessWeightedNode new
		weight: 70;
		value: 'url2';
		yourself.
	wr
		addNode: n1;
		addNode: n2.
	10000
		timesRepeat: [ latest := wr next.
			latest value = 'url1'
				ifTrue: [ i := i + 1 ].
			latest value = 'url2'
				ifTrue: [ j := j + 1 ] ].
	self assert: i > 2800.
	self assert: j > 6800
]

{ #category : #tests }
MaplessResourcesTest >> testAddNodes [

	| wr n1 n2 |
	wr := MaplessWeightedRandomPolicy new.
	n1 := MaplessWeightedNode new
		      weight: 30;
		      value: 'url1';
		      yourself.
	n2 := MaplessWeightedNode new
		      weight: 70;
		      value: 'url2';
		      yourself.
	wr nodes: {
			n1.
			n2 }.

	self assert: wr nodes first equals: n1.
	self assert: wr nodes second equals: n2
]

{ #category : #tests }
MaplessResourcesTest >> testChangeWeightedNodeWeight [

	| n1 |
	n1 := MaplessWeightedNode new
		      weight: 0.5;
		      value: 'url1';
		      yourself.

	self assert: n1 weight equals: 0.5.

	n1 weight: 0.75.
	self deny: n1 weight equals: 0.5.
	self assert: n1 weight equals: 0.75
]

{ #category : #tests }
MaplessResourcesTest >> testHalfHalfChance [
	| wr n1 n2 i j latest |
	i := 0.
	j := 0.
	wr := MaplessWeightedRandomPolicy new.
	n1 := MaplessWeightedNode new
		weight: 2;
		value: 'url1';
		yourself.
	n2 := MaplessWeightedNode new
		weight: 2;
		value: 'url2';
		yourself.
	wr
		addNode: n1;
		addNode: n2.
	10000
		timesRepeat: [ latest := wr next.
			latest value = 'url1'
				ifTrue: [ i := i + 1 ].
			latest value = 'url2'
				ifTrue: [ j := j + 1 ] ].
	self assert: i > 4800.
	self assert: j > 4800
]

{ #category : #tests }
MaplessResourcesTest >> testPrintsWeightedNodeInAUsefulWay [

	| n1 |
	n1 := MaplessWeightedNode new
		      weight: 0.5;
		      value: 'url1';
		      yourself.

	self assert: n1 asString equals: 'a MaplessWeightedNode(0.5@url1)'
]

{ #category : #tests }
MaplessResourcesTest >> testRandom [

	| wr n1 n2 thisOne |
	wr := MaplessWeightedRandomPolicy seed: 1000.
	n1 := MaplessWeightedNode new
		      weight: 30;
		      value: 'url1';
		      yourself.
	n2 := MaplessWeightedNode new
		      weight: 70;
		      value: 'url2';
		      yourself.
	wr nodes: {
			n1.
			n2 }.
	wr recalculateWeight.
	thisOne := wr next.
	self assert: (thisOne = n1 or: [ thisOne = n2 ])
]

{ #category : #tests }
MaplessResourcesTest >> testWeights [

	| wr n1 n2 |
	wr := MaplessWeightedRandomPolicy seed: 1000.
	n1 := MaplessWeightedNode new
		      weight: 30;
		      value: 'url1';
		      yourself.
	n2 := MaplessWeightedNode new
		      weight: 70;
		      value: 'url2';
		      yourself.
	wr nodes: {
			n1.
			n2 }.
	wr recalculateWeight.
	self assert: wr totalWeight equals: 100
]
