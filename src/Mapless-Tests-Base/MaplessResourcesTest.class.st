Class {
	#name : #MaplessResourcesTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Tests-Base-Tests'
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
		addNode: n3;
		yourself.
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
	self assert: j > 4300.
	self assert: j < 4500.
	self assert: k > 4300.
	self assert: k < 4500
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
		addNode: n2;
		yourself.
	10000
		timesRepeat: [ latest := wr next.
			latest value = 'url1'
				ifTrue: [ i := i + 1 ].
			latest value = 'url2'
				ifTrue: [ j := j + 1 ] ].
	self assert: i > 2900.
	self assert: j > 6900
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
		addNode: n2;
		yourself.
	10000
		timesRepeat: [ latest := wr next.
			latest value = 'url1'
				ifTrue: [ i := i + 1 ].
			latest value = 'url2'
				ifTrue: [ j := j + 1 ] ].
	self assert: i > 4900.
	self assert: j > 4900
]
