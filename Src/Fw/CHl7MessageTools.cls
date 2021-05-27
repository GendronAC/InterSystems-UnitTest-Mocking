Class Fw.CHl7MessageTools [ Abstract ]
{

ClassMethod AreEquals(hl7MessageExpected As EnsLib.HL7.Message, hl7MessageProduced As EnsLib.HL7.Message, bOmitDateControlIDFromMSH As %Boolean = 1, ByRef strNotEqualReason As %String = "")
{
   set streamExpected = ##class(%Stream.TmpCharacter).%New()
   do hl7MessageExpected.OutputToLibraryStream(.streamExpected)
   do:bOmitDateControlIDFromMSH ..RemoveDateControlIDFromHL7(.streamExpected)

   set streamProducted = ##class(%Stream.TmpCharacter).%New()
   do hl7MessageProduced.OutputToLibraryStream(.streamProducted)
   do:bOmitDateControlIDFromMSH ..RemoveDateControlIDFromHL7(.streamProducted)

   quit ##class(Fw.CStreamTools).IsEqualStreams(streamProducted, streamExpected, .strNotEqualReason)
}

ClassMethod RemoveDateControlIDFromHL7(ByRef stream As %Stream.Object) As %Status
{
   #Dim status As %Status = $$$ERROR("Invalid stream input received")

   if ($IsObject(stream))
   {
      set filteredStream = ##class(%Stream.TmpCharacter).%New()
      set filteredStream.LineTerminator = stream.LineTerminator
      do stream.Rewind()

      while ('stream.AtEnd)
      {
         #Dim strLine As %String = stream.ReadLine()
         #Dim strSegment As %String = $Extract(strLine, 1, 3)

         // Remove MSH 7 and MSH 10 as they are a date and a control ID.
         if (strSegment = "MSH")
         {
            set:($Piece(strLine, "|", 7) '= "") $Piece(strLine, "|", 7) = ""
            set:($Piece(strLine, "|", 10) '= "") $Piece(strLine, "|", 10) = ""
         }
         do filteredStream.WriteLine(strLine)
      }
      set status = stream.CopyFrom(filteredStream)
      do stream.Rewind()
   }

   quit status
}

}
