*mapless-core
asJSONString

	^ String streamContents: [:str |
		self jsonWriteOn: str ]