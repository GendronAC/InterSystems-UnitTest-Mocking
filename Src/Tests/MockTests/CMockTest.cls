Class Tests.MockTests.CMockTest Extends Tests.Fw.CUnitTestBase
{

Property mock As Tests.MockTests.IMockTest;

Property mock2 As Tests.MockTests.IMockTest;

Property mockTestObject As Tests.MockTests.CMockTestObject;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   set ..mock = ..CreateMock()
   set ..mock2 = ..CreateMock(##class(Tests.MockTests.IMockTest).%ClassName(1))
   set ..mockTestObject = ##class(Tests.MockTests.CMockTestObject).%New(..mock)
   quit $$$OK
}

Method TestMockSuccessReturnObject()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(..mock).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), ..mock)

   do ..VerifyAllMocks()
}

Method TestMockSuccessReturnDataType()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(1).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)

   do ..VerifyAllMocks()
}

Method TestMockSuccessTimes2()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(1).Times(2)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)
   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)

   do ..VerifyAllMocks()
}

Method TestMockSuccessTimesNoTimes()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)

   do ..VerifyAllMocks()
}

Method TestMockSuccessNoReturn()
{
   do ..Expect(..mock.CallSameMethod("A")).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorWrongInstance()
{
   do ..Expect(..mock.CallSameMethod("A")).Times(1)
   do ..ReplayAllMocks()

   do ..mockTestObject.SetMock(..CreateMock())
   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorWrongMethod()
{
   do ..Expect(..mock.CallSameMethod("A")).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallAnotherSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorWrongParameterCountExpectedMore()
{
   do ..Expect(..mock.CallSameMethod("A", "1")).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorWrongParameterCountGotMore()
{
   do ..Expect(..mock.CallSameMethodTwoParams("A")).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethodTwoParams("A", "B"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorReturnWrongParameter()
{
   do ..Expect(..mock.CallSameMethod("B")).AndReturn(1).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)

   do ..VerifyAllMocks()
}

Method TestMockErrorWrongSecondParameter()
{
   do ..Expect(..mock.CallSameMethodTwoParams("A", "B")).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethodTwoParams("A", "C"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorNoMoreExpectedMethod()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(..mock).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), ..mock)
   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorNoExpectedMethodEver()
{
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")

   do ..VerifyAllMocks()
}

Method TestMockErrorMethodExpectedLeft()
{
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(..mock).Times(1)
   do ..ReplayAllMocks()

   do ..VerifyAllMocks()
}

Method TestMockSuccessMultipleMocks()
{
   do ..mockTestObject.SetSecondMock(..mock2)
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(..mock).Times(1)
   do ..Expect(..mock2.CallSameMethod("B")).AndReturn(..mock2).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), ..mock)
   do $$$AssertEquals(..mockTestObject.CallSameMethodSecondMock("B"), ..mock2)

   do ..VerifyAllMocks()
}

Method TestMockSuccessMultipleMocksMultipleCalls()
{
   do ..mockTestObject.SetSecondMock(..mock2)
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(1).Times(2)
   do ..Expect(..mock2.CallSameMethod("B")).AndReturn(2).Times(1)
   do ..Expect(..mock.CallAnotherSameMethod("C")).AndReturn(3).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)
   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), 1)
   do $$$AssertEquals(..mockTestObject.CallSameMethodSecondMock("B"), 2)
   do $$$AssertEquals(..mockTestObject.CallAnotherSameMethod("C"), 3)

   do ..VerifyAllMocks()
}

Method TestMockErrorMultipleMocksWrongOrder()
{
   do ..mockTestObject.SetSecondMock(..mock2)
   do ..Expect(..mock2.CallSameMethod("B")).AndReturn(..mock).Times(1)
   do ..Expect(..mock.CallSameMethod("A")).AndReturn(..mock2).Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "")
   do $$$AssertEquals(..mockTestObject.CallSameMethodSecondMock("B"), ..mock)

   do ..VerifyAllMocks()
}

// --- NotNull tests ---

Method TestMockSuccessNotNullObjectValidator()
{
   do ..Expect(..mock.CallSameMethod(..NotNullObject("%Stream.GlobalCharacter"))).AndReturn("A").Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod(##class("%Stream.GlobalCharacter").%New("A")), "A")
   do ..VerifyAllMocks()
}

Method TestMockErrorNotNullObjectValidatorNullObject()
{
   do ..Expect(..mock.CallSameMethod(..NotNullObject("%Stream.GlobalCharacter"))).AndReturn("A").Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod(""), "A")
   do ..VerifyAllMocks()
}

Method TestMockErrorNotNullObjectValidatorNotAnObject()
{
   do ..Expect(..mock.CallSameMethod(..NotNullObject("%String"))).AndReturn("A").Times(1)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("A"), "A")
   do ..VerifyAllMocks()
}

// --- UseCustomFunctionValidation tests ---

Method TestMockSuccessUseCustomFunctionValidation()
{
   do ..Expect(..mock.CallSameMethod(..UseCustomFunctionValidation(..mockTestObject, "VerificationMethod"))).AndReturn("A")
   do ..Expect(..mock.VerificationMethod("123"))
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("123"), "A")

   do ..VerifyAllMocks()
}

Method TestMockErrorUseCustomFunctionValidationUnknownFunction()
{
   do ..Expect(..mock.CallSameMethod(..UseCustomFunctionValidation(..mockTestObject, "UndefinedFunction"))).AndReturn("A")
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethod("123"), "A")

   do ..VerifyAllMocks()
}

// --- ByRef tests ---

Method TestMockSuccessByRef()
{
   #dim strParameter = "A"
   #dim strParameterFinalValue = "B"
   do ..Expect(..mock.CallSameMethodByRef(..ByRefParam(strParameter,
                                                                               strParameterFinalValue))).AndReturn(..mock)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethodByRef(.strParameter), ..mock)
   do $$$AssertEquals(strParameter, strParameterFinalValue)

   do ..VerifyAllMocks()
}

Method TestMockSuccessNotNullByRef()
{
   #dim strParameter = ##class(%Stream.GlobalBinary).%New()
   #dim strParameterFinalValue = ##class(%Stream.GlobalBinary).%New("AAAAA")

   do ..Expect(..mock.CallSameMethodByRef(..ByRefParam(..NotNullObject("%Stream.GlobalBinary"),
                                                                               strParameterFinalValue))).AndReturn(..mock)
   do ..ReplayAllMocks()

   do $$$AssertEquals(..mockTestObject.CallSameMethodByRef(.strParameter), ..mock)
   do $$$AssertEquals(strParameter, strParameterFinalValue)

   do ..VerifyAllMocks()
}

// -- SetMockResultSet tests --

Method TestMockSuccessSetMockResultSet()
{
   do $$$AssertEquals(##class(Fw.CResultSetTools).GetNewResultSet().%ClassName(1), ##class(%ResultSet).%ClassName(1))
   do ..SetMockResultSet("", ..%ClassName(1)_"||ResultSetOverrides")
   do $$$AssertEquals(##class(Fw.CResultSetTools).GetNewResultSet().%ClassName(1), ##class(Tests.Fw.Mock.CMockResultSet).%ClassName(1))

   #Dim ex As %Exception.General = $$$NULLOREF
   try
   {
      do $$$AssertEquals(##class(Fw.CResultSetTools).GetNewResultSet("Query"), $$$NULLOREF)
      do ..SetMockResultSet("Query", ..%ClassName(1)_"||ResultSetOverrides")
      do $$$AssertEquals(##class(Fw.CResultSetTools).GetNewResultSet("Query").%ClassName(1), ##class(Tests.Fw.Mock.CMockResultSet).%ClassName(1))
   }
   catch ex
   {
      do $$$AssertEquals(ex.DisplayString(), "Query columns are empty   ")
   }
}

// -- GetMockResultSet tests --

Method TestMockSuccessGetMockResultSet()
{
   do $$$AssertEquals(..GetMockResultSet().%ClassName(1), ##class(%ResultSet).%ClassName(1))
   do ..SetMockResultSet("", ..%ClassName(1)_"||ResultSetOverrides")
   do $$$AssertEquals(..GetMockResultSet().%ClassName(1), ##class(Tests.Fw.Mock.CMockResultSet).%ClassName(1))

   #Dim ex As %Exception.General = $$$NULLOREF
   try
   {
      do $$$AssertEquals(..GetMockResultSet("Query"), $$$NULLOREF)
      do ..SetMockResultSet("Query", ..%ClassName(1)_"||ResultSetOverrides")
      do $$$AssertEquals(..GetMockResultSet("Query").%ClassName(1), ##class(Tests.Fw.Mock.CMockResultSet).%ClassName(1))
   }
   catch ex
   {
      do $$$AssertEquals(ex.DisplayString(), "Query columns are empty   ")
   }
}

// -- Helper method --

XData ResultSetOverrides
{
<Query>
<ColumnsNames>;FacilityID;Name;ShortName;SiteCode</ColumnsNames>
<Row>C;Centre hospitalier;CHUS;123456</Row>
<Row>D;Ailleurs très loin;FAR;-</Row>
</Query>
}

}
