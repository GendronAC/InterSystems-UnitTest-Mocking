Class Fw.CResultSetTools [ Abstract ]
{

/// Used to retrieve a resultSet obtained by "%New". Testcases can override
/// the %ResultSet to return a CMockResultSet instead.
/// strQueryName is composed of "ClassName:QueryName" and can be omitted or empty.
ClassMethod GetNewResultSet(strQueryName As %String = "") As %ResultSet
{
   #Dim rs As %ResultSet = $$$NULLOREF

   try 
   {
      set rs = $ClassMethod("Tests.Fw.Mock.CMockManager", "GetMockResultSet", strQueryName)
   }
   catch
   {
      // Trying to access an undefined classmethod throws an error. Ignore it.
   }
   
   // If there are no defined CMockResultSet, create a standard one.
   set:('$IsObject(rs)) rs = ##class(%ResultSet).%New(strQueryName)   
   
   quit rs
}

}
