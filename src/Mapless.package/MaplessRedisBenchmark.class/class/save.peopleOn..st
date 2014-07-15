actions
save: aQuantity peopleOn: aStream 

	| guys firstNames lastNames delay savesPerSecond readsPerSecond |

	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guys := OrderedCollection new.
	
	1 to: aQuantity do:[ :i |
		firstNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		lastNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i | 
		guys add: (MaplessRedisDummyPerson new
					firstName: (firstNames at: i);
					lastName: (lastNames at: i);
					yourself)].

	RedisPool instance do:[ :client |
		delay := Time millisecondsToRun: [
			1 to: aQuantity do:[ :i | 
				(guys at: i) save]]].
	
	savesPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessRedisDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',savesPerSecond asString,' saves per second)'.
		
	RedisPool instance do:[ :client |
		delay := Time millisecondsToRun: [
				guys do:[ :guy | 
					MaplessRedisDummyUser findAt: guy oid]]].
	
	readsPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
			
	aStream cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessRedisDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',readsPerSecond asString,' reads per second)';
		flush