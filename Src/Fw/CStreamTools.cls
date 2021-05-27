Class Fw.CStreamTools Extends %RegisteredObject
{

/// Note : Does not care about the line endings, so the sizes are not compared.
ClassMethod IsEqualStreams(object As %Stream.Object, objectToCompare As %Stream.Object, Output strNotEqualReason As %String = "") As %Boolean
{
   #Dim bEqual As %Boolean = 0
   #Dim nChunkSize As %Integer = 100
   if ('$IsObject(object) || '$IsObject(objectToCompare))
   {
      set strNotEqualReason = "Undefined stream received"
   }
   elseif ('$$$ISOK(object.Rewind()) || '$$$ISOK(objectToCompare.Rewind()))
   {
      set strNotEqualReason = "Unable to initialise streams"
   }
   // This prevent from considering equal when one of the variable is empty.
   else
   {
      // This prevent from considering equal when one of the variable is empty.
      set bEqual = (objectToCompare.AtEnd = object.AtEnd)
      set:'bEqual bEqual = (objectToCompare.Size = object.Size)
      set:'bEqual strNotEqualReason = "One of the variable is empty"

      if ('objectToCompare.AtEnd && bEqual)
      {
         #Dim referenceLine As %String = ""
         #Dim testedLine As %String = ""
         while (('objectToCompare.AtEnd) && bEqual)
         {
            set referenceLine = objectToCompare.ReadLine(nChunkSize)
            set testedLine = object.ReadLine(nChunkSize)
            if (referenceLine '= testedLine)
            {
               set bEqual = 0
               set strNotEqualReason = "Streams not equal ! """ _ referenceLine _ """ '= """ _ testedLine _ """"
            }
         }

         if (bEqual && (objectToCompare.AtEnd '= object.AtEnd))
         {
            set bEqual = 0
            set strNotEqualReason = "Streams line count are different"
         }
      }
   }

   quit bEqual
}

}
