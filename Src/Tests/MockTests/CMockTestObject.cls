Class Tests.MockTests.CMockTestObject Extends %RegisteredObject
{

Property testObject As %RegisteredObject;

Property testObject2 As %RegisteredObject;

Method %OnNew(testObject As %RegisteredObject = {$$$NULLOREF}) As %Status
{
   set ..testObject = testObject
   quit $$$OK
}

Method SetMock(testObject As %RegisteredObject)
{
   set ..testObject = testObject
}

Method SetSecondMock(testObject As %RegisteredObject)
{
   set ..testObject2 = testObject
}

Method CallSameMethod(parameter) As %String
{
   quit ..testObject.CallSameMethod(parameter)
}

Method CallSameMethodSecondMock(parameter As %String) As %String
{
   quit ..testObject2.CallSameMethod(parameter)
}

Method CallAnotherSameMethod(parameter As %String) As %String
{
   quit ..testObject.CallAnotherSameMethod(parameter)
}

Method CallSameMethodByRef(ByRef parameter)
{
   quit ..testObject.CallSameMethodByRef(.parameter)
}

Method CallSameMethodTwoParams(parameter1 As %String, parameter2 As %String) As %String
{
   quit ..testObject.CallSameMethodTwoParams(parameter1, parameter2)
}

Method IsEqual(object As %RegisteredObject) As %Status
{
   #dim status = $$$ERROR("Not equals")

   set:((..testObject = object.testObject) && (..testObject2 = object.testObject2)) status = $$$OK
   
   quit status
}

Method VerificationMethod(strContent As %String)
{
   do ..testObject.VerificationMethod(strContent)
}

}
