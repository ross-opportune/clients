/**
 * @author Bruce Behrens Opportune LLP
 * @description controller for LWC OpIntegrationStatus
 * @date 1-30-2020
*/
public with sharing class OP_IntegrationStatusController {

	@AuraEnabled
	public static String addNewSchedule(string name, Integer hour, Integer minute)
	{
		try{
			System.schedule('Daily OP_IntegrationBatch Job: ' + name, '0 ' + minute + ' ' + hour + ' * * ?', new OP_IntegrationBatch());
		} 
		catch(Exception ex){
			return 'Error: ' + ex.getMessage();
		}
		return '';
	}

	@AuraEnabled
	public static list<Sobject> getScheduledJobs()
	{
		return[SELECT ID, CronExpression, CronJobDetail.JobType, CronJobDetail.Name, CronJobDetailId, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger where CronJobDetail.Name like '%OP_IntegrationBatch%' order by NextFireTime desc];
	}

	@AuraEnabled
	public static list<Sobject> getApexJobs()
	{
		return[SELECT Id, CreatedDate, CreatedById, JobType, ApexClass.Name, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob where ApexClass.Name like '%OP_IntegrationBatch%' order by CompletedDate desc limit 100];
	}

	@AuraEnabled
	public static list<Sobject> getIntegrationLogs()
	{
		return[SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Type__c, Status__c, Log__c, FTP_File_Path__c, FTP_File_Name__c FROM Integration_Log__c order by CreatedDate desc limit 100];
	}

	@AuraEnabled
	public static void runJobNow()
	{
		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download';
		database.executebatch(mybatch, 1);
	}

	@AuraEnabled
	public static list<Sobject> getReadyForProCount()
	{
		return[SELECT Id, Name, CreatedDate, LastModifiedDate, Asset__r.Name, Asset__r.Equip_ID__c, Asset__c, Duration_hrs__c, Date__c, Downtime_Type__c, Parent_Code__c, Downtime_Code__c, integration_equip_id__c, integration_equip_name__c, longest_occur__c, integration_id__c, integration_meterId__c, intergration_flowType__c, integration_events__c, integration_longest_ts__c, Send_To_ProCount__c, ProCount_Last_Update__c FROM Downtime_Log__c where Send_To_ProCount__c = true order by LastModifiedDate desc limit 1000];
	}

	@AuraEnabled
	public static list<Sobject> getRecentDowntimeLogs()
	{
		return[SELECT Id, Name, CreatedDate, LastModifiedDate, Asset__r.Name, Asset__r.Equip_ID__c, Asset__c, Duration_hrs__c, Date__c, Downtime_Type__c, Parent_Code__c, Downtime_Code__c, integration_equip_id__c, integration_equip_name__c, longest_occur__c, integration_id__c, integration_meterId__c, intergration_flowType__c, integration_events__c, integration_longest_ts__c, Send_To_ProCount__c, ProCount_Last_Update__c FROM Downtime_Log__c order by LastModifiedDate desc limit 250];
	}

}