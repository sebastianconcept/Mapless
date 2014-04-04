actions
setReferenceFrom: aString on: aKey of: aJsonObject
	"Set a reference (only if aJsonObject feels like one)"

	| jsonObject |

	jsonObject := [ Json readFrom: aString readStream ] ifError: [ :x| nil ].

	(jsonObject notNil and:[
	jsonObject oid notNil and:[
	jsonObject modelClass notNil]]) ifTrue:[ 
		 aJsonObject 
			at: aKey 
			put: ( MaplessReference fromJSONObject: jsonObject ) ] 
