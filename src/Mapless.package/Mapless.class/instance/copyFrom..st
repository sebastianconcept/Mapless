actions
copyFrom: aMapless
	"Takes the keys and values from aMapless
	and puts them in the local one.
	All key/values except for those to exclude 
	and without removing any local element."
	
	(aMapless data keys asOrderedCollection 
		removeAllFoundIn: self class keysToExclude;
		yourself) do: [ :k |
			self data at: k put: (aMapless at: k) ]