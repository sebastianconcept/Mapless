actions
updateWith: aDict

	aDict keysAndValuesDo: [:key :value| self data at: key put: value].