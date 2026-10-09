"
ExampleEmployee is an ExamplePerson subclass that does not use MaplessBehavior itself.
When a composed model stores one of these, the repository treats it as a Mapless model because it inherits isMapless from ExamplePerson.
"
Class {
	#name : #ExampleEmployee,
	#superclass : #ExamplePerson,
	#category : #'Mapless-Behavior-Tests'
}
