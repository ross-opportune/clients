/**
 * @author Bruce Behrens Opportune LLP
 * @description controller for LWC dowtimeLogsManager
 * @date 2-4-2020
*/
public with sharing class dowtimeLogsManagerController {

	@AuraEnabled
	public static list<Sobject> getDowntimeLogs(map<string, string> searchfor)
	{
		OP_Utility.log('***getDowntimeLogs searchfor: ' + searchfor);


		String myquery = ' SELECT Id, Name, CreatedDate, LastModifiedDate, Asset__r.Name, Asset__r.Equip_ID__c, Asset__c, Duration_hrs__c, Date__c, Downtime_Type__c, Parent_Code__c, Downtime_Code__c, integration_equip_id__c, integration_equip_name__c, longest_occur__c, integration_id__c, integration_meterId__c, intergration_flowType__c, integration_events__c, integration_longest_ts__c, Send_To_ProCount__c, ProCount_Last_Update__c FROM Downtime_Log__c Where IsDeleted = false ';

		if (searchfor != null)
		{
			string myqueryAdditionalWhere = String.join(new list<String> (OP_Utility.buildWhere(new Map<string, string> { 'Asset__c' => 'REFERENCE', 'Downtime_Type__c' => 'PICKLIST', 'Parent_Code__c' => 'PICKLIST', 'Downtime_Code__c' => 'PICKLIST', 'Date__c' => 'DATE' }, searchfor).values()), ' AND ');
			if (String.isNotBlank(myqueryAdditionalWhere))
			{
				myquery += ' AND ' + myqueryAdditionalWhere;
			}
		}

		myquery += ' Limit 1000';
		OP_Utility.log('***getRecords myquery: ' + myquery);

		return Database.query(myquery);
	}


	@AuraEnabled
	public static String copyLogs(List<Id> sourceIds, Date newDate)
	{
		OP_Utility.log('***copyLogs newDate: ' + newDate + ' sourceIds: ' + sourceIds);
		
		List<Downtime_Log__c> newLogs = new List<Downtime_Log__c> ();
		List<Downtime_Log__c> logs = new List<Downtime_Log__c> ([SELECT Id, Name, Asset__c, Duration_hrs__c, Date__c, Downtime_Type__c, Parent_Code__c, Downtime_Code__c, integration_equip_id__c, integration_equip_name__c, longest_occur__c, integration_id__c, integration_meterId__c, intergration_flowType__c, integration_events__c, integration_longest_ts__c, Send_To_ProCount__c, ProCount_Last_Update__c FROM Downtime_Log__c Where IsDeleted = false and Id in :sourceIds]);
		
		//Date dt1 = Date.valueOf(newDate);
		
		//Datetime dt1 = Datetime.newInstanceGmt(newDate, Time.newInstance(12,0,0,0));
		//OP_Utility.log('***copyLogs dt1: ' + dt1);
		//OP_Utility.log('***copyLogs dt1.date: ' + dt1.date());
		//OP_Utility.log('***copyLogs dt1.dateGmt: ' + dt1.dateGmt());
		for (Downtime_Log__c item :logs) {

			Downtime_Log__c dtnew = item.clone(false, false, false, false);
			dtnew.Date__c = newDate;//Date.newInstance(dt1.year(),dt1.month(), dt1.day());
			//dtnew.Send_To_ProCount__c = true;
			newLogs.add(dtnew);

			OP_Utility.log('***copyLogs dtnew.Date__c: ' + dtnew.Date__c);
		}
		List<Database.SaveResult> saveresults = Database.insert(newLogs, false);
		List<String> errors = new List<String>();
		List<String> sourceerrornames = new List<String>();


		List<Downtime_Log__c> updateLogs = new List<Downtime_Log__c> ();
		for(Integer i = 0; i < saveresults.size(); i++){
			Downtime_Log__c source = logs[i];
			Database.SaveResult sr = saveresults[i];
			if (sr.isSuccess() == false)
			{
				sourceerrornames.add(source.Name);
				for(Database.Error de : sr.getErrors()){
					errors.add(de.getMessage());
				}
			}
			else{
				updateLogs.add(source);
			}
		}
		//calling update so we can fire process builder that check Send_To_ProCount__c based on configured criteria. 
		if (updateLogs.isEmpty() == false){
			update logs;
		}

		return sourceerrornames.isEmpty() ? '' : 'Not able to copy logs ('+ String.join(sourceerrornames, ',') +') details: ' + String.join(errors, ' | ') ;
	}


	@AuraEnabled
	public static String deleteLogs(List<Id> sourceIds)
	{
		OP_Utility.log('***deleteLogs sourceIds: ' + sourceIds);
		List<Downtime_Log__c> logs = new List<Downtime_Log__c> ([SELECT Id FROM Downtime_Log__c Where IsDeleted = false and Id in :sourceIds]);
		if (logs.isEmpty() == false) {
			delete logs;
		}
		return '';
	}

}