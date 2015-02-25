actions
save: aQuantity peopleOn: aStream 

	| guys firstNames lastNames delay savesPerSecond readsPerSecond redisRepository  |

	firstNames := OrderedCollection new.
	lastNames := OrderedCollection new.
	guys := OrderedCollection new.
	redisRepository := MaplessRedisRepository on: RedisPool instance requestClient.
	
	1 to: aQuantity do:[ :i |
		firstNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i |
		lastNames add: Character alphabet shuffled anyOne asString ].

	1 to: aQuantity do:[ :i | 
		guys add: (DummyPerson new
					firstName: (firstNames at: i);
					lastName: (lastNames at: i);
					yourself)].

	redisRepository do: [ 
		delay := Time millisecondsToRun: [
			1 to: aQuantity do:[ :i | 
				(guys at: i) save]]].
	
	savesPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
	
	aStream cr;
		nextPutAll: 'Saved ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',savesPerSecond asString,' saves per second)'.
		
	redisRepository do:[
		delay := Time millisecondsToRun: [
				guys do:[ :guy | 
					DummyUser findId: guy oid]]].
	
	readsPerSecond := ((1000 * aQuantity) / delay asFloat) truncated.
			
	aStream cr;
		nextPutAll: 'Read ';
		nextPutAll: aQuantity asString;
		nextPutAll: ' instances of MaplessDummyPerson in: ';
		nextPutAll: delay milliseconds asString;
		nextPutAll: ' ms ';
		nextPutAll: '(~',readsPerSecond asString,' reads per second)';
		flush