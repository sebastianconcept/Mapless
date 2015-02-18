tests
testSimpleSaveAndLoad
	| guy loaded |

	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self do: [ self assert: guy isUnsaved ].	
	self do: [ guy save ].
	self do: [ self deny: guy isUnsaved ].

	self do: [ loaded := DummyPerson findId: guy id ].

	self assert: loaded notNil.
	self do: [ self deny: loaded isUnsaved ].
	
	loaded data keysAndValuesDo: [ :k :v |
		((loaded data at: k) isKindOf: DateAndTime) not ifTrue: [
			self assert: (loaded data at: k) = (guy data at: k)]]

	