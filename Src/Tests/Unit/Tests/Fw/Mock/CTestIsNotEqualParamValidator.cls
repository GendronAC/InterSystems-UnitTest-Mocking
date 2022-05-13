Import Tests.Fw.Mock

/// Make sure the tests are synced with Tests.MockTests.CTestIsEqualObjectParamValidator
Class Tests.Unit.Tests.Fw.Mock.CTestIsNotEqualParamValidator Extends Tests.Fw.CUnitTestBase
{

Property validator As CIsNotEqualParamValidator;

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
   
   set ..validator = ##class(CIsNotEqualParamValidator).%New(..streamContainer)
   do $$$AssertStatusNotOK(..validator.Validate(..mock))
   
   do ..VerifyAllMocks()
}

Method TestValidateTwoNotEqualObjects()
{
   do ..Expect(..mock.IsEqual(..streamContainer)).AndReturn($$$ERROR(""))
   do ..ReplayAllMocks()
   
   set ..validator = ##class(CIsNotEqualParamValidator).%New(..streamContainer)
   do $$$AssertStatusOK(..validator.Validate(..mock))
   
   do ..VerifyAllMocks()
}

Method TestValidateIsEqualNotImplemented()
{
   set ..validator = ##class(CIsNotEqualParamValidator).%New(..streamContainer)
   do $$$AssertStatusNotOK(..validator.Validate(..streamContainer))
}

Method TestValidateTwoEqualDatatypes()
{
   set ..validator = ##class(CIsNotEqualParamValidator).%New("A")
   do $$$AssertStatusNotOK(..validator.Validate("A"))
}

Method TestValidateTwoNotEqualDatatypes()
{
   set ..validator = ##class(CIsNotEqualParamValidator).%New("A")
   do $$$AssertStatusOK(..validator.Validate("B"))
}

Method TestValidateListsItemsDifferent()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(2))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   
   set ..validator = ##class(CIsNotEqualParamValidator).%New(lstOne)
   do $$$AssertStatusOK(..validator.Validate(lstTwo))
}

Method TestValidateListsItemsSame()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   
   set ..validator = ##class(CIsNotEqualParamValidator).%New(lstOne)
   do $$$AssertStatusNotOK(..validator.Validate(lstTwo))
}

}
