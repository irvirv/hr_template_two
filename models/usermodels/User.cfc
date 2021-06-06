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
	property name="code_empl_status";
	
	
	/**
	* init
	**/
	public component function init(){
		return this;
	}
	
}