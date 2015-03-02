actions
save
	"Storage this instance into the persistent collection"
	
	self onAboutToSave.
	
	self isUnsaved
		ifTrue:[ self insert ]
		ifFalse:[ self update ].
		
	self onSaved