Import Tests.Fw.Mock

Class Tests.Unit.Tests.Fw.Mock.CTestContainsParamValidator Extends Tests.Fw.CUnitTestBase [ ProcedureBlock ]
{

Property validator As Tests.Fw.Mock.CContainsParamValidator [ Private ];

ClassMethod RunTests()
{
   do ##super()
}

// --- Validate tests ---

Method TestValidateContainFound()
{
   set ..validator = ##class(CContainsParamValidator).%New("LookForThis")

   do $$$AssertStatusOK(..validator.Validate("Blah LookForThis Thing"))
   do $$$AssertStatusOK(..validator.Validate("LookForThis Thing"))
   do $$$AssertStatusOK(..validator.Validate("Blah LookForThis"))
   do $$$AssertStatusNotOK(..validator.Validate("Blah LOOkForThis"))
}

Method TestValidateContainInsensitive()
{
   set ..validator = ##class(CContainsParamValidator).%New("LookForThis", 1)

   do $$$AssertStatusOK(..validator.Validate("Blah LookForThis Thing"))
   do $$$AssertStatusOK(..validator.Validate("LookForThis Thing"))
   do $$$AssertStatusOK(..validator.Validate("Blah LookForThis"))
   do $$$AssertStatusOK(..validator.Validate("Blah LOOkForThis"))
}

Method TestValidateContainObjectUnsupported()
{
   set ..validator = ##class(CContainsParamValidator).%New(##class(%ArrayOfDataTypes).%New())
   do $$$AssertStatusNotOK(..validator.Validate("Blah LookForThis Thing"))
   do $$$AssertStatusNotOK(..validator.Validate(##class(%ListOfDataTypes).%New()))

   set ..validator = ##class(CContainsParamValidator).%New("LookForThis")
   do $$$AssertStatusNotOK(..validator.Validate(##class(%ListOfDataTypes).%New()))
}

}
