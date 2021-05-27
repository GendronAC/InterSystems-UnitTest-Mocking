Class Tests.Unit.CTestTestedClassWithoutInjection Extends Tests.Fw.CUnitTestBase
{

// --- Run test ---

Property testedClass As MockDemo.CTestedClassWithoutInjection [ Private ];

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   set ..testedClass = ##class(MockDemo.CTestedClassWithoutInjection).%New()
   quit $$$OK
}

// --- Tests for ComplexSumOperation ---

Method TestSumOperation()
{
   do $$$AssertEquals(..testedClass.SumOperation(1, 2), 3)
}

}
