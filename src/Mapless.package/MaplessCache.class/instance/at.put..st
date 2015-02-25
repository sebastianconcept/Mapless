actions
at: anId put: aModel

	^ self models at: anId put: (self newSlotFor: aModel)