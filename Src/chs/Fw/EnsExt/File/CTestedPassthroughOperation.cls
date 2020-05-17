Class chs.Fw.EnsExt.File.CTestedPassthroughOperation Extends EnsLib.File.PassthroughOperation
{

/// initialize Business Host object
Method %OnNew(pConfigName As %String, adapterOverride As Ens.Adapter = {$$$NULLOREF}) As %Status
{
   do ##super(pConfigName)
   
   // Used for unit testing injection only.
   set:($IsObject(adapterOverride)) ..Adapter = adapterOverride
   
   quit $$$OK
}

}
