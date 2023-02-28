/**
 * @author Bruce Behrens Opportune LLP
 * @description unit test for OP_IntegrationBatch
 * @date 1-24-2020
*/
@isTest
private class OP_IntegrationBatchTest {

	private static Ignition_ProCount_Integration_Settings__mdt getTestSettings()
	{
		Map<String, Object> fields = new Map<String, Object>
		{
			'Enabled__c' => true,
			'Ignition_ProCount_Send_Errors_to_Email__c' => 'admin@ensignnr.com',
			'ProCount_File_Name__c' => 'ProCount.csv',
			'REST_FTP_api_Key__c' => 'test',
			'REST_FTP_Ignition_Download_Path__c' => '/toSF',
			'REST_FTP_ProCount_Upload_Path__c' => 'fromSF',
			'REST_FTP_server__c' => 'test.ensignnr.com',
			'REST_FTP_server_password__c' => 'mysecert',
			'REST_FTP_server_port__c' => 21,
			'REST_FTP_server_username__c' => 'admin@ensignnr.com',
			'REST_FTP_server_useTLS__c' => false,
			'REST_FTP_URL__c' => 'https://sftoftpproxy.herokuapp.com',
			'Delete_Downtime_Logs_after_x_days__c' => 365,
			'Delete_Integration_Logs_after_x_days__c' => 365
		};
		Ignition_ProCount_Integration_Settings__mdt settings = (Ignition_ProCount_Integration_Settings__mdt) OP_Utility.getMetadata('Ignition_ProCount_Integration_Settings__mdt', fields);
		OP_Utility.OPIntegrationSettings = settings;
		return settings;

	}


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
	private static void IgnitionDowntimeExportDownloadTest() {

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();
		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();

		OP_IntegrationBatch.ResponseResult t1 = new OP_IntegrationBatch.ResponseResult();
		t1.success = true;
		t1.files = new List<String> ();
		t1.files.add('Ignition_Downtime_Export_Example.csv');
		t1.files.add('1.csv');
		HttpResponse listfiles = new HttpResponse();
		listfiles.setBody(JSON.serialize(t1));


		OP_IntegrationBatch.testresponse.put('listfiles', listfiles);



		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = true;
		t2.data = 'aWQscmVwb3J0RGF0ZSxlcXVpcF9uYW1lLGVxdWlwX2lkLG1ldGVySWQsZmxvd1R5cGUsZXZlbnRzLGxvbmdlc3Rfb2NjdXIsbG9uZ2VzdF90cyxkdXJhdGlvbg0KMjI2MCwxLzI2LzIwMjAsQUZGTEVSQkFDSCAwMSAwMkggUEwsMjU0OTAsNzItMTEwNSxJbnRlcm1pdHRlciwxLDE5LjgyNDcxNSwxLzI2LzIwMjAsMTkuODI0NzE1DQoyMjYxLDEvMjYvMjAyMCxPRVRLRU4gMDEgMDFIIFBMLDI1MzgwLDcxLTMwMDIsSW50ZXJtaXR0ZXIsMSwxNy4xOTg2MiwxLzI2LzIwMjAsMTcuMTk4NjINCg==';
		HttpResponse getfile = new HttpResponse();
		getfile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('getfile', getfile);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download';
		//mybatch.continueToNextJob = false;
		database.executebatch(mybatch, 1);

		Test.stopTest();


		Integration_Log__c test1 = [Select Id from Integration_Log__c where Type__c = 'Ignition Downtime Export' and FTP_File_Name__c = 'Ignition_Downtime_Export_Example.csv'];
		System.assert(test1 != null);

		Attachment test2 = [Select Id from Attachment where ParentId = :test1.Id and Name = 'Ignition_Downtime_Export_Example.csv'];
		System.assert(test1 != null);

	}

	@isTest
	private static void IgnitionDowntimeExportDownloadStep2Test() {

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();
		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();

		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = true;
		t2.data = 'aWQscmVwb3J0RGF0ZSxlcXVpcF9uYW1lLGVxdWlwX2lkLG1ldGVySWQsZmxvd1R5cGUsZXZlbnRzLGxvbmdlc3Rfb2NjdXIsbG9uZ2VzdF90cyxkdXJhdGlvbg0KMjI2MCwxLzI2LzIwMjAsQUZGTEVSQkFDSCAwMSAwMkggUEwsMjU0OTAsNzItMTEwNSxJbnRlcm1pdHRlciwxLDE5LjgyNDcxNSwxLzI2LzIwMjAsMTkuODI0NzE1DQoyMjYxLDEvMjYvMjAyMCxPRVRLRU4gMDEgMDFIIFBMLDI1MzgwLDcxLTMwMDIsSW50ZXJtaXR0ZXIsMSwxNy4xOTg2MiwxLzI2LzIwMjAsMTcuMTk4NjINCg==';
		HttpResponse getfile = new HttpResponse();
		getfile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('getfile', getfile);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download';
		//mybatch.continueToNextJob = false;
		mybatch.filestoprocess = new List<String> { '1.csv' };
		database.executebatch(mybatch, 1);


		Test.stopTest();


		Integration_Log__c test1 = [Select Id from Integration_Log__c where Type__c = 'Ignition Downtime Export' and FTP_File_Name__c = '1.csv'];
		System.assert(test1 != null);

		Attachment test2 = [Select Id from Attachment where ParentId = :test1.Id and Name = '1.csv'];
		System.assert(test1 != null);

	}

	@isTest
	private static void IgnitionDowntimeExportDownloadStepFTPGetFileErrorTest() {

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();
		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();

		OP_IntegrationBatch.ResponseResult t1 = new OP_IntegrationBatch.ResponseResult();
		t1.success = true;
		t1.files = new List<String> ();
		t1.files.add('Ignition_Downtime_Export_Example.csv');
		t1.files.add('1.csv');
		HttpResponse listfiles = new HttpResponse();
		listfiles.setBody(JSON.serialize(t1));


		OP_IntegrationBatch.testresponse.put('listfiles', listfiles);



		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = false;
		t2.errors.add('test error');
		HttpResponse getfile = new HttpResponse();
		getfile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('getfile', getfile);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download';
		//mybatch.continueToNextJob = false;
		database.executebatch(mybatch, 1);

		Test.stopTest();


		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Type__c = 'Ignition Downtime Export' and FTP_File_Name__c = 'Ignition_Downtime_Export_Example.csv'];
		System.assert(test1 != null);

		System.assertEquals('Error', test1.Status__c);

	}

	@isTest
	private static void IgnitionDowntimeExportDownloadDeleteFTPFilesTest() {

		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'Ignition Downtime Export';
		il1.Status__c = 'Download Complete';
		il1.FTP_File_Path__c = '/toSF/';
		il1.FTP_File_Name__c = '1.csv';

		insert il1;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();
		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();

		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = true;
		HttpResponse deletefile = new HttpResponse();
		deletefile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('deletefile', deletefile);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download Delete FTP Files';
		//mybatch.continueToNextJob = false;
		database.executebatch(mybatch, 1);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Id = :il1.Id];
		System.assertEquals('Ready to Process', test1.Status__c);
	}

	@isTest
	private static void IgnitionDowntimeExportDownloadDeleteFTPFilesErrorTest() {

		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'Ignition Downtime Export';
		il1.Status__c = 'Download Complete';
		il1.FTP_File_Path__c = '/toSF/';
		il1.FTP_File_Name__c = '1.csv';

		insert il1;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();
		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();

		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = false;
		t2.errors.add('test error');
		HttpResponse deletefile = new HttpResponse();
		deletefile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('deletefile', deletefile);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Ignition Downtime Export Download Delete FTP Files';
		//mybatch.continueToNextJob = false;
		database.executebatch(mybatch, 1);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Id = :il1.Id];
		System.assertEquals('Error', test1.Status__c);
	}

	@isTest
	private static void ProcessIgnitionDowntimeExportTest() {

		Account acc1 = new Account();
		acc1.Name = 'Test Account';
		insert acc1;

		//Contact c1 = new Contact;
		//c1.FirstName = 'test';
		//c1.LastName = 'test';
		//insert c1;


		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Asset_Type__c = 'CGP';
		a1.Asset_Search_Type__c = 'CGP';
		a1.Equip_ID__c = '99999';
		a1.AccountId = acc1.Id;
		insert a1;


		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'Ignition Downtime Export';
		il1.Status__c = 'Ready to Process';
		il1.FTP_File_Path__c = '/toSF/';
		il1.FTP_File_Name__c = '1.csv';
		insert il1;

		Attachment att1 = new Attachment();
		att1.Name = '1.csv';
		att1.ParentId = il1.Id;
		att1.Body = EncodingUtil.base64Decode('aWQscmVwb3J0RGF0ZSxlcXVpcF9uYW1lLGVxdWlwX2lkLG1ldGVyaWQsZmxvd1R5cGUsZXZlbnRzLGxvbmdlc3Rfb2NjdXIsbG9uZ2VzdF90cyxkdXJhdGlvbgozMDc4LDIwMjAtMDItMDYsUkFORVkgMDEgMDFIIEdBUywyNTI2NSw2MS03MDEsRmxvd2luZywxLDI0LDIwMjAtMDItMDYsMjQuMAozMDc5LDIwMjAtMDItMDYsRUxJWk9ORE8gMDEgMDNIIEdBUyw3NTIyMCw3MS0zNzAzLEZsb3dpbmcsMSwyMy41NTQ4LDIwMjAtMDItMDYsMjMuNTU0NzcwNTU1NTU1NTU3');
		insert att1;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Process Ignition Downtime Export';
		//mybatch.continueToNextJob = false;
		database.executebatch(mybatch, 1);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Id = :il1.Id];
		System.assertEquals('Process Completed', test1.Status__c);
	}

	@isTest
	private static void PrepareDowntimeLogsforProCountTest() {

		Account acc1 = new Account();
		acc1.Name = 'Test Account';
		insert acc1;

		Asset a1 = new Asset();
		a1.Name = 'test asset';
		a1.Asset_Type__c = 'CGP';
		a1.Asset_Search_Type__c = 'CGP';
		a1.Equip_ID__c = '99998';
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
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Prepare Downtime Logs for ProCount';
		database.executebatch(mybatch, 2000);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Type__c = 'ProCount Export' AND Status__c = 'Ready to Process'];
		System.assert(test1 != null);
	}

	@isTest
	private static void ProcessDowntimeLogsforProCountTest() {

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


		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'ProCount Export';
		il1.Status__c = 'Ready to Process';
		il1.FTP_File_Path__c = '/toSF/';
		//il1.FTP_File_Name__c = '1.csv';
		insert il1;


		Map<String, Integer> headers = new Map<String, Integer> ();
		headers.put('id', 0);
		headers.put('reportDate', 1);
		headers.put('equip_name', 2);
		headers.put('equip_id', 3);
		headers.put('meterid', 4);
		headers.put('flowType', 5);
		headers.put('events', 6);
		headers.put('longest_occur', 7);
		headers.put('longest_ts', 8);
		headers.put('duration', 9);
		headers.put('Downtime_Type__c', 10);
		headers.put('Parent_Code__c', 11);
		headers.put('Downtime_Code__c', 12);
		headers.put('SF_Id', 13);

		list<list<String>> downtimedata = new list<list<String>> ();

		list<String> dtlogdata = new list<String> ();
		dtlogdata.add(dtlog.integration_id__c);
		dtlogdata.add(String.valueOf(dtlog.Date__c));
		dtlogdata.add(dtlog.integration_equip_name__c);
		dtlogdata.add(dtlog.integration_equip_id__c);

		dtlogdata.add(dtlog.integration_meterId__c);
		dtlogdata.add(dtlog.intergration_flowType__c);
		dtlogdata.add(dtlog.integration_events__c);
		dtlogdata.add(String.valueOf(dtlog.longest_occur__c));
		dtlogdata.add(String.valueOf(dtlog.integration_longest_ts__c));
		dtlogdata.add(String.valueOf(dtlog.Duration_hrs__c));
		dtlogdata.add(dtlog.Downtime_Type__c);
		dtlogdata.add(dtlog.Parent_Code__c);
		dtlogdata.add(dtlog.Downtime_Code__c);
		dtlogdata.add(dtlog.Id);


		downtimedata.add(dtlogdata);

		OP_IntegrationBatch ob1 = new OP_IntegrationBatch();

		String csvdata = ob1.createcsvdata(headers, downtimedata, true, true);

		Attachment att1 = new Attachment();
		att1.Name = '1.csv';
		att1.ParentId = il1.Id;
		att1.Body = Blob.valueOf(csvdata);
		insert att1;


		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();
		OP_IntegrationBatch.ResponseResult t1 = new OP_IntegrationBatch.ResponseResult();
		t1.success = true;
		t1.files = new List<String> ();
		//t1.files.add(OP_Utility.OPSettings.ProCount_File_Name__c);
		HttpResponse listfiles = new HttpResponse();
		listfiles.setBody(JSON.serialize(t1));
		OP_IntegrationBatch.testresponse.put('listfiles', listfiles);

		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = true;
		HttpResponse addfile = new HttpResponse();
		addfile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('addfile', addfile);


		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Process Downtime Logs for ProCount';
		database.executebatch(mybatch, 1);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Id = :il1.Id];
		System.assertEquals('Process Completed', test1.Status__c);
	}


	@isTest
	private static void ProcessDowntimeLogsforProCountHoldTest() {

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


		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'ProCount Export';
		il1.Status__c = 'Ready to Process';
		il1.FTP_File_Path__c = '/toSF/';
		//il1.FTP_File_Name__c = '1.csv';
		insert il1;


		Map<String, Integer> headers = new Map<String, Integer> ();
		headers.put('id', 0);
		headers.put('reportDate', 1);
		headers.put('equip_name', 2);
		headers.put('equip_id', 3);
		headers.put('meterid', 4);
		headers.put('flowType', 5);
		headers.put('events', 6);
		headers.put('longest_occur', 7);
		headers.put('longest_ts', 8);
		headers.put('duration', 9);
		headers.put('Downtime_Type__c', 10);
		headers.put('Parent_Code__c', 11);
		headers.put('Downtime_Code__c', 12);
		headers.put('SF_Id', 13);

		list<list<String>> downtimedata = new list<list<String>> ();

		list<String> dtlogdata = new list<String> ();
		dtlogdata.add(dtlog.integration_id__c);
		dtlogdata.add(String.valueOf(dtlog.Date__c));
		dtlogdata.add(dtlog.integration_equip_name__c);
		dtlogdata.add(dtlog.integration_equip_id__c);

		dtlogdata.add(dtlog.integration_meterId__c);
		dtlogdata.add(dtlog.intergration_flowType__c);
		dtlogdata.add(dtlog.integration_events__c);
		dtlogdata.add(String.valueOf(dtlog.longest_occur__c));
		dtlogdata.add(String.valueOf(dtlog.integration_longest_ts__c));
		dtlogdata.add(String.valueOf(dtlog.Duration_hrs__c));
		dtlogdata.add(dtlog.Downtime_Type__c);
		dtlogdata.add(dtlog.Parent_Code__c);
		dtlogdata.add(dtlog.Downtime_Code__c);
		dtlogdata.add(dtlog.Id);


		downtimedata.add(dtlogdata);

		OP_IntegrationBatch ob1 = new OP_IntegrationBatch();

		String csvdata = ob1.createcsvdata(headers, downtimedata, true, true);

		Attachment att1 = new Attachment();
		att1.Name = '1.csv';
		att1.ParentId = il1.Id;
		att1.Body = Blob.valueOf(csvdata);
		insert att1;


		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		OP_IntegrationBatch.testresponse = new Map<String, HttpResponse> ();
		OP_IntegrationBatch.ResponseResult t1 = new OP_IntegrationBatch.ResponseResult();
		t1.success = true;
		t1.files = new List<String> ();
		t1.files.add(settings.ProCount_File_Name__c);
		HttpResponse listfiles = new HttpResponse();
		listfiles.setBody(JSON.serialize(t1));
		OP_IntegrationBatch.testresponse.put('listfiles', listfiles);

		OP_IntegrationBatch.ResponseResult t2 = new OP_IntegrationBatch.ResponseResult();
		t2.success = true;
		HttpResponse addfile = new HttpResponse();
		addfile.setBody(JSON.serialize(t2));
		OP_IntegrationBatch.testresponse.put('addfile', addfile);


		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Process Downtime Logs for ProCount';
		database.executebatch(mybatch, 1);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c from Integration_Log__c where Id = :il1.Id];
		System.assertEquals('Holding', test1.Status__c);
	}


	@isTest
	private static void CleanupIntegrationLogsTest() {

		Integration_Log__c il1 = new Integration_Log__c();
		il1.Type__c = 'ProCount Export';
		il1.Status__c = 'Ready to Process';
		il1.FTP_File_Path__c = '/toSF/';
		il1.CreatedDate = Datetime.now().addDays(- 400);
		insert il1;

		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		System.assertEquals(365, OP_IntegrationBatch.IntegrationLogCleanupDays);


		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Cleanup Integration Logs';
		mybatch.query = 'Select Id From Integration_Log__c Where IsDeleted = false and Id = \'' + il1.Id + '\'';
		database.executebatch(mybatch, 200);

		Test.stopTest();

		Integration_Log__c test1 = [Select Id, Status__c, IsDeleted from Integration_Log__c where Id = :il1.Id ALL ROWS];
		System.assertEquals(true, test1.IsDeleted);
	}


	@isTest
	private static void CleanupDowntimeLogsTest() {

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
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();

		System.assertEquals(365, OP_IntegrationBatch.DowntimeLogCleanupDays);

		OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
		mybatch.JobType = 'Cleanup Downtime Logs';
		mybatch.query = 'Select Id From Downtime_Log__c Where IsDeleted = false and Id = \'' + dtlog.Id + '\'';
		database.executebatch(mybatch, 200);

		Test.stopTest();

		Downtime_Log__c test1 = [Select Id, IsDeleted from Downtime_Log__c where Id = :dtlog.Id ALL ROWS];
		System.assertEquals(true, test1.IsDeleted);
	}

	@isTest
	private static void scheduleTest() {


		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Ignition_ProCount_Integration_Settings__mdt settings = getTestSettings();



		System.schedule('Daily OPTEST_IntegrationBatch Job', '0 0 2 * * ?', new OP_IntegrationBatch());

		Test.stopTest();


	}



}