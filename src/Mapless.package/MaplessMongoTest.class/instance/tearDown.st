setUp-tearDown
tearDown
	super tearDown.

	pool reset.
	pool := nil.
	repository := nil