*Mapless
asJSONString

	^ String streamContents: [:str |
		self jsonWriteOn: str ]