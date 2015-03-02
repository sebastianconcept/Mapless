*Mapless-Core-Base
asJSONString

	^ String streamContents: [:str |
		self jsonWriteOn: str ]