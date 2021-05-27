Class Tests.Fw.Mock.CMockResultSet Extends (%RegisteredObject, %XML.Adaptor)
{

Parameter XMLNAME = "Query";

Property strColumnNames As %String(MAXLEN = 1000, XMLNAME = "ColumnsNames", XMLPROJECTION = "ELEMENT");

Property rows As list Of %String(MAXLEN = 5000, XMLNAME = "Row", XMLPROJECTION = "ELEMENT") [ Private ];

Property %ROWCOUNT As %Integer(XMLPROJECTION = "NONE") [ InitialExpression = 0 ];

Method %OnNew(lstRows As %ListOfDataTypes = {##class(%ListOfDataTypes).%New()}) As %Status [ Private, ServerOnly = 1 ]
{
   set ..rows = lstRows
   Quit $$$OK
}

/// Exemple d'appels :
/// set rs = ##class(%ResultSet).%New("chs.Fw.Qcpr.Services.CFacilityService:SqlGetFacilityInfo")
/// do rs.Execute(1)
/// do ##class(Tests.Fw.Mock.CMockResultSet).DumpXDataFromResultSet(rs)
/// 
/// ou
/// 
/// set rs = ##class(%ResultSet).%New()
/// do rs.Prepare("Select ShortName from chs_Fw_Qcpr_Sql_View.Facility where FacilityID = ?")
/// do rs.Execute(1)
/// do ##class(Tests.Fw.Mock.CMockResultSet).DumpXDataFromResultSet(rs)
ClassMethod DumpXDataFromResultSet(rs As %ResultSet, separator As %String = ";")
{
   set xData = ##class(%Stream.TmpCharacter).%New()

   do xData.WriteLine("XData xDataName")
   do xData.WriteLine("{")
   do xData.WriteLine("<Query>")
   do xData.Write("<ColumnsNames>")

   #Dim i As %Integer = 0
   for i = 1:1:rs.GetColumnCount()
   {
      do xData.Write(separator _ rs.GetColumnName(i))
   }

   do xData.WriteLine("</ColumnsNames>")
   while (rs.Next())
   {
      do xData.Write("<Row>")
      if (rs.GetData(i) [ separator)
      {
         write "ATTENTION : les données contiennent le séparateur """ _ separator _ """. SVP en choisir un autre !"
         return
      }
      for i = 1:1:rs.GetColumnCount() do xData.Write(rs.GetData(i) _ separator)
      do xData.WriteLine("</Row>")
   }
   do xData.WriteLine("</Query>")
   do xData.WriteLine("}")

   do xData.OutputToDevice()
}

ClassMethod CreateFromXData(xDataName As %String) As Tests.Fw.Mock.CMockResultSet
{
   #Dim customResultSet As Tests.Fw.Mock.CMockResultSet = $$$NULLOREF

   set xData = ##class(%Dictionary.CompiledXData).%OpenId(xDataName)
   set reader = ##class(%XML.Reader).%New()
   if $IsObject(xData) && $$$ISOK(reader.OpenStream(xData.Data))
   {
      do reader.Correlate(..#XMLNAME, ..%ClassName(1))
      do reader.Next(.customResultSet)
   }

   quit customResultSet
}

Method Prepare(args...) As %Status
{
   set ..%ROWCOUNT = 0
   quit $$$OK
}

Method Execute(args...) As %Status
{
   set ..%ROWCOUNT = 0
   quit $$$OK
}

/// Advance the result set cursor to the next row. Returns 0 if the cursor is at the end of the
/// result set.
Method Next(ByRef sc As %Status) As %Integer
{

   set ..%ROWCOUNT = ..%ROWCOUNT + 1

   quit (..%ROWCOUNT <= ..rows.Count())
}

Method %DispatchGetProperty(pProperty As %String)
{
   #Dim returnValue As %String = ""
   if ((..%ROWCOUNT > 0) && (..%ROWCOUNT <= ..rows.Count()))
   {
      set returnValue = ..GetData($ListFind(..GetColumnNamesList($ZConvert(..strColumnNames, "U")), $ZConvert(pProperty,"U")))
   }
   quit returnValue
}

/// Returns the number of rows in the result set.
Method GetRowCount() As %Integer
{
   quit ..rows.Count()
}

/// Returns the number of columns in the result set.
Method GetColumnCount() As %Integer
{
   quit $ListLength(..GetColumnNamesList(..strColumnNames))
}

/// Returns the name of column <var>nIndex</var> in the result set.
Method GetColumnName(nIndex As %Integer) As %String
{
   #Dim strColumnName As %String = ""
   try
   {
      set strColumnName = $List(..GetColumnNamesList(..strColumnNames), nIndex)
   }
   catch
   {
      // $List throws an error if nIndex is 0 or when given an empty list, this is annoying.
   }
   quit strColumnName
}

/// Returns the value of column <var>nIndex</var> in the current row of the result set.
Method GetData(nIndex As %Integer) As %String
{
   #Dim strData As %String = ""

   try
   {
      set strData = $List($ListFromString(..rows.GetAt(..%ROWCOUNT), ..GetSeparator()), nIndex)
   }
   catch
   {
      // $List throws an error if nIndex is 0 or when given an empty list, this is annoying.
   }

   quit strData
}

Method GetDataByName(name As %String) As %String
{
   quit ..%DispatchGetProperty(name)
}

// -- Helper --

Method GetSeparator() As %Char [ Private ]
{
   quit $Extract(..strColumnNames, 1, 1)
}

Method GetColumnNamesList(strColumnNames As %String) As %List [ Private ]
{
   quit $ListFromString($Extract(strColumnNames, 2, *), ..GetSeparator())
}

/// Compares the column names of a query and an XData to see if they are the same
/// Format for queryName = "Package.Class:Query"
/// Format for xDataName = "Package.Class:XData"
ClassMethod CompareColumns(queryName As %String, xDataName As %String) As %Boolean
{
   // If no query is given, this means that the ".Prepare" part of the MockResultSet is used, we can't
   // compare columns with the mocked resultSet
   quit:queryName="" 1

   #Dim xDataColumns as %String = ..GetColumnsFromXData(xDataName)
   #Dim queryColumns as %String = ..GetColumnsFromQuery(queryName)

   throw:(xDataColumns="") ##class(%Exception.General).%New("XData columns are empty")
   throw:(queryColumns="") ##class(%Exception.General).%New("Query columns are empty")

   #Dim listResultQuery as %ListOfDataTypes = ##class(Fw.CCollectionTools).GetListFromString($E($ZCONVERT(queryColumns,"U"), 2, *), $E(queryColumns, 1))
   #Dim listResultXData as %ListOfDataTypes = ##class(Fw.CCollectionTools).GetListFromString($E($ZCONVERT(xDataColumns,"U"), 2, *), $E(xDataColumns, 1))

   #Dim listRemainderXData as %ListOfDataTypes = listResultXData.%ConstructClone()
   #Dim listRemainderQuery as %ListOfDataTypes = listResultQuery.%ConstructClone()

   #Dim i as %Integer = 0

   for i=1:1:listResultQuery.Count()
   {
      do ##class(Fw.CCollectionTools).RemoveFromList(.listRemainderXData, listResultQuery.GetAt(i))
   }

   for i=1:1:listResultXData.Count()
   {
      do ##class(Fw.CCollectionTools).RemoveFromList(.listRemainderQuery, listResultXData.GetAt(i))
   }

   if ( (listRemainderXData.Count() > 0) || (listRemainderQuery.Count() > 0) )
   {
      #Dim message as %String = ""
      set:(listRemainderXData.Count() > 0) message = message _ "Colonnes manquantes de la Query " _ queryName _ " : " _ $Replace(##class(Fw.CCollectionTools).ListToString(listRemainderXData), ",", ";")
      set:(listRemainderQuery.Count() > 0) message = message _ " Colonnes manquantes du XData " _ xDataName _ " : " _ $Replace(##class(Fw.CCollectionTools).ListToString(listRemainderQuery), ",", ";")

      throw ##class(%Exception.General).%New(message)
   }

   quit 1
}

/// Returns a string containing the value of the first <ColumnsNames> value of an XData sorted alphabetically
/// Format for xDataName = "Package.Class:XData"
ClassMethod GetColumnsFromXData(xDataName As %String) As %String
{
   #Dim line as %String = ""
   #Dim columnsName = ""

   // On regarde si le XData existe
   if (##class(%Dictionary.XDataDefinition).%ExistsId($Replace(xDataName, ":", "||")))
   {
      // On load le contenu du XData
      set xDataStream = ##class(%Dictionary.XDataDefinition).%OpenId($Replace(xDataName, ":", "||")).Data

      // On cherche pour la ligne contenant <ColumnsNames> pour ensuite comparer les valeurs
      do
      {
         set line = xDataStream.ReadLine()

         if ($P(line,"<ColumnsNames>",2) '= "")
         {
            // On garde la valeur des colonnes a comparer
            set columnsName = ($P($P(line, ">",2),"<",1))
            quit
         }
      } while (line '= "")
   }
   else
   {
      write "XData " _ xDataName _ " not found!",!
   }

   quit columnsName
}

/// Returns a string containing the column names of a SQL query
/// Format for queryName = "Package.Class:QueryName"
ClassMethod GetColumnsFromQuery(queryName As %String) As %String
{
   set resultSet = ##class(%ResultSet).%New("Tests.Fw.Mock.CMockResultSet:GetQueryColumnsName")

   #Dim status as %Status = resultSet.Execute(queryName)
   #Dim queryColumns as %String = ""

   if ($$$ISOK(status))
   {
      // Si la query retourne un résultat
      if (resultSet.Next())
      {
         set queryColumns = (";" _ resultSet.ColNames)
      }
   }
   else
   {
      do $System.OBJ.DisplayError(status)
   }

   quit queryColumns
}

/// SQL Query that returns a list of strings containing the column names of a given SQL query
/// Format for className = "Package.Class"
/// Format for queryName = "QueryName"
Query GetQueryColumnsName(query As %String) As %SQLQuery
{
   SELECT
   $ListToString(colNames,';') as ColNames
   FROM %Dictionary.CompiledQuery
   where parent = $Piece(:query , ':', 1)
   and Name = $Piece(:query , ':', 2)
}

}
