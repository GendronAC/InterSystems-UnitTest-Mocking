Class MockDemo.CTestedClassWithoutInjection Extends %RegisteredObject
{

Method SumOperation(A As %Integer, B As %Integer) As %Integer
{
   set mathService = ##class(MathService).%New()
   quit mathService.Add(A, B)
}

}
