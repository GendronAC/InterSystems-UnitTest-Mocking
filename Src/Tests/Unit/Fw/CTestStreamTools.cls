Class Tests.Unit.Fw.CTestStreamTools Extends Tests.Fw.CUnitTestBase
{

Property streamTools As Fw.CStreamTools;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   set ..streamTools = ##class(Fw.CStreamTools).%New()
   
   quit $$$OK
}

// -- IsEqualStreams Tests -

Method TestIsEqualStreamsUndefined()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write("ABC"))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, $$$NULLOREF, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Undefined stream received")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams($$$NULLOREF, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Undefined stream received")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams($$$NULLOREF, $$$NULLOREF, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Undefined stream received")
}

Method TestIsEqualStreamsUnableToRewind()
{
   #Dim streamA As %Stream.Object = ..CreateMock()
   do ..Expect(streamA.Rewind()).AndReturn($$$ERROR("Unable to rewind")).Times(3)
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.Write("ABC"))
   
   do ..ReplayAllMocks()   
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Unable to initialise streams")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Unable to initialise streams")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Unable to initialise streams")
   
   do ..VerifyAllMocks()
}

Method TestIsEqualStreamsItemsSame()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write("ABC"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.Write("ABC"))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualStreamsCompareWithStartsWithStreamCompareTo()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.WriteLine("ABC"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.WriteLine("ABC"))
   do $$$AssertStatusOK(streamB.WriteLine("123"))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! ""123"" '= """"")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams line count are different")
}

Method TestIsEqualStreamsCompareToStartsWithStreamCompareWith()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.WriteLine("ABC"))
   do $$$AssertStatusOK(streamA.WriteLine("123"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.WriteLine("ABC"))

   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams line count are different")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! ""123"" '= """"")
}

Method TestIsEqualStreamsItemsSameEmpty()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write(""))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.Write(""))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualStreamsItemsSameNeverWritten()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   set streamB = ##class(%Stream.TmpCharacter).%New()
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualStreamsItemsSameOneEmptyOneNeverWritten()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write(""))
   set streamB = ##class(%Stream.TmpCharacter).%New()
      
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualStreamsItemsDifferent()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write("AAA"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.Write("ABC"))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! ""ABC"" '= ""AAA""")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! ""AAA"" '= ""ABC""")
}

Method TestIsEqualStreamsItemsDifferentOneEmpty()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write("ABC"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamB.Write(""))
      
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! """" '= ""ABC""")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "Streams not equal ! ""ABC"" '= """"")
}

Method TestIsEqualStreamsItemsDifferentOneNeverWritten()
{
   set streamA = ##class(%Stream.TmpCharacter).%New()
   do $$$AssertStatusOK(streamA.Write("ABC"))
   set streamB = ##class(%Stream.TmpCharacter).%New()
      
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamA, streamB, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "One of the variable is empty")
   do $$$AssertNotTrue(..streamTools.IsEqualStreams(streamB, streamA, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "One of the variable is empty")
}

}
