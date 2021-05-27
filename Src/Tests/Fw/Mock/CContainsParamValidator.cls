Class Tests.Fw.Mock.CContainsParamValidator Extends (%RegisteredObject, Tests.Fw.Mock.IMockParamValidator)
{

Property stringToLookFor;

Property bCaseInsensitive As %Boolean [ InitialExpression = 0 ];

Method %OnNew(stringToLookFor, bCaseInsensitive As %Boolean = 0) As %Status [ Internal ]
{
   set ..stringToLookFor = stringToLookFor
   set ..bCaseInsensitive = bCaseInsensitive

   quit $$$OK
}

Method Validate(stringToTest As %String) As %Status [ Internal ]
{
   #dim status As %Status = $$$ERROR("Contain")

   if ($data(stringToTest) && $IsObject(stringToTest) && $IsObject(..stringToLookFor))
   {
      set status = $$$ERROR("Object are not supported.")
   }
   // Else it is a datatype.
   elseif (..bCaseInsensitive && ($ZCVT(stringToTest,"U") [ $ZCVT(..stringToLookFor,"U")))
   {
      set status = $$$OK
   }
   elseif ('..bCaseInsensitive && (stringToTest [ ..stringToLookFor))
   {
      set status = $$$OK
   }

   quit status
}

Method GetAssertDescription(nIndex As %Integer, strMethodName As %String) As %String [ Internal ]
{

   quit "Expected Parameter(" _ nIndex _ ") contains """ _ ..stringToLookFor _ """ for method: " _ strMethodName _ " but was not found."
}

}
