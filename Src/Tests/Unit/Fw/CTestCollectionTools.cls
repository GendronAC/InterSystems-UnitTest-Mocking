Import (Tests.Fw, Tests.Fw.Mock)

Class Tests.Unit.Fw.CTestCollectionTools Extends Tests.Fw.CUnitTestBase
{

Parameter keyToRemove As %String = "ark";

Parameter searchedKey As %String = "goo";

Parameter replaceByKey As %String = "gorf";

Property collectionTools As Fw.CCollectionTools [ Private ];

ClassMethod RunTests()
{
   do ##super()
}

Method OnBeforeOneTest() As %Status
{
   set ..collectionTools = ##class(Fw.CCollectionTools).%New()

   quit $$$OK
}

// -- DynamicObjectsAreEqual tests --

Method TestDynamicObjectsAreEqual()
{
   #Dim originalDynamicObjects As %DynamicObject = ##class(%DynamicObject).%FromJSON(..GetXDataPayload("testOriginals").Read(100000))
   #Dim comparedToDynamicObjects As %DynamicObject = ##class(%DynamicObject).%FromJSON(..GetXDataPayload("testComparedTo").Read(100000))
   #Dim expectedResultOfAreEqual As %DynamicObject = ##class(%DynamicObject).%FromJSON(..GetXDataPayload("expectedResultOfTestCase").Read(100000))
   #Dim expectedNotEqualReasonMessage As %DynamicObject = ##class(%DynamicObject).%FromJSON(..GetXDataPayload("expectedNotEqualReasonOfTestCase").Read(100000))
   
   #Dim iterator As %Iterator.Object = originalDynamicObjects.%GetIterator()
   #Dim testCase As %String = ""
   #Dim original As %DynamicObject = $$$NULLOREF
   #Dim comparedTo As %DynamicObject = $$$NULLOREF
   #Dim expectedAreEqual As %Boolean = 0
   #Dim lstExpectedNotEqualReason As %DynamicArray = $$$NULLOREF
   #Dim expectedNotEqualReason As %String = ""
   while (iterator.%GetNext(.testCase, .original))
   {
      set comparedTo = comparedToDynamicObjects.%Get(testCase)
      set expectedAreEqual = expectedResultOfAreEqual.%Get(testCase)
      set lstExpectedNotEqualReason = expectedNotEqualReasonMessage.%Get(testCase)
      
      #Dim notEqualReason As %String = ""
      if (expectedAreEqual)
      {
         do $$$AssertTrue(..collectionTools.DynamicObjectsAreEqual(original, comparedTo, .notEqualReason), notEqualReason)
      }
      else
      {
         do $$$AssertNotTrue(..collectionTools.DynamicObjectsAreEqual(original, comparedTo, .notEqualReason), notEqualReason)
         
         #Dim strMessageModificator As %String = ""
         #Dim notEqualReasonList = $ListFromString(notEqualReason, ..collectionTools.#notEqualReasonSeparator)
         #Dim notEqualReasonIndex As %Integer = 0
         
         #Dim ptr = 0
         while $listNext(notEqualReasonList, ptr, notEqualReason)
         {
            set expectedNotEqualReason = lstExpectedNotEqualReason.%Get(notEqualReasonIndex)
            
            if ((notEqualReason '= "") &&
                (expectedNotEqualReason '= ""))
            {
               set strMessageModificator = "ne contient pas "
               if (notEqualReason [ expectedNotEqualReason)
               {
                  set strMessageModificator = "contient "
               }
               do $$$AssertTrue((notEqualReason [ expectedNotEqualReason), "The 'notEqualReason':'" _ notEqualReason _ "'"_ $char(10) _ strMessageModificator _ "la sous chaîne:'" _ expectedNotEqualReason _ "'")
            }
            set notEqualReasonIndex = notEqualReasonIndex + 1
         }
         do $$$AssertEquals(lstExpectedNotEqualReason.%Size(), $ListLength(notEqualReasonList))
      }
   }
}

// -- GetListFromString tests --

Method TestGetListFromString()
{
   #Dim strList As %String = "1-BcCD--345 A;"
   #Dim list As %ListOfDataTypes = ..collectionTools.GetListFromString(strList, "-")
   do $$$AssertEquals(list.GetAt(1), 1)
   do $$$AssertEquals(list.GetAt(2), "BcCD")
   do $$$AssertEquals(list.GetAt(3), "")
   do $$$AssertEquals(list.GetAt(4), "345 A;")
}

// -- IsEqualList tests --

Method TestIsEqualListFirstListBigger()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

Method TestIsEqualListSecondListBigger()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

Method TestIsEqualListEmptyLists()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   set lstTwo = ##class(%ListOfDataTypes).%New()
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualListDataTypesNotEqual()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(2))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

Method TestIsEqualListSecondDataTypesNotEqual()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   do $$$AssertStatusOK(lstOne.Insert(2))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   do $$$AssertStatusOK(lstTwo.Insert(3))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

Method TestIsEqualListDataTypesEqual()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstOne.Insert(1))
   do $$$AssertStatusOK(lstOne.Insert(2))
   set lstTwo = ##class(%ListOfDataTypes).%New()
   do $$$AssertStatusOK(lstTwo.Insert(1))
   do $$$AssertStatusOK(lstTwo.Insert(2))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertEquals(strNotEqualReason, "")
}

Method TestIsEqualListObjectNoIsEqualMethod()
{
   set lstOne = ##class(%ListOfObjects).%New()
   do $$$AssertStatusOK(lstOne.Insert(##class(%Stream.TmpCharacter).%New("")))
   set lstTwo = ##class(%ListOfObjects).%New()
   do $$$AssertStatusOK(lstTwo.Insert(##class(%Stream.TmpCharacter).%New("")))
   
   #Dim strNotEqualReason As %String = ""
   do $$$AssertNotTrue(..collectionTools.IsEqualList(lstOne, lstTwo, .strNotEqualReason))
   do $$$AssertNotEquals(strNotEqualReason, "")
}

Method TestIsEqualListNoStatusPassed()
{
   set lstOne = ##class(%ListOfDataTypes).%New()
   set lstTwo = ##class(%ListOfDataTypes).%New()
   
   do $$$AssertTrue(..collectionTools.IsEqualList(lstOne, lstTwo))
}

// -- ListToString tests --

Method TestListToString()
{
   set list = ##class(%ListOfDataTypes).%New()
   do list.Insert(1)
   do list.Insert("BcCD")
   do list.Insert("")
   do list.Insert("345 A;")
   do $$$AssertEquals(..collectionTools.ListToString(list, "-"), "1-BcCD--345 A;")
}

// -- RemoveFromList tests -- 

Method TestRemoveFromList()
{
   set testList = ##class(%ListOfDataTypes).%New()
   do testList.Insert("A")
   do testList.Insert("B")
   do testList.Insert("")
   do testList.Insert("D")
   do testList.Insert("A")
   
   do $$$AssertEquals(testList.Count(), 5)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, "C"))
   do $$$AssertEquals(testList.Count(), 5)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, ""))
   do $$$AssertEquals(testList.Count(), 4)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, "A"))
   do $$$AssertEquals(testList.Count(), 2)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, "B"))
   do $$$AssertEquals(testList.Count(), 1)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, "D"))
   do $$$AssertEquals(testList.Count(), 0)
   do $$$AssertStatusOK(..collectionTools.RemoveFromList(.testList, "B"))
   do $$$AssertEquals(testList.Count(), 0)
}

// -- setListFromString tests --

Method TestSetListFromString()
{
   #Dim strList As %String = "1-BcCD--345 A;"
   #Dim list As %ListOfDataTypes = $$$NULLOREF
   do ..collectionTools.setListFromString(strList, .list, "-")
   do $$$AssertEquals(list.GetAt(1), 1)
   do $$$AssertEquals(list.GetAt(2), "BcCD")
   do $$$AssertEquals(list.GetAt(3), "")
   do $$$AssertEquals(list.GetAt(4), "345 A;")
}

XData testOriginals
{
<CDATA>
{
   "caseAreEqual":
   {
      "a":"b",
      "jim":"dunlop",
      "auto":
      {
         "toyota":"corolla",
         "honda":"crv"
      },
      "enum":[1, 2, 3, 4]
   },
   
   "caseDifferentNumberOfKeys":
   {
      "foo":"f",
      "goo":"g",
      "vlad":"kozlovf",
      "bar":"b"
   },
   
   "caseKeyNotFound":
   {
      "bahds":
      {
         "aix":"sponsa",
         "branta":"canadensis"
      },
      "gulo":"gulo",
      "alces":"alces",
      "salvelinus":"fontinalis",
      "salmo":"salar"
   },
   
   "caseDifferentAtomicValue":
   {
      "gymnosperm":
      {  
         "picea":"mariana",
         "abies":"balsamea",
         "pinus":"strobus"
      },
      "angiosperm":
      {
         "tilia":"americana",
         "juglans":"nigra",
         "quercus":"rubra"
      }
   },
   
   "caseNotMutuallyAtomicObjects":
   {
      "firstObject":"atomic",
      "secondObject":[1, 2, 3],
      "thirdObject":
      {
         "not":"atomic",
         "jim":"dunlop"
      }
   },
   
      "caseObjectComparedNotSameType":
   {
      "anArray":["a", "b", "c", "d"],
      "anObject":
      {
         "first":"firstValue",
         "second":"secondValue"
      } 
   }, 
   
   "caseDifferentNbrOfElemInArray":
   {
      "testNbrElemInArray":["an", "array", "with", "five", "elems"],
      "testSameNbrElemInArray":[1, 2, 3]
   }, 
   
   "caseMultipleDifferences":
   {  
      "a":["b",["3","2"],{"ab":"b","g":[4,{"5":6},2]}],
      "aa":"jim",
      "cle":{
         "flet":"tan",
         "broc":"het",
         "salve":"linus"
      },
      "differentNbOfKey":
      {
         "keyOne":"first",
         "keyTwo":"second"
      }
   }
}
</CDATA>
}

XData testComparedTo
{
<CDATA>
{
   "caseAreEqual":
   {
      "jim":"dunlop",
      "a":"b",
      "enum":[1, 2, 3, 4],
      "auto":
      {
         "honda":"crv",
         "toyota":"corolla"
      }
   },
   "caseDifferentNumberOfKeys":
   {
      "goo":"g",
      "garf":"gorf",
      "foo":"f",
      "bar":"b",
      "vlad":"kozlovf"
   },
   
   "caseKeyNotFound":
   {
      "salvelinus":"fontinalis",
      "salmo":"salar",
      "alces":"alces",
      "gulo":"gulo",
      "bahds":
      {
         "anas":"platyrynchos",
         "aix":"sponsa"
      }
   },
   
   "caseDifferentAtomicValue":
   {
      "angiosperm":
      {
         "tilia":"americana",
         "quercus":"rubra",
         "juglans":"cinerea"
      },
      "gymnosperm":
      {  
         "picea":"mariana",
         "pinus":"banksiana",
         "abies":"balsamea"
      }
   },
   
   "caseNotMutuallyAtomicObjects":
   {
      "firstObject":"atomic",
      "secondObject":"notAnArray",
      "thirdObject":"notAnObject"
   },
   
   "caseObjectComparedNotSameType":
   {
      "anArray":
      {
         "not":"an",
         "array":"is",
         "an":"object"
      },
      "anObject":["not", "an", "object", "is", "an", "array"]
   },
   
   "caseDifferentNbrOfElemInArray":
   {
      "testSameNbrElemInArray":[1, 2, 3],
      "testNbrElemInArray":["an", "array", "with", "five", "elems", "plusOne"]
   },
   
   "caseMultipleDifferences":
   {
      "differentNbOfKey":
      {
         "keyOne":"first",
         "keyTwo":"second",
         "keyThree":"third"
      },
      "cle":{
         "salve":"linuus",
         "flet":"tan",
         "broc":"het"
      },
      "a":["b",["3","1"],{"a":"b","g":[4,{"5":6},2]}],
      "aa":"jim"
   }
}
</CDATA>
}

XData expectedResultOfTestCase
{
<CDATA>
{  
   "caseAreEqual":1,
   "caseDifferentNumberOfKeys":0,
   "caseKeyNotFound":0,
   "caseDifferentAtomicValue":0,
   "caseNotMutuallyAtomicObjects":0,
   "caseObjectComparedNotSameType":0,
   "caseDifferentNbrOfElemInArray":0,
   "caseMultipleDifferences":0
}
</CDATA>
}

XData expectedNotEqualReasonOfTestCase
{
<CDATA>
{  
   "caseAreEqual":[""],
   "caseDifferentNumberOfKeys":["n'a pas le même nombre de clés que"],
   "caseKeyNotFound":["ne se retrouve pas dans l'objet"],
   "caseDifferentAtomicValue":
   ["n'est pas égal à l'atome de comparaison",
    "n'est pas égal à l'atome de comparaison"],
   "caseNotMutuallyAtomicObjects":
   ["ne sont pas tout deux atomique",
    "ne sont pas tout deux atomique"],
   "caseObjectComparedNotSameType":
   ["ne sont pas de même nature",
    "ne sont pas de même nature"],
   "caseDifferentNbrOfElemInArray":
   ["n'a pas le même nombre d'élément que",
    "n'a pas le même nombre de clés que"
   ],
   "caseMultipleDifferences":
   ["n'est pas égal à l'atome de comparaison",
    "ne se retrouve pas dans l'objet",
    "n'est pas égal à l'atome de comparaison",
    "n'a pas le même nombre de clés que"
   ]
}
</CDATA>
}

}
