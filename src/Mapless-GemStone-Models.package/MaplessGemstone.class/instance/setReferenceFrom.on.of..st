actions
setReferenceFrom: aString on: aKey of: aJSONObject
	"Set a reference (only if aJsonObject feels like one)"

	| jsonObject |

	jsonObject := [ Json readFrom: aString readStream ] ifError: [ :x| nil ].

	(jsonObject notNil and:[
	jsonObject oid notNil and:[
	jsonObject modelClass notNil]]) ifTrue:[ 
		 aJSONObject 
			at: aKey 
			put: ( MaplessReference fromJSONObject: jsonObject ) ]