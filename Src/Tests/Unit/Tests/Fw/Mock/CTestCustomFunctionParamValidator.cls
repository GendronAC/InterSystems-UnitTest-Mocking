Import Tests.Fw.Mock

Class Tests.Unit.Tests.Fw.Mock.CTestCustomFunctionParamValidator Extends Tests.Fw.CUnitTestBase
{

Property validator As CCustomFunctionParamValidator;

Property mock As Tests.Fw.Mock.CMockBase;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   do ##super()
   
   set ..mock = ..CreateMock()
   
   quit $$$OK
}

// --- Validate tests ---

Method TestValidateExistingFunction()
{
   do ..Expect(..mock.ValidateMethodName("123"))
   
   do ..ReplayAllMocks()
   
   set ..validator = ##class(CCustomFunctionParamValidator).%New(..mock, "ValidateMethodName")
   do $$$AssertStatusOK(..validator.Validate("123"))
   
   do ..VerifyAllMocks()
}

Method TestValidateUndefinedObject()
{
   set ..validator = ##class(CCustomFunctionParamValidator).%New($$$NULLOREF, "ValidateMethodName")
   do $$$AssertStatusNotOK(..validator.Validate("123"))
}

Method TestValidateUndefinedFunction()
{
   set ..validator = ##class(CCustomFunctionParamValidator).%New($THIS, "UndefinedFunction")      
   do $$$AssertStatusNotOK(..validator.Validate("123"))
}

Method TestValidateDatatypes()
{
   set ..validator = ##class(CCustomFunctionParamValidator).%New($THIS, "ValidateStringHelper")
   do $$$AssertStatusOK(..validator.Validate("123"))
}

Method TestValidateObjects()
{
   set ..validator = ##class(CCustomFunctionParamValidator).%New($THIS, "ValidateObjectHelper")
   set object = ##class(%ZEN.proxyObject).%New()
   set object.strContent = "Ce test est un succès !"
   do $$$AssertStatusOK(..validator.Validate(object))
}

// -- Helper functions --

Method ValidateStringHelper(strValue As %String)
{
   do $$$AssertTrue(strValue [ "2")
}

Method ValidateObjectHelper(object As %RegisteredObject)
{
   do $$$AssertTrue(object.strContent [ "succès")
}

}
