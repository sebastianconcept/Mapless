actions
save: aMapless
	"Storage this instance into the persistent collection"

	self onAboutToSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
		
	self onSaved: aMapless