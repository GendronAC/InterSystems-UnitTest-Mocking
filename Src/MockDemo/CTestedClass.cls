Import Fw

Class MockDemo.CTestedClass Extends %RegisteredObject
{

Property mathService As MathService [ Private ];

Method %OnNew(mathService As MathService = {##class(MathService).%New()}) As %Status [ Private, ServerOnly = 1 ]
{
   set ..mathService = mathService
   quit $$$OK
}

Method SumOperation(A As %Integer, B As %Integer) As %Integer
{
   quit ..mathService.Add(A, B)
}

Method ComplexOperation(A As %Integer, B As %Integer, ByRef status As %Status = {$$$OK}) As %Integer
{
   if (..mathService.GreaterThan(A, B))
   {
      quit ..mathService.Divide(A, B, .status)
   }
   else
   {
      quit ..mathService.Multiply(A, B, .status)
   }
}

Method FetchSQLQueryInformation(input As %String) As %String
{
   #Dim returnedValue As %String = ""
   
   #Dim rs As %ResultSet = ##class(CResultSetTools).GetNewResultSet($ClassName() _ ":MyQuery")
   do rs.Execute(input)
   if (rs.Next())
   {
      set returnedValue = rs.ResultA _ "+" _ rs.ResultB
   }
      
   quit returnedValue
}

Query MyQuery(input As %String) As %SQLQuery
{
   select 'A' As ResultA, :input As ResultB
}

Method FetchSQLPrepareInformation(input As %String) As %String
{
   #Dim returnedValue As %String = ""
   
   #Dim rs As %ResultSet = ##class(CResultSetTools).GetNewResultSet("")
   do rs.Prepare("select 'B' As ResultA, ? As ResultB")
   do rs.Execute(input)
   while (rs.Next())
   {
      set returnedValue = (returnedValue _ "|" _ rs.ResultA _ "+" _ rs.ResultB)
   }
   
   quit returnedValue
}

Method PopulateObjectProperties(ByRef hl7Message As EnsLib.HL7.Message, searchTable As EnsLib.XML.SearchTable) As %Status
{
   // Build a stream
   set expectedStream = ##class(%Stream.TmpCharacter).%New()
   do expectedStream.Write("This is some content")
   
   quit ..mathService.GetResult(.hl7Message, searchTable, expectedStream)
}

}
