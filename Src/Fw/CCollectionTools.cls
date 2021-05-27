/// This class provides functions for lists, arrayOfDataTypes and all type of collection object
Class Fw.CCollectionTools Extends %RegisteredObject
{

Parameter notEqualReasonSeparator As %String = {$Char(10)};

ClassMethod ListToString(lstElements As %ListOfDataTypes, strElementSeparator As %String = ",") As %String
{
   #dim strReturnedString As %String = ""

   if ($IsObject(lstElements))
   {
      #Dim strKey As %String = lstElements.Next("")
      while (strKey '= "")
      {
         if ($LENGTH(strReturnedString) > 0)
         {
            set strReturnedString = strReturnedString _ strElementSeparator
         }

         set strReturnedString = strReturnedString _ lstElements.GetAt(strKey)
         set strKey = lstElements.Next(.strKey)
      }
   }

   quit strReturnedString
}

ClassMethod setListFromString(strList As %String, ByRef rlstElements As %ListOfDataTypes, strElementSeparator As %String = ",")
{
   set:(rlstElements = $$$NULLOREF) rlstElements = ##class(%ListOfDataTypes).%New()
   #dim lstOriginalList AS %List = $ListFromString(strList, strElementSeparator)
   #Dim i As %Integer = 0
   for i = 1 : 1 : $LISTLENGTH(lstOriginalList)
   {
      do rlstElements.Insert($LISTGET(lstOriginalList, i))
   }
}

ClassMethod GetListFromString(strList As %String, strElementSeparator As %String = ",") As %ListOfDataTypes
{
   set lstElements = ##class(%ListOfDataTypes).%New()
   do ..setListFromString(strList, .lstElements, strElementSeparator)
   quit lstElements
}

ClassMethod IsEqualList(ByRef lstA As %Collection.AbstractList, ByRef lstB As %Collection.AbstractList, Output strNotEqualReason As %String = "") As %Boolean
{
   quit ..IsEqualCollection(lstA, lstB, .strNotEqualReason)
}

/// toRemove peut être un object ou un datatype.
ClassMethod RemoveFromList(ByRef list As %ListOfDataTypes, toRemove) As %Status
{
   while (list.Find(toRemove))
   {
      do list.RemoveAt(list.Find(toRemove))
   }
   quit $$$OK
}

/// Le paramètre strNotEqualReason accumule des strings qui décrivent pourquoi les objets ne sont pas égaux.
/// Il est possible d'avoir plusieurs raisons pourquoi les objets ne sont pas égaux.
/// Les string qui décrivent ces raisons sont séparées par un $char(10) pour aider à la lecture.
/// 
/// NOTE : Supporte à la fois les %DynamicObject et %DynamicArray
ClassMethod DynamicObjectsAreEqual(original As %DynamicAbstractObject, comparedTo As %DynamicAbstractObject, ByRef strNotEqualReason As %String = "") As %Boolean
{
   #Dim areEqual As %Boolean = 0
   #Dim originalIsAtomic As %Boolean = ..DynamicObjectIsAtomic(original)
   #Dim comparedToIsAtomic As %Boolean = ..DynamicObjectIsAtomic(comparedTo)

   if (originalIsAtomic && comparedToIsAtomic)
   {
      set areEqual = 1
      if (original '= comparedTo)
      {
         set areEqual = 0
         do ..AppendNotEqualReason(.strNotEqualReason, "l'atome de référence '" _ original _ "' n'est pas égal à l'atome de comparaison '" _ comparedTo _ "'")
      }
   }
   elseif ((originalIsAtomic && 'comparedToIsAtomic) ||
           ('originalIsAtomic && comparedToIsAtomic))
   {
      #Dim strOriginalForMessage As %String = original
      if ('originalIsAtomic)
      {
         set strOriginalForMessage = original.%ToJSON()
      }

      #Dim strComparedToForMessage As %String = comparedTo
      if ('comparedToIsAtomic)
      {
         set strComparedToForMessage = comparedTo.%ToJSON()
      }

      set areEqual = 0
      do ..AppendNotEqualReason(.strNotEqualReason, "L'objet de référence :'" _ strOriginalForMessage _ "' et le comparé :'" _ strComparedToForMessage _ "' ne sont pas tout deux atomique, donc non égaux.")
   }
   else
   {
      if (original.%ClassName(1) '= comparedTo.%ClassName(1))
      {
         set areEqual = 0
         do ..AppendNotEqualReason(.strNotEqualReason, "L'objet de référence :'" _ original.%ToJSON() _ "' et le comparé:'" _ comparedTo.%ToJSON() _ "' ne sont pas de même nature, donc non égaux.")
      }
      else
      {
         #Dim sameNumberElemInArray As %Boolean = 1
         if (original.%IsA(##class(%DynamicArray).%ClassName(1)))
         {
            //Ici, on sait que original et comparedTo sont tous les deux des %DynamicArray
            #Dim nbrElemOriginal As %Integer = original.%Size()
            #Dim nbrElemComparedTo As %Integer = comparedTo.%Size()

            set sameNumberElemInArray = (nbrElemOriginal = nbrElemComparedTo)
            if ('sameNumberElemInArray)
            {
               do ..AppendNotEqualReason(.strNotEqualReason, "'" _ original.%ToJSON() _ "':(" _ nbrElemOriginal _ ") n'a pas le même nombre d'élément que '" _ comparedTo.%ToJSON() _ "':(" _ nbrElemComparedTo _ ")")
            }
         }

         if (..DynamicObjectKeyAreEqual(original, comparedTo, .strNotEqualReason))
         {
            #Dim nbrOfNotEqual As %Integer = 0
            #Dim iterator As %Iterator.Object = original.%GetIterator()
            #Dim originalKey, originalValue, comparedToValue
            while (iterator.%GetNext(.originalKey, .originalValue))
            {
               set comparedToValue = comparedTo.%Get(originalKey)
               if '(..DynamicObjectsAreEqual(originalValue, comparedToValue, .strNotEqualReason))
               {
                  set nbrOfNotEqual = nbrOfNotEqual + 1
               }
            }
            set areEqual = 'nbrOfNotEqual
         }
         set areEqual = (areEqual && sameNumberElemInArray)
      }
   }
   return areEqual
}

ClassMethod DynamicObjectKeyAreEqual(original As %DynamicAbstractObject, comparedTo As %DynamicAbstractObject, ByRef strNotEqualReason As %String = "") As %Boolean
{
   #Dim nrbDifferentKey As %Integer = 0
   #Dim sameNumberOfElement As %Boolean = (original.%Size() = comparedTo.%Size())
   if (sameNumberOfElement)
   {
      #Dim iterator As %Iterator.Object = original.%GetIterator()
      #Dim originalKey, originalValue
      while (iterator.%GetNext(.originalKey, .originalValue))
      {
         if '(comparedTo.%IsDefined(originalKey))
         {
            set nrbDifferentKey = nrbDifferentKey + 1
            do ..AppendNotEqualReason(.strNotEqualReason, "La clé """ _ originalKey _ """ de " _ original.%ToJSON() _ " ne se retrouve pas dans l'objet " _ comparedTo.%ToJSON() _ " avec lequel on compare")
         }
      }
   }
   else
   {
      do ..AppendNotEqualReason(.strNotEqualReason, original.%ToJSON() _ " n'a pas le même nombre de clés que " _ comparedTo.%ToJSON() _ ", ils sont donc non égaux")
   }

   return (sameNumberOfElement) && (nrbDifferentKey = 0)
}

ClassMethod DynamicObjectIsAtomic(obj As %DynamicAbstractObject) As %Boolean
{
   quit '$IsObject(obj)
}

// -- Private utils --

ClassMethod IsEqualCollection(objA As %RegisteredObject, objB As %RegisteredObject, Output strNotEqualReason As %String = "") As %Boolean [ Private ]
{
   set strNotEqualReason = ""
   #Dim bIsEqual as %Boolean = 1
   if ('$IsObject(objA) || '$IsObject(objB))
   {
      set strNotEqualReason = "One of the object is not valid"
      set bIsEqual = 0
   }
   elseif (objA.Count() '= objB.Count())
   {
      set strNotEqualReason = "Objet size not equals. 1st: " _ objA.Count() _ " 2nd: " _ objB.Count()
      set bIsEqual = 0
   }
   else
   {
      // Get first key
      #Dim strKey As %String = ""
      do objA.GetNext(.strKey)

      while (strKey '= "")
      {
         if ($IsObject(objA.GetAt(strKey)))
         {
            try
            {
               if ('(objA.GetAt(strKey).IsEqual(objB.GetAt(strKey))))
               {
                  set strNotEqualReason = "IsEqual returned false for items: " _ objA.GetAt(strKey) _ " ; " _  objB.GetAt(strKey) _ " at index: " _ strKey
                  set bIsEqual = 0
                  quit
               }
            }
            catch
            {
               set strNotEqualReason = "IsEqual not supported or crashed on item: " _ objA.GetAt(strKey) _ " at index: " _  strKey _ " of objA"
               set bIsEqual = 0
            }
         }
         // Not an object then it is a datatype.
         elseif (objA.GetAt(strKey) '= objB.GetAt(strKey))
         {
            set strNotEqualReason = "DataTypes not equal: " _ objA.GetAt(strKey) _ " '= " _  objB.GetAt(strKey) _ " at index: " _ strKey
            set bIsEqual = 0
            quit
         }

         // Get next key, if any
         do objA.GetNext(.strKey)
      }
   }
   quit bIsEqual
}

ClassMethod AppendNotEqualReason(ByRef strNotEqualReason As %String, strNewReason As %String) [ Private ]
{
   set strNotEqualReason = strNotEqualReason _ $Select(strNotEqualReason '= "" : ..#notEqualReasonSeparator, 1:"") _ strNewReason
}

}
