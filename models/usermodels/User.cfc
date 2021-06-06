component scope="session" accessors="true"{

	property name="accessID";
	property name="Position_ID";
	property name="numb_empl_id";
	property name="positiontitle";
	property name="nameFull";
	property name="nameFirst";
	property name="nameLast";
	property name="email";
	property name="notes" default="";
	property name="lstPermissions" default="";
	property name="arrPermissions" type="array" default="[]"; // note default is not true array but rather a string. Be sure to check if array when using.
	property name="arrRoles" type="array" default="[]"; // note default is not true array but rather a string. Be sure to check if array when using.
	property name="usingEmulation" default=0;
	property name="emulatingUser";
	property name="code_empl_status";
	
	
	/**
	* init
	**/
	public component function init(){
		setUsingEmulation(0);
		return this;
	}
	
}