component output="false" singleton {
	

	/**
	* init
	**/
	public component function init(){
		return this;
	}
	
	


	/**
	*  return items common to two lists
	* @list1 first list to compare
	* @list2 second list to compare
	**/
	public string function ListCommon(list1, list2){
		var list1Array = ListToArray(arguments.list1);
		var list2Array = ListToArray(arguments.list2);
		list1Array.RetainAll(list2Array);
		return ArrayToList(list1Array);
	}
	
}



