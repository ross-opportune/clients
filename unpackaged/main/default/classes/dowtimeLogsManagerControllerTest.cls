/**
 * @author Bruce Behrens Opportune LLP
 * @description test class for dowtimeLogsManagerController
 * @date 2-4-2020
*/
@isTest
private class dowtimeLogsManagerControllerTest {


	private static Map<String, String> Downtime_CodeMap
	{
		get {
			if (Downtime_CodeMap == null) {
				Downtime_CodeMap = new Map<String, String> ();
				Schema.DescribeFieldResult fieldResult = Downtime_Log__c.Downtime_Code__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				for (Schema.PicklistEntry pickListVal : ple) {
					Downtime_CodeMap.put(pickListVal.getLabel(), pickListVal.getValue());
				}
			}
			return Downtime_CodeMap;
		}
		set;
	}

	private static Map<String, String> Parent_CodeMap
	{
		get {
			if (Parent_CodeMap == null) {
				Parent_CodeMap = new Map<String, String> ();
				Schema.DescribeFieldResult fieldResult = Downtime_Log__c.Parent_Code__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				for (Schema.PicklistEntry pickListVal : ple) {
					Parent_CodeMap.put(pickListVal.getLabel(), pickListVal.getValue());
				}

			}
			return Parent_CodeMap;
		}
		set;
	}

	private static Map<String, String> Downtime_TypeMap
	{
		get {
			if (Downtime_TypeMap == null) {
				Downtime_TypeMap = new Map<String, String> ();
				Schema.DescribeFieldResult fieldResult = Downtime_Log__c.Downtime_Type__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				for (Schema.PicklistEntry pickListVal : ple) {
					Downtime_TypeMap.put(pickListVal.getLabel(), pickListVal.getValue());
				}

			}
			return Downtime_TypeMap;
		}
		set;
	}

	@isTest
	private static void getDowntimeLogsTest() {
		Account acc1 = new Account();
		acc1.Name = 'Test Account';
		insert acc1;

		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Asset_Type__c = 'CGP';
		a1.Asset_Search_Type__c = 'CGP';
		a1.Equip_ID__c = '99999';
		a1.AccountId = acc1.Id;
		insert a1;

		Downtime_Log__c dtlog = new Downtime_Log__c();
		dtlog.integration_id__c = '1234';
		dtlog.Date__c = Date.today();
		dtlog.integration_equip_name__c = '1234';
		dtlog.integration_equip_id__c = '1234';
		dtlog.integration_meterId__c = '1234';
		dtlog.intergration_flowType__c = '1234';
		dtlog.integration_events__c = '1234';
		dtlog.longest_occur__c = 24;
		dtlog.integration_longest_ts__c = Date.today();
		dtlog.Duration_hrs__c = 24;
		dtlog.Downtime_Type__c = Downtime_TypeMap.get('Compressor Downtime');
		dtlog.Parent_Code__c = Parent_CodeMap.get('Un-Planned');
		dtlog.Downtime_Code__c = Downtime_CodeMap.get('Cat. Conv. Temp. High');
		dtlog.Asset__c = a1.Id;
		dtlog.Send_To_ProCount__c = true;
		insert dtlog;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		map<string, string> searchfor = new map<string, string> ();
		searchfor.put('Asset__c', 'test asset');
		list<Sobject> test1 = dowtimeLogsManagerController.getDowntimeLogs(searchfor);
		Test.stopTest();

		System.assertEquals(1, test1.size());

	}

	@isTest
	private static void copyLogsTest() {
		Account acc1 = new Account();
		acc1.Name = 'Test Account';
		insert acc1;

		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Asset_Type__c = 'CGP';
		a1.Asset_Search_Type__c = 'CGP';
		a1.Equip_ID__c = '99999';
		a1.AccountId = acc1.Id;
		insert a1;

		Downtime_Log__c dtlog = new Downtime_Log__c();
		dtlog.integration_id__c = '1234';
		dtlog.Date__c = Date.today();
		dtlog.integration_equip_name__c = '1234';
		dtlog.integration_equip_id__c = '1234';
		dtlog.integration_meterId__c = '1234';
		dtlog.intergration_flowType__c = '1234';
		dtlog.integration_events__c = '1234';
		dtlog.longest_occur__c = 24;
		dtlog.integration_longest_ts__c = Date.today();
		dtlog.Duration_hrs__c = 24;
		dtlog.Downtime_Type__c = Downtime_TypeMap.get('Compressor Downtime');
		dtlog.Parent_Code__c = Parent_CodeMap.get('Un-Planned');
		dtlog.Downtime_Code__c = Downtime_CodeMap.get('Cat. Conv. Temp. High');
		dtlog.Asset__c = a1.Id;
		dtlog.Send_To_ProCount__c = true;
		insert dtlog;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		String test1 = dowtimeLogsManagerController.copyLogs(new List<Id>{dtlog.Id}, Date.today().addDays(1));
		Test.stopTest();

		System.assertEquals('', test1);

	}

	@isTest
	private static void deleteLogsTest() {
		Account acc1 = new Account();
		acc1.Name = 'Test Account';
		insert acc1;

		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Asset_Type__c = 'CGP';
		a1.Asset_Search_Type__c = 'CGP';
		a1.Equip_ID__c = '99999';
		a1.AccountId = acc1.Id;
		insert a1;

		Downtime_Log__c dtlog = new Downtime_Log__c();
		dtlog.integration_id__c = '1234';
		dtlog.Date__c = Date.today();
		dtlog.integration_equip_name__c = '1234';
		dtlog.integration_equip_id__c = '1234';
		dtlog.integration_meterId__c = '1234';
		dtlog.intergration_flowType__c = '1234';
		dtlog.integration_events__c = '1234';
		dtlog.longest_occur__c = 24;
		dtlog.integration_longest_ts__c = Date.today();
		dtlog.Duration_hrs__c = 24;
		dtlog.Downtime_Type__c = Downtime_TypeMap.get('Compressor Downtime');
		dtlog.Parent_Code__c = Parent_CodeMap.get('Un-Planned');
		dtlog.Downtime_Code__c = Downtime_CodeMap.get('Cat. Conv. Temp. High');
		dtlog.Asset__c = a1.Id;
		dtlog.Send_To_ProCount__c = true;
		insert dtlog;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		String test1 = dowtimeLogsManagerController.deleteLogs(new List<Id>{dtlog.Id});
		Test.stopTest();

		System.assertEquals('', test1);

	}

}