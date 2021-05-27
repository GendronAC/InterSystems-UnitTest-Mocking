Import Fw

Class Tests.Unit.Fw.CTestHl7MessageTools Extends Tests.Fw.CUnitTestBase
{

Property strPropertyPath As %String [ InitialExpression = "MSH:MessageProfileIdentifier" ];

ClassMethod RunTests()
{
   do ##super()
}

// -- RemoveDateControlIDFromHL7 tests --

Method TestRemoveDateControlIDFromHL7InvalidInput()
{
   do $$$AssertStatusNotOK(##class(CHl7MessageTools).RemoveDateControlIDFromHL7($$$NULLOREF))
}

Method TestRemoveDateControlIDFromHL7EmptyInput()
{
   #Dim stream As %Stream.TmpCharacter = ##class(%Stream.TmpCharacter).%New()
   set stream.LineTerminator = $Char(1,2,3)
   do $$$AssertStatusOK(##class(CHl7MessageTools).RemoveDateControlIDFromHL7(.stream))
   do $$$AssertEquals(stream.Size, 0)
   do $$$AssertEquals(stream.LineTerminator, $Char(1,2,3))
}

Method TestRemoveDateControlIDFromHL7LineTerminatorChange()
{
   #Dim stream As %Stream.TmpCharacter = ##class(%Stream.TmpCharacter).%New()
   set stream.LineTerminator = $Char(1,2,3)
   do $$$AssertStatusOK(##class(CHl7MessageTools).RemoveDateControlIDFromHL7(.stream))
   do $$$AssertEquals(stream.Size, 0)
   do $$$AssertEquals(stream.LineTerminator, $Char(1,2,3))
}

Method TestRemoveDateControlIDFromHL7MSHContent()
{
   #Dim stream As %Stream.TmpCharacter = ##class(%Stream.TmpCharacter).%New()
   do stream.WriteLine("MSH|^~\&|||||20010203040506|||123456789|||||||||fr-CA")
   do stream.WriteLine("PID|1||DOEJ465621827^^^^RAMQ~325428^^^^PI||Doé^John|MotherName^Given")
   do $$$AssertStatusOK(##class(CHl7MessageTools).RemoveDateControlIDFromHL7(.stream))
   do $$$AssertEquals(stream.ReadLine(), "MSH|^~\&|||||||||||||||||fr-CA")
   do $$$AssertEquals(stream.ReadLine(), "PID|1||DOEJ465621827^^^^RAMQ~325428^^^^PI||Doé^John|MotherName^Given")
}

// -- AreEquals tests --

Method TestAreEquals()
{
   #Dim hl7Source As EnsLib.HL7.Message = ..GetHL7FromXData("TestAreEqualsMessageSource")
   #Dim strNotEqualReason As %String = ""
   
   #Dim hl7SourceTwin         As EnsLib.HL7.Message = ..GetHL7FromXData("TestAreEqualsMessageSource")
   do $$$AssertTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7SourceTwin, 1, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7SourceTwin, 0, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   
   #Dim hl7DifferentControlID As EnsLib.HL7.Message = ..GetHL7FromXData("TestAreEqualsMessageDifferentControlID")
   set strNotEqualReason = ""
   do $$$AssertTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentControlID, 1, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertNotTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentControlID, 0, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
   
   #Dim hl7DifferentDate As EnsLib.HL7.Message = ..GetHL7FromXData("TestAreEqualsMessageDifferentDate")
   set strNotEqualReason = ""
   do $$$AssertTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentDate, 1, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
   do $$$AssertNotTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentDate, 0, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
   
   #Dim hl7DifferentPID As EnsLib.HL7.Message = ..GetHL7FromXData("TestAreEqualsMessageDifferentPID")
   set strNotEqualReason = ""
   do $$$AssertNotTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentPID, 1, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
   do $$$AssertNotTrue(##class(CHl7MessageTools).AreEquals(hl7Source, hl7DifferentPID, 0, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

XData TestAreEqualsMessageSource
{
<CDATA>
MSH|^~\&|||||20010101010101||ADT^A04^ADT_A01|17073302|P|2.6
EVN|A04|20010101010101||||20010101020202|51216687
PID||ABCD12345678
PV1|
</CDATA>
}

XData TestAreEqualsMessageDifferentControlID
{
<CDATA>
MSH|^~\&|||||20010101010101||ADT^A04^ADT_A01|17073303|P|2.6
EVN|A04|20010101010101||||20010101020202|51216687
PID||ABCD12345678
PV1|
</CDATA>
}

XData TestAreEqualsMessageDifferentDate
{
<CDATA>
MSH|^~\&|||||20010101020202||ADT^A04^ADT_A01|17073302|P|2.6
EVN|A04|20010101010101||||20010101020202|51216687
PID||ABCD12345678
PV1|
</CDATA>
}

XData TestAreEqualsMessageDifferentPID
{
<CDATA>
MSH|^~\&|||||20010101010101||ADT^A04^ADT_A01|17073302|P|2.6
EVN|A04|20010101010101||||20010101020202|51216687
PID||ABCD98765432
PV1|
</CDATA>
}

}
