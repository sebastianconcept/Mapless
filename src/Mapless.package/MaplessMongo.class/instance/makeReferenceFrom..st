actions
makeReferenceFrom: aJSONString 
	"Answers a new reference from aJSONString (or nil if doesn't feel like one)"

	| jsonObject |

	jsonObject := [ Json readFrom: aJSONString readStream ] ifError: [ :x| nil ].

	^ (jsonObject notNil and:[
	jsonObject oid notNil and:[
	jsonObject modelClass notNil]]) 
		ifTrue:[ MaplessReference fromJSONObject: jsonObject ]
		ifFalse:[ nil ] 
