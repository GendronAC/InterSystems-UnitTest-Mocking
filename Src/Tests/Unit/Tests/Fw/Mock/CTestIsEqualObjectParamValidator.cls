Import Tests.Fw.Mock

/// Make sure the tests are synced with Tests.MockTests.CTestIsNotEqualParamValidator
Class Tests.Unit.Tests.Fw.Mock.CTestIsEqualObjectParamValidator Extends Tests.Fw.CUnitTestBase
{

Property validator As CIsEqualObjectParamValidator;

Property mock As Tests.Fw.Mock.CMockBase;

Property streamContainer As Ens.StreamContainer;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   do ##super()
   
   set ..mock = ..CreateMock()
   set ..streamContainer = ##class(Ens.StreamContainer).%New()
   
   quit $$$OK
}

// --- Validate tests ---

Method TestValidateTwoEqualObjects()
{
   do ..Expect(..mock.IsEqual(..streamContainer)).AndReturn($$$OK)
   do ..ReplayAllMocks()
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(..streamContainer)
   do $$$AssertStatusOK(..validator.Validate(..mock))
   
   do ..VerifyAllMocks()
}

Method TestValidateTwoNotEqualObjects()
{
   do ..Expect(..mock.IsEqual(..streamContainer)).AndReturn($$$ERROR(""))
   do ..ReplayAllMocks()
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(..streamContainer)
   do $$$AssertStatusNotOK(..validator.Validate(..mock))
   
   do ..VerifyAllMocks()
}

Method TestValidateIsEqualNotImplementedSameObject()
{
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(..streamContainer)
   do $$$AssertStatusOK(..validator.Validate(..streamContainer))
}

Method TestValidateIsEqualNotImplementedNotSameObject()
{
   set stream = ##class(%Stream.GlobalBinary).%New("")
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(stream)
   do $$$AssertStatusNotOK(..validator.Validate(..streamContainer))
}

Method TestValidateTwoEqualDatatypes()
{
   set ..validator = ##class(CIsEqualObjectParamValidator).%New("A")
   do $$$AssertStatusOK(..validator.Validate("A"))
}

Method TestValidateTwoNotEqualDatatypes()
{
   set ..validator = ##class(CIsEqualObjectParamValidator).%New("A")
   do $$$AssertStatusNotOK(..validator.Validate("B"))
}

Method TestValidateListsItemsDifferent()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(2))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(lstOne)
   do $$$AssertStatusNotOK(..validator.Validate(lstTwo))
}

Method TestValidateListsItemsSame()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(lstOne)
   do $$$AssertStatusOK(..validator.Validate(lstTwo))
}

Method TestValidateDynamicObjectSame()
{
   #Dim objOne As %DynamicObject = {"A" : "B", "C" : "D"}
   #Dim objTwo As %DynamicObject = {"C" : "D", "A" : "B"}
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(objOne)
   do $$$AssertStatusOK(..validator.Validate(objTwo))
}

Method TestValidateDynamicArraySame()
{
   #Dim objOne As %DynamicArray = ["A", "B", "C"]
   #Dim objTwo As %DynamicArray = ["A", "B", "C"]
   
   set ..validator = ##class(CIsEqualObjectParamValidator).%New(objOne)
   do $$$AssertStatusOK(..validator.Validate(objTwo))
}

}
