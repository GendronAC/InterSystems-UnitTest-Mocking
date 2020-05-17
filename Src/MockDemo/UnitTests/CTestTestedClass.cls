Class MockDemo.UnitTests.CTestTestedClass Extends Tests.Fw.CUnitTestBase
{

Property mathService As MockDemo.MathService [ Private ];

Property testedClass As MockDemo.CTestedClass [ Private ];

// --- Run test ---

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   set ..mathService = ..CreateMock()
   set ..testedClass = ##class(MockDemo.CTestedClass).%New(..mathService)
   quit $$$OK
}

// --- Tests for SumOperation ---

Method TestSumOperation()
{
   do ..Expect(..mathService.Add(1, 2)).AndReturn(3).Times(3)
   do ..ReplayAllMocks()
   
   do $$$AssertEquals(..testedClass.SumOperation(1, 2), 3)
   do $$$AssertEquals(..testedClass.SumOperation(1, 2), 3)
   do $$$AssertEquals(..testedClass.SumOperation(1, 2), 3)
   
   do ..VerifyAllMocks()
}

/// This tests fails only because it is intended to for demo purpose.
Method TestSumOperationParameterError()
{
   do ..Expect(..mathService.Add(1, 2)).AndReturn(3)
   do ..ReplayAllMocks()
   
   do $$$AssertEquals(..testedClass.SumOperation(1, 3), 3)
   
   do ..VerifyAllMocks()
}

// --- Tests for ComplexOperation ---

/// The mathService.Divide() method isn't even implemented. Yet this test is able
/// to verify that the status can be properly returned when passed by reference.
/// The result of 6/2 doesn't even count. The mock is told to return "50".
Method TestComplexOperationDivide()
{
   #Dim expectedStatus As %Status = $$$OK
   do ..Expect(..mathService.GreaterThan(6, 2)).AndReturn(1)
   do ..Expect(..mathService.Divide(6, 2, ..ByRefParam($$$OK, expectedStatus))).AndReturn(50)
   do ..ReplayAllMocks()
   
   #Dim status As %Status = $$$OK
   do $$$AssertEquals(..testedClass.ComplexOperation(6, 2, .status), 50)
   do $$$AssertStatusOK(status)
   
   do ..VerifyAllMocks()
}

Method TestComplexOperationMultiply()
{
   #Dim expectedStatus As %Status = $$$OK
   do ..Expect(..mathService.GreaterThan(6, 2)).AndReturn(0) // <-- Does not even have to be real.
   do ..Expect(..mathService.Multiply(6, 2, ..ByRefParam($$$OK, expectedStatus))).AndReturn(-25)
   do ..ReplayAllMocks()
   
   #Dim status As %Status = $$$OK
   do $$$AssertEquals(..testedClass.ComplexOperation(6, 2, .status), -25)
   do $$$AssertStatusOK(status)
   
   do ..VerifyAllMocks()
}

Method TestComplexOperationErrorDivisionByZeroError()
{
   #Dim expectedStatus As %Status = $$$ERROR("Divide by zero")
   do ..Expect(..mathService.GreaterThan(6, 0)).AndReturn(1)
   do ..Expect(..mathService.Divide(6, 0, ..ByRefParam($$$OK, expectedStatus))).AndReturn(-1)
   do ..ReplayAllMocks()
   
   #Dim status As %Status = $$$OK
   do $$$AssertEquals(..testedClass.ComplexOperation(6, 0, .status), -1)
   do $$$AssertStatusNotOK(status)
   
   do ..VerifyAllMocks()
}

/// This tests fails on purpose
Method TestComplexOperationUnconsumedError()
{
   #Dim expectedStatus As %Status = $$$ERROR("Divide by zero")
   do ..Expect(..mathService.Divide(6, 2, ..ByRefParam($$$OK, expectedStatus))).AndReturn(50)
   do ..ReplayAllMocks()
   
   // NOTHING
      
   do ..VerifyAllMocks()
}

/// This tests fails on purpose
Method TestComplexOperationUnexpectedCallError()
{
   // NO EXPECT

   do ..ReplayAllMocks()
   
   #Dim status As %Status = $$$OK
   do $$$AssertEquals(..testedClass.ComplexOperation(6, 2, .status), 50)
   do $$$AssertStatusNotOK(status)
   
   do ..VerifyAllMocks()
}

// --- Tests for FetchSQLQueryInformation ---

Method TestFetchSQLQueryInformation()
{
   do ..SetMockResultSet("MockDemo.CTestedClass:MyQuery", 
                         ..%ClassName(1) _ "||ResultSetMockedDemo")
   do ..ReplayAllMocks()
   
   do $$$AssertEquals(..testedClass.FetchSQLQueryInformation("C"), "A+C")
   
   do ..VerifyAllMocks()
}

XData ResultSetMockedDemo
{
<Query>
<ColumnsNames>,ResultA,ResultB</ColumnsNames>
<Row>A,C</Row>
<Row>A,D</Row>
</Query>
}

// --- Tests for FetchSQLPrepareInformation ---

Method TestFetchSQLPrepareInformation()
{
   do ..SetMockResultSet("", 
                         ..%ClassName(1) _ "||ResultSetMockedDemo")
   do ..ReplayAllMocks()
   do $$$AssertEquals(..testedClass.FetchSQLPrepareInformation("C"), "|A+C|A+D")
   
   do ..VerifyAllMocks()
}

/// This test fails on purpose to show unconsumed SQL Queries
Method TestFetchSQLPrepareInformationUnconsumedError()
{
   do ..SetMockResultSet("", 
                         ..%ClassName(1) _ "||ResultSetMockedDemo")
   do ..ReplayAllMocks()

   // NOTHING

   do ..VerifyAllMocks()
}

/// This tests validates Object passed in mocks
Method TestPopulateObjectProperties()
{
   // Prepare expected test parameters
   set expectedHl7Message = ##class(EnsLib.HL7.Message).%New()
   set expectedHl7Message.DocType = "2.6:ADT_A01"
   do $$$AssertStatusOK(expectedHl7Message.SetValueAt("Content", "MSH:4"))
   
   set expectedStream = ##class(%Stream.TmpCharacter).%New()
   do expectedStream.Write("This is some CONtent")
   
   // Expect them
   do ..Expect(..mathService.GetResult(..ByRefParam($$$NULLOREF, expectedHl7Message),
                                       ..NotNullObject(##class(EnsLib.XML.SearchTable).%ClassName(1)),
                                       ..IsEqualObject(expectedStream))
                                       ).AndReturn($$$OK)
   do ..ReplayAllMocks()
   
   // Start the test
   #Dim hl7Message As EnsLib.HL7.Message = $$$NULLOREF
   set searchTable = ##class(EnsLib.XML.SearchTable).%New() 
   do $$$AssertStatusOK(..testedClass.PopulateObjectProperties(.hl7Message, searchTable))
   do $$$AssertEquals(hl7Message.DocType, "2.6:ADT_A01")
   do $$$AssertTrue(hl7Message.GetValueAt("MSH:4") = "Content")
   
   do ..VerifyAllMocks()
}

}
