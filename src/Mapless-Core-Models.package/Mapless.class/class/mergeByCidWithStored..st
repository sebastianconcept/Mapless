actions
mergeByCidWithStored: aMapless
	"Merges the stored verision of aMapless (found by cid) by
	 overwriting and adding whatever is in aMapless."
	
	| stored |

	stored := aMapless freshFromCid.
	stored 
		ifNil: [ stored := aMapless ]
		ifNotNil: [ 
			aMapless data keysAndValuesDo: [ :k :v |
				stored data at: k put: v ] ].

	^ stored