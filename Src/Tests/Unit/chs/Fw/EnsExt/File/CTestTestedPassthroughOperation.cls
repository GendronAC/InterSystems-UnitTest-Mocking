Include Ensemble

Class Tests.Unit.chs.Fw.EnsExt.File.CTestTestedPassthroughOperation Extends Tests.Fw.CUnitTestBase
{

Property operation As EnsLib.File.PassthroughOperation;

Property Adapter As EnsLib.File.OutboundAdapter;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest(testname As %String) As %Status
{
   set ..Adapter = ..CreateMock()
   set ..operation = ##class(chs.Fw.EnsExt.File.CTestedPassthroughOperation).%New("UnitTest", ..Adapter)
   set ..operation.Filename = "%f_%Q"
   
   quit $$$OK
}

// -- OnMessage tests --

Method TestOnMessage()
{
   set stream = ##class(%Stream.GlobalCharacter).%New()
   do stream.Write("Test")
   set ensStream = ##class(Ens.StreamContainer).%New(stream)
   set ensStream.OriginalFilename = "C:/Temp/Blah.txt"
      
   do ..Expect(..Adapter.FilePath).AndReturn("C:/Temp/")
   do ..Expect(..Adapter.CreateFilename("Blah.txt", "%f_%Q")).AndReturn("Blah.txt_20170901...txt")
   do ..Expect(..Adapter.PutStream("Blah.txt_20170901...txt", stream)).AndReturn($$$OK)
   do ..ReplayAllMocks()
   
   do $$$AssertStatusOK(..operation.OnMessage(ensStream, .out))
   
   do ..VerifyAllMocks()
}

Method TestOnMessageFailure()
{
   set stream = ##class(%Stream.GlobalCharacter).%New()
   do stream.Write("Test")
   set ensStream = ##class(Ens.StreamContainer).%New(stream)
   set ensStream.OriginalFilename = "C:/Temp/Blah.txt"
      
   do ..Expect(..Adapter.FilePath).AndReturn("C:/Temp/")
   do ..Expect(..Adapter.CreateFilename("Blah.txt", "%f_%Q")).AndReturn("Blah.txt_20170901...txt")
   do ..Expect(..Adapter.PutStream("Blah.txt_20170901...txt", stream)).AndReturn($$$ERROR($$$EnsErrGeneral, "PutStream() Rename failed with code 1"))
   do ..ReplayAllMocks()
   
   do $$$AssertStatusNotOK(..operation.OnMessage(ensStream, .out))
   
   do ..VerifyAllMocks()
}

}
