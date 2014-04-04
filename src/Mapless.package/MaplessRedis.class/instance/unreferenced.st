actions
unreferenced 
	"Returns this model without references to submodels.
	It will reify any proxy (reference to another sub model) found"
	
	data keysAndValuesDo: [:k :v |
	
		v class = MaplessReference ifTrue:[ |subModel|
			subModel := v model.
			data at: k put: subModel unreferenced. ].
		"decend one level into arrays which could hold MaplessMongoReference's"
		v isArray ifTrue: [ | unreferencedCollection |
			unreferencedCollection := OrderedCollection new.
			v do: [:each |
				each class = MaplessReference 
					ifFalse:[unreferencedCollection add: each unreferenced]
					ifTrue: [| subModelInArray |
						subModelInArray := each model.
						unreferencedCollection add: subModelInArray unreferenced] 
				].
			data at: k put: unreferencedCollection.
			]
		]