Class Tests.Fw.Mock.CIsEqualObjectParamValidator Extends (%RegisteredObject, Tests.Fw.Mock.IMockParamValidator)
{

Parameter strIsEqualNotImplemented = "IsEqual not implemented and not same object reference";

Property objectToCompare;

Method %OnNew(objectToCompare) As %Status [ Internal ]
{
   set ..objectToCompare = objectToCompare

   quit $$$OK
}

Method Validate(object) As %Status [ Internal ]
{
   #dim status As %Status = $$$ERROR("Not equal: "_ object _ " : " _ ..objectToCompare)

   if ($data(object) && $IsObject(object) && $IsObject(..objectToCompare))
   {
      try
      {
         set status = object.IsEqual(..objectToCompare)
      }
      catch
      {
         #Dim strNotEqualReason As %String = ""
         if (object.%Extends("%Collection.AbstractList") && ..objectToCompare.%Extends("%Collection.AbstractList"))
         {
            set status = $$$OK
            set status = $Case(##class(Fw.CCollectionTools).IsEqualList(object, ..objectToCompare, .strNotEqualReason),
                               1 : $$$OK,
                               0 : $$$ERROR(strNotEqualReason))
         }
         elseif (object.%Extends("%Stream.Object") && ..objectToCompare.%Extends("%Stream.Object"))
         {
            set status = $Case(##class(Fw.CStreamTools).IsEqualStreams(object, ..objectToCompare, .strNotEqualReason),
                               1 : $$$OK,
                               0 : $$$ERROR(strNotEqualReason))
         }
         elseif (object.%Extends("EnsLib.HL7.Message") && ..objectToCompare.%Extends("EnsLib.HL7.Message"))
         {
            set status = $Case(##class(Fw.CHl7MessageTools).AreEquals(object, ..objectToCompare, 1, .strNotEqualReason),
                               1 : $$$OK,
                               0 : $$$ERROR(strNotEqualReason))
         }
         elseif (object.%Extends("%Library.DynamicAbstractObject") && ..objectToCompare.%Extends("%Library.DynamicAbstractObject"))
         {
            set status = $Case(##class(Fw.CCollectionTools).DynamicObjectsAreEqual(object, ..objectToCompare, .strNotEqualReason),
                               1 : $$$OK,
                               0 : $$$ERROR(strNotEqualReason))
         }
         // If IsEqual is not implemented we try to compare OREF.
         elseif(..objectToCompare = object)
         {
            set status = $$$OK
         }
         else
         {
            set status = $$$ERROR(..#strIsEqualNotImplemented)
         }
      }
   }
   // Else it is a datatype.
   elseif (..objectToCompare = object)
   {
      set status = $$$OK
   }

   quit status
}

Method GetAssertDescription(nIndex As %Integer, strMethodName As %String) As %String [ Internal ]
{
   quit "Expected Parameter(" _ nIndex _ ") Equal for method: " _ strMethodName _ " Got not equal"
}

// addresses only listOfDataTypes for now

// we will try to make a completely generic object comparison with this method

Method ValidateObjectsAreEqual(originalObject, comparedObject) As %Boolean
{
   #Dim bObjectsAreEqual As %Boolean = 1

   if (originalObject.Count() '= comparedObject.Count())
   {
      set bObjectsAreEqual = 0
   }

   #Dim i As %Integer = 1
   while ((bObjectsAreEqual) &&
          (i <= originalObject.Count()))
   {
      set bObjectsAreEqual = (originalObject.GetAt(i) = comparedObject.GetAt(i))
      set i = i + 1
   }
   quit bObjectsAreEqual
}

}
