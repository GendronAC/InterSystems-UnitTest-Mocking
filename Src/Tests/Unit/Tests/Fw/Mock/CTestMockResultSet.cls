Import Tests.Fw.Mock

Class Tests.Unit.Tests.Fw.Mock.CTestMockResultSet Extends Tests.Fw.CUnitTestBase
{

Property customResultSet As Tests.Fw.Mock.CMockResultSet;

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest() As %Status
{
   do ##super()

   set ..customResultSet = ##class(CMockResultSet).%New()

   quit $$$OK
}

// -- CreateFromXData tests --

Method TestCreateFromXData()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertTrue(..customResultSet.%IsA(##class(CMockResultSet).%ClassName(1)))
}

Method TestCreateFromXDataInvalid()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||UnknownXDATA")
   do $$$AssertNotTrue($IsObject(..customResultSet))
}

// -- Prepare tests --

Method TestPrepare()
{
   do $$$AssertStatusOK(..customResultSet.Prepare())
   do $$$AssertEquals(..customResultSet.%ROWCOUNT, 0)
   do $$$AssertStatusOK(..customResultSet.Prepare(123))
   do $$$AssertEquals(..customResultSet.%ROWCOUNT, 0)
}

// -- Execute tests --

Method TestExecute()
{
   do $$$AssertStatusOK(..customResultSet.Execute())
   do $$$AssertEquals(..customResultSet.%ROWCOUNT, 0)
   do $$$AssertStatusOK(..customResultSet.Execute(1, 2, 3))
   do $$$AssertEquals(..customResultSet.%ROWCOUNT, 0)
}

// -- Next tests --

Method TestNextNoData()
{
   do $$$AssertEquals(..customResultSet.Next(), 0)
}

Method TestNextWithData()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.Next(), 1)
   do $$$AssertEquals(..customResultSet.Next(), 1)
   do $$$AssertEquals(..customResultSet.Next(), 0)
}

// -- %DispatchGetProperty tests --

Method TestDispatchGetProperty()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.Next(), 1)
   do $$$AssertEquals(..customResultSet.FacilityID, "C")
   do $$$AssertEquals(..customResultSet.Name, "Centre < hospitalier")
   do $$$AssertEquals(..customResultSet.ShortName, "CHUS")
   do $$$AssertEquals(..customResultSet.SiteCode, "123456")
   do $$$AssertEquals(..customResultSet.Next(), 1)
   do $$$AssertEquals(..customResultSet.FacilityID, "D")
   do $$$AssertEquals(..customResultSet.Name, "Ailleurs très loin")
   do $$$AssertEquals(..customResultSet.ShortName, "FAR")
   do $$$AssertEquals(..customResultSet.SiteCode, "-")
   do $$$AssertEquals(..customResultSet.Next(), 0)
   do $$$AssertEquals(..customResultSet.FacilityID, "")
   do $$$AssertEquals(..customResultSet.Name, "")
   do $$$AssertEquals(..customResultSet.ShortName, "")
   do $$$AssertEquals(..customResultSet.SiteCode, "")
}

Method TestDispatchGetPropertyCaseInsensitive()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.Next(), 1)

   do $$$AssertEquals(..customResultSet.fAcIlItYID, "C")
}

Method TestDispatchGetPropertyNoData()
{
   do $$$AssertEquals(..customResultSet.UndefinedProperty, "")
}

// -- GetColumnCount tests -

Method TestGetColumnCount()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.GetColumnCount(), 4)
}

Method TestGetColumnCountNoData()
{
   do $$$AssertEquals(..customResultSet.GetColumnCount(), 0)
}

// -- GetColumnName tests -

Method TestGetColumnName()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.GetColumnName(1), "FacilityID")
   do $$$AssertEquals(..customResultSet.GetColumnName(2), "Name")
   do $$$AssertEquals(..customResultSet.GetColumnName(3), "ShortName")
   do $$$AssertEquals(..customResultSet.GetColumnName(4), "SiteCode")
}

Method TestGetColumnNameNoData()
{
   do $$$AssertEquals(..customResultSet.GetColumnName(1), "")
}

// -- GetData tests -

Method TestGetData()
{
   set ..customResultSet = ##class(CMockResultSet).CreateFromXData(..%ClassName(1)_"||SampleXDATA")
   do $$$AssertEquals(..customResultSet.Next(), 1)
   do $$$AssertEquals(..customResultSet.GetData(1), "C")
   do $$$AssertEquals(..customResultSet.GetData(2), "Centre < hospitalier")
   do $$$AssertEquals(..customResultSet.GetData(3), "CHUS")
   do $$$AssertEquals(..customResultSet.GetData(4), "123456")
}

Method TestGetDataNoData()
{
   do $$$AssertEquals(..customResultSet.GetData(1), "")
}

// -- Compare Columns --

Method TestCompareColumnsSame()
{
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATACompare"

   do $$$AssertTrue(##class(Tests.Fw.Mock.CMockResultSet).CompareColumns(queryName, xDataName))
}

Method TestCompareColumnsDifferent()
{
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATA"
   #Dim err As %Exception.General
   #Dim bExceptionThrown as %Boolean = 0

   try
   {
      do $$$AssertNotTrue(##class(Tests.Fw.Mock.CMockResultSet).CompareColumns(queryName, xDataName))
   }
   CATCH err
   {
      // On s'assure qu'on a la bonne erreur, c-a-d que les colonnes du xdata ne sont pas dans ceux de la query et vice-versa
      if (err.DisplayString() = "Colonnes manquantes de la Query Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery : FACILITYID;NAME;SHORTNAME;SITECODE Colonnes manquantes du XData Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATA : ID;RESULT;REQUEST;COMMANDTIME")
         set bExceptionThrown = 1
   }

   do $$$AssertTrue(bExceptionThrown)
}

Method TestCompareColumnsDifferentMissingQuery()
{
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery123"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATA"
   #Dim err As %Exception.General

   #Dim bExceptionThrown as %Boolean = 0

   TRY
   {
      do $$$AssertNotTrue(##class(Tests.Fw.Mock.CMockResultSet).CompareColumns(queryName, xDataName))
   }
   CATCH err
   {
      set bExceptionThrown = 1
   }

   do $$$AssertTrue(bExceptionThrown)
}

Method TestCompareColumnsDifferentMissingXData()
{
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATA123"
   #Dim err As %Exception.General
   #Dim bExceptionThrown as %Boolean = 0

   TRY
   {
      do $$$AssertNotTrue(##class(Tests.Fw.Mock.CMockResultSet).CompareColumns(queryName, xDataName))
   }
   CATCH err
   {
      set bExceptionThrown = 1
   }

   do $$$AssertTrue(bExceptionThrown)
}

Method TestCompareColumnsDifferentMissingBoth()
{
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery123"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATA123"
   #Dim err As %Exception.General

   #Dim bExceptionThrown as %Boolean = 0

   TRY
   {
      do $$$AssertTrue(##class(Tests.Fw.Mock.CMockResultSet).CompareColumns(queryName, xDataName))
   }
   CATCH err
   {
      if (err.DisplayString() = "Colonnes XData vides")
         set bExceptionThrown = 1
   }

   do $$$AssertTrue(bExceptionThrown)
}

// -- GetColumnsFromQuery --

Method TestGetColumnsFromQuery()
{
   #Dim expectedColumns as %String = ";ID;result;request;commandTime"
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery" // Pckg.class:query
   #Dim result as %String = ##class(Tests.Fw.Mock.CMockResultSet).GetColumnsFromQuery(queryName)
   do $$$AssertEquals(expectedColumns, result)
}

Method TestGetColumnsFromQueryMissing()
{
   #Dim expectedColumns as %String = ";ID;result;request;commandTime"
   #Dim queryName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleQuery123" // Pckg.class:query

   do $$$AssertNotEquals(expectedColumns, ##class(Tests.Fw.Mock.CMockResultSet).GetColumnsFromQuery(queryName))
}

// -- GetColumnsFromXData --

Method TestGetColumnsFromXData()
{
   #Dim expectedColumns as %String = ";ID;result;request;commandTime"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATACompare" // Pckg.class:XData

   do $$$AssertEquals(expectedColumns, ##class(Tests.Fw.Mock.CMockResultSet).GetColumnsFromXData(xDataName))
}

Method TestGetColumnsFromXDataMissing()
{
   #Dim expectedColumns as %String = ";ID;result;request;commandTime"
   #Dim xDataName as %String = "Tests.Unit.Tests.Fw.Mock.CTestMockResultSet:SampleXDATACompare123" // Pckg.class:XData

   do $$$AssertNotEquals(expectedColumns, ##class(Tests.Fw.Mock.CMockResultSet).GetColumnsFromXData(xDataName))
}

Query SampleQuery() As %SQLQuery
{
   SELECT '1' as ID, '2' as result,'3' as request,'4' as commandTime
}

XData SampleXDATA
{
<Query>
<ColumnsNames>;FacilityID;Name;ShortName;SiteCode</ColumnsNames>
<Row>C;Centre &lt; hospitalier;CHUS;123456</Row>
<Row>D;Ailleurs très loin;FAR;-</Row>
</Query>
}

XData SampleXDATACompare
{
<Query>
<ColumnsNames>;ID;result;request;commandTime</ColumnsNames>
<Row>;ID;result;request;commandTime</Row>
</Query>
}

}
