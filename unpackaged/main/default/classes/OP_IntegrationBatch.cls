/**
 * @author Bruce Behrens Opportune LLP
 * @description Batch class for processing Ignition Downtime Exports
 * @date 1-24-2020
 
  //jobs are chained together. running 
  1. 'Ignition Downtime Export Download': Downloads all .csv files in the configred ftp folder REST_FTP_Ignition_Download_Path__c. 
  Each file is added to a Integration_Log__c Type__c: "Ignition Downtime Export" Status__c: "Download Complete". The file is added to the record's Attachment
  2. 'Ignition Downtime Export Download Delete FTP Files': File is deleted from FTP that was downloaded in step 1. Integration_Log__c Status__c updated to: "Ready to Process"
  3. 'Process Ignition Downtime Export': Downtime_Log__c are created from step 1. Integration_Log__c Status__c updated to: "Process Completed"
  4. 'Prepare Downtime Logs for ProCount': Integration_Log__c Type__c: "ProCount Export" Status__c: "Ready to Process" is created in groups of 2000 records where Downtime_Log__c.Status__c = 'TBD'
  5. 'Process Downtime Logs for ProCount' Files are uploaded to FTP from step 4.  Integration_Log__c Status__c updated to: "Process Completed" Downtime_Log__c.Status__c updated to TBD
 
  //download Ignitions files from FTP
  OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
  mybatch.JobType = 'Ignition Downtime Export Download';
  database.executebatch(mybatch, 1);
 
 
  //download Ignitions fiels from FTP
  OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
  mybatch.JobType = 'Process Ignition Downtime Export';
  database.executebatch(mybatch, 1);
 
 
  //create ProCount Integration Log
  OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
  mybatch.JobType = 'Prepare Downtime Logs for ProCount';
  database.executebatch(mybatch, 2000);
 
  //upload ProCount Integration file
  OP_IntegrationBatch mybatch = new OP_IntegrationBatch();
  mybatch.JobType = 'Process Downtime Logs for ProCount';
  database.executebatch(mybatch, 1);
 
 
  //scedule to run at 2AM daily
  System.schedule('Daily OP_IntegrationBatch Job', '0 0 2 * * ?', new OP_IntegrationBatch());
 
*/
public class OP_IntegrationBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, System.Schedulable {


	public String query;
	public String jobType = '';

	public List<String> filestoprocess = null;

	//used to stop looping if a fatal error occurs
	public Boolean continueToNextJob = true;

	public OP_IntegrationBatch() {
		OP_Utility.log('***OP_IntegrationBatch');
	}

	public void execute(SchedulableContext SC)
	{
		OP_IntegrationBatch batch = new OP_IntegrationBatch();
		batch.JobType = 'Ignition Downtime Export Download';
		database.executebatch(batch, 1);
	}

	public static Integer IntegrationLogCleanupDays
	{
		get
		{
			return Integer.valueOf(OP_Utility.OPIntegrationSettings.Delete_Integration_Logs_after_x_days__c != null && OP_Utility.OPIntegrationSettings.Delete_Integration_Logs_after_x_days__c > 0
			                       ? OP_Utility.OPIntegrationSettings.Delete_Integration_Logs_after_x_days__c : 0);

		}
	}

	public static Integer DowntimeLogCleanupDays
	{
		get
		{
			return Integer.valueOf(OP_Utility.OPIntegrationSettings.Delete_Downtime_Logs_after_x_days__c != null && OP_Utility.OPIntegrationSettings.Delete_Downtime_Logs_after_x_days__c > 0
			                       ? OP_Utility.OPIntegrationSettings.Delete_Downtime_Logs_after_x_days__c : 0);

		}
	}


	public Database.QueryLocator start(Database.BatchableContext bc) {
		if (query == null) {
			if (jobType == 'Ignition Downtime Export Download') {
				this.query = 'Select Id from User Limit 1';
			}
			else if (jobType == 'Ignition Downtime Export Download Delete FTP Files') {
				this.query = 'Select Id,Type__c,Status__c,Log__c,FTP_File_Name__c,FTP_File_Path__c From Integration_Log__c Where Type__c = \'Ignition Downtime Export\' and Status__c = \'Download Complete\'';
			}
			else if (jobType == 'Process Ignition Downtime Export') {
				this.query = 'Select Id,Type__c,Status__c,Log__c,FTP_File_Name__c,FTP_File_Path__c From Integration_Log__c Where Type__c = \'Ignition Downtime Export\' and Status__c = \'Ready to Process\'';
			}
			else if (jobType == 'Prepare Downtime Logs for ProCount') {
				this.query = 'Select integration_id__c,Date__c,integration_equip_name__c,integration_equip_id__c,integration_meterId__c,intergration_flowType__c,integration_events__c,longest_occur__c,integration_longest_ts__c,Duration_hrs__c,Downtime_Type__c,Parent_Code__c,Downtime_Code__c, Asset__c, Asset__r.Equip_ID__c,Asset__r.Name From Downtime_Log__c where Send_To_ProCount__c = true';
			}
			else if (jobType == 'Process Downtime Logs for ProCount') {
				this.query = 'Select Id,Type__c,Status__c,Log__c,FTP_File_Name__c,FTP_File_Path__c From Integration_Log__c Where Type__c = \'ProCount Export\' and Status__c in (\'Ready to Process\',\'Holding\') order by LastModifiedDate ASC';
			}
			else if (jobType == 'Cleanup Integration Logs') {
				this.query = 'Select Id From Integration_Log__c Where IsDeleted = false ';
				this.query += OP_IntegrationBatch.IntegrationLogCleanupDays > 0 ? ' AND LastModifiedDate != LAST_N_DAYS:' + OP_IntegrationBatch.IntegrationLogCleanupDays : ' AND Id = null';
			}
			else if (jobType == 'Cleanup Downtime Logs') {
				this.query = 'Select Id From Downtime_Log__c Where IsDeleted = false ';
				this.query += OP_IntegrationBatch.DowntimeLogCleanupDays > 0 ? ' AND LastModifiedDate != LAST_N_DAYS:' + OP_IntegrationBatch.DowntimeLogCleanupDays : ' AND Id = null';

			}
		}
		this.query = query;
		OP_Utility.log('***OP_IntegrationBatch start query:' + query);
		return Database.getQueryLocator(query);
	}

	public class ftpOptions {
		public string server { get; set; }
		public Integer port { get; set; }
		public string username { get; set; }
		public string password { get; set; }
		public string path { get; set; }
		public Boolean useTLS { get; set; }
		public string file { get; set; }
		public string data { get; set; }
	}


	public class ResponseResult {
		public ResponseResult() {
			errors = new List<String> ();
			success = false;
		}

		public String[] errors { get; set; }
		public Boolean success { get; set; }
		public String data { get; set; }
		public String[] files { get; set; }

	}

	public static ResponseResult parseFTPresult(String jsonString) {
		OP_Utility.log('**parseFTPresult jsonString: ' + jsonString);
		return(ResponseResult) JSON.deserialize(jsonString, ResponseResult.class);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	public void execute(Database.BatchableContext context, List<SObject> scope) {
		OP_Utility.log('***OP_IntegrationBatch execute jobType:' + jobType);
		try
		{
			if (OP_Utility.OPIntegrationSettings.Enabled__c == true)
			{
				if (jobType == 'Ignition Downtime Export Download') {
					if (String.isNotBlank(OP_Utility.OPIntegrationSettings.REST_FTP_URL__c)) {

						ftpOptions ftoption = new ftpOptions();
						ftoption.server = OP_Utility.OPIntegrationSettings.REST_FTP_server__c;
						ftoption.port = Integer.valueOf(OP_Utility.OPIntegrationSettings.REST_FTP_server_port__c);
						ftoption.username = OP_Utility.OPIntegrationSettings.REST_FTP_server_username__c;
						ftoption.password = OP_Utility.OPIntegrationSettings.REST_FTP_server_password__c;
						ftoption.path = OP_Utility.OPIntegrationSettings.REST_FTP_Ignition_Download_Path__c;
						ftoption.useTLS = OP_Utility.OPIntegrationSettings.REST_FTP_server_useTLS__c;

						ResponseResult getfilelistresults = new ResponseResult();
						OP_Utility.log('***OP_IntegrationBatch filestoprocess:' + this.filestoprocess);
						if (this.filestoprocess == null)
						{
							getfilelistresults = callFtpApi(ftoption, 'listfiles');
							//OP_Utility.log('***OP_IntegrationBatch getfilelistresults:' + getfilelistresults);
							if (getfilelistresults.success == true && !getfilelistresults.files.isEmpty()) {
								//cleaning list and only choosing .csv files
								set<String> cleanlist = new set<String> ();
								for (string filename : getfilelistresults.files) {

									if (filename.endsWith('.csv')) {
										cleanlist.add(filename);
									}
								}
								getfilelistresults.files = new List<String> (cleanlist);
							}
							this.filestoprocess = null;
						} else {
							OP_Utility.log('***OP_IntegrationBatch adding remaining files to process. Not calling FTP listfiles');
							getfilelistresults.files = this.filestoprocess;
							getfilelistresults.success = true;
							this.filestoprocess = null;
						}

						OP_Utility.log('***OP_IntegrationBatch getfilelistresults:' + getfilelistresults);
						if (getfilelistresults.success == true && !getfilelistresults.files.isEmpty()) {

							Integer startfiles = getfilelistresults.files.size();

							string firstfile = getfilelistresults.files.get(0);
							getfilelistresults.files.remove(0);
							ftoption.file = firstfile;

							System.assertEquals(startfiles - 1, getfilelistresults.files.size());

							//if (getfilelistresults.files.isEmpty()) {
							this.filestoprocess = getfilelistresults.files.isEmpty() ? null : getfilelistresults.files;
							//}

							OP_Utility.log('***OP_IntegrationBatch filestoprocess2 :' + this.filestoprocess);

							ResponseResult getfileresults = callFtpApi(ftoption, 'getfile');
							OP_Utility.log('***OP_IntegrationBatch getfileresults:' + getfileresults);

							Integration_Log__c logitem = new Integration_Log__c();
							logitem.Type__c = 'Ignition Downtime Export';
							logitem.FTP_File_Path__c = ftoption.path;
							logitem.FTP_File_Name__c = ftoption.file;
							logitem.Log__c = '';

							if (getfileresults.success == true && getfileresults.data != null) {
								logitem.Status__c = 'Download Complete';
								insert logitem;

								logitem.Log__c += ' Successfully downloaded file from the ftp.';

								OP_Utility.log('***OP_IntegrationBatch logitem:' + logitem);


								Attachment att1 = new Attachment();
								att1.Name = firstfile;
								att1.ParentId = logitem.Id;
								att1.Body = EncodingUtil.base64Decode(getfileresults.data);
								insert att1;

								logitem.Log__c = ' Attachment added Id: ' + att1.Id + '.\r\n';
								OP_Utility.log('***OP_IntegrationBatch att1:' + att1);
							} else {
								logitem.Status__c = 'Error';
								logitem.Log__c += ' Error downloading file from the ftp. File path: ' + ftoption.path + ' File name: ' + ftoption.file + '  Error : ' + getfileresults.errors + '.\r\n';
								emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Error downloading file from the ftp. File path: ' + ftoption.path + ' File name: ' + ftoption.file + '  Error : ' + getfileresults.errors + '\r\n');
							}
							logitem.Log__c = OP_Utility.trimChar(logitem.Log__c, 131091);
							OP_Utility.log('***OP_IntegrationBatch logitem: ' + logitem);

							if (logitem.Id != null) {
								update logitem;
							} else {
								insert logitem;
							}

						}
					}
				}
				else if (jobType == 'Ignition Downtime Export Download Delete FTP Files') {
					for (Sobject s : scope) {
						if (s.getsObjectType() == Integration_Log__c.sObjectType) {
							Integration_Log__c logitem = (Integration_Log__c) s;

							logitem.Log__c = String.isNotBlank(logitem.Log__c) ? logitem.Log__c : '';

							if (String.isNotBlank(OP_Utility.OPIntegrationSettings.REST_FTP_URL__c)) {

								ftpOptions ftoption = new ftpOptions();
								ftoption.server = OP_Utility.OPIntegrationSettings.REST_FTP_server__c;
								ftoption.port = Integer.valueOf(OP_Utility.OPIntegrationSettings.REST_FTP_server_port__c);
								ftoption.username = OP_Utility.OPIntegrationSettings.REST_FTP_server_username__c;
								ftoption.password = OP_Utility.OPIntegrationSettings.REST_FTP_server_password__c;
								ftoption.path = logitem.FTP_File_Path__c;
								ftoption.file = logitem.FTP_File_Name__c;
								ftoption.useTLS = OP_Utility.OPIntegrationSettings.REST_FTP_server_useTLS__c;

								ResponseResult deletefileresults = callFtpApi(ftoption, 'deletefile');
								OP_Utility.log('***OP_IntegrationBatch deletefileresults:' + deletefileresults);

								if (deletefileresults.success == true) {
									logitem.Log__c += ' Successfully deleted ftp file' + '.\r\n';
									logitem.Status__c = 'Ready to Process';
								} else {

									logitem.Status__c = 'Error';
									logitem.Log__c += ' Error deleting file from the ftp. Error : ' + deletefileresults.errors + '.\r\n';
									emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Error deleting file from the ftp. Error : ' + deletefileresults.errors + '\r\n');

								}
								logitem.Log__c = OP_Utility.trimChar(logitem.Log__c, 131091);
								OP_Utility.log('***OP_IntegrationBatch logitem: ' + logitem);
								update logitem;
							}
						}
					}
				}
				else if (jobType == 'Process Ignition Downtime Export') {
					for (Sobject s : scope) {
						if (s.getsObjectType() == Integration_Log__c.sObjectType) {
							Integration_Log__c logitem = (Integration_Log__c) s;
							logitem.Log__c = String.isNotBlank(logitem.Log__c) ? logitem.Log__c : '';

							try
							{
								Attachment att1 = [Select Id, Name, Body from Attachment where ParentId = :logitem.Id];

								String csvdata = att1.Body.toString();
								OP_Utility.log('***OP_IntegrationBatch csvdata:' + csvdata);
								OP_CsvReader csvreader = new OP_CsvReader(csvdata, ',');
								OP_Utility.log('***OP_IntegrationBatch csvreader:' + csvreader);
								string[] rowdata = csvreader.readLine();
								if (rowdata != null) {

									Map<String, Integer> headermap = new Map<String, Integer> ();
									for (Integer i = 0; i<rowdata.size(); i++) {
										headermap.put(rowdata.get(i), i);
									}
									OP_Utility.log('***OP_IntegrationBatch headermap:' + headermap);
									//get second line
									rowdata = csvreader.readLine();
									if (rowdata == null)
									{
										logitem.Log__c += ' Not able to parse csv file.\r\n';
										logitem.Status__c = 'Error';
										emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Not able to parse csv file.\r\n');
									} else {

										List<Downtime_Log__c> downtownLogs = new List<Downtime_Log__c> ();
										Set<String> equip_ids = new Set<String> { '99999' };
										while (rowdata != null) {

											OP_Utility.log('***OP_IntegrationBatch rowdata:' + rowdata);
											Downtime_Log__c log = new Downtime_Log__c();
											log.raw_csv_data__c = createcsvdata(headermap, new list<List<String>> { rowdata }, true, true);

											log.integration_equip_id__c = rowdata.get(headermap.get('equip_id'));
											log.integration_equip_name__c = rowdata.get(headermap.get('equip_name'));
											log.integration_id__c = rowdata.get(headermap.get('id'));

											OP_Utility.log('***OP_IntegrationBatch rowdata.get(headermap.get(meterid)):' + (rowdata.get(headermap.get('meterid'))));
											log.integration_meterId__c = rowdata.get(headermap.get('meterid'));
											log.intergration_flowType__c = rowdata.get(headermap.get('flowType'));
											log.integration_events__c = rowdata.get(headermap.get('events'));

											log.longest_occur__c = Decimal.valueOf(rowdata.get(headermap.get('longest_occur')));
											log.integration_longest_ts__c = Date.valueOf(rowdata.get(headermap.get('longest_ts')));


											log.Date__c = Date.valueOf(rowdata.get(headermap.get('reportDate')));


											OP_Utility.log('***OP_IntegrationBatch headermap.containsKey(duration):' + (headermap.containsKey('duration')));
											OP_Utility.log('***OP_IntegrationBatch headermap.get(duration):' + (headermap.get('duration')));
											OP_Utility.log('***OP_IntegrationBatch rowdata.get(headermap.get(duration)):' + (rowdata.get(headermap.get('duration'))));
											log.Duration_hrs__c = Decimal.valueOf(rowdata.get(headermap.get('duration')));

											equip_ids.add(log.integration_equip_id__c);

											downtownLogs.add(log);

											rowdata = csvreader.readLine();
										}
										Map<String, Id> assetMap = new Map<String, Id> ();
										for (Asset item :[Select Id, Equip_ID__c from Asset where Equip_ID__c in :equip_ids]) {
											assetMap.put(item.Equip_ID__c, item.Id);
										}

										for (Downtime_Log__c item : downtownLogs) {
											item.Asset__c = assetMap.containsKey(item.integration_equip_id__c) ? assetMap.get(item.integration_equip_id__c) : assetMap.get('99999');
										}

										List<Database.SaveResult> saveresults = Database.insert(downtownLogs, false);
										OP_Utility.log('***OP_IntegrationBatch saveresults: ' + saveresults);

										Integration_Log__c errortolog = null;
										String errortologcsv = '';
										Boolean oneWasSuccess = false;
										Integer successcount = 0;
										Integer failurecount = 0;
										for (Integer i = 0; i<saveresults.size(); i++) {
											Database.SaveResult sr = saveresults.get(i);
											if (!sr.isSuccess())
											{
												Downtime_Log__c saveditem = downtownLogs.get(i);
												OP_Utility.log('***OP_IntegrationBatch Downtime_Log__c insert falure Errors: ' + sr.getErrors());
												OP_Utility.log('***OP_IntegrationBatch saveditem: ' + saveditem);
												logitem.Log__c += ' Error inserting Downtime_Log__c: ' + saveditem + ' Details: ' + sr.getErrors() + '.\r\n';
												errortolog = errortolog == null ? new Integration_Log__c(Log__c = 'Ogiginal Integration_Log__c: ' + logitem.Id + '\r\n', Type__c = 'Ignition Downtime Export', Status__c = 'Error') : errortolog;

												errortolog.Log__c += ' Error inserting Downtime_Log__c: ' + saveditem + ' Details: ' + sr.getErrors() + '\r\n';

												String[] csvraw = saveditem.raw_csv_data__c.split('\r\n');
												OP_Utility.log('***OP_IntegrationBatch csvraw: ' + csvraw);
												errortologcsv += errortologcsv == '' ? csvraw[0] + '\r\n' + csvraw[1] + '\r\n' : csvraw[1] + '\r\n';

											} else {
												successcount++;
												oneWasSuccess = true;
											}
										}
										//only add a new Integration_Log__c if we had partial success
										OP_Utility.log('***OP_IntegrationBatch oneWasSuccess: ' + oneWasSuccess);
										OP_Utility.log('***OP_IntegrationBatch errortolog: ' + errortolog);
										OP_Utility.log('***OP_IntegrationBatch errortologcsv: ' + errortologcsv);
										if (oneWasSuccess && errortolog != null) {
											insert errortolog;
											OP_Utility.log('***OP_IntegrationBatch errortolog: ' + errortolog);
											Attachment att2 = new Attachment();
											att2.Name = 'error.csv';
											att2.ParentId = errortolog.Id;
											att2.Body = Blob.valueOf(errortologcsv);
											insert att2;
											OP_Utility.log('***OP_IntegrationBatch att2: ' + att2);
											emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Partial success processing import file. Failures added to new Integration log id ' + errortolog.Id);

											logitem.Log__c += ' Partial success occured. Failed to add ' + failurecount + ' Downtime_Log__c\'s. They were added to Integration_Log__c: ' + errortolog.id + ' for research.\r\n';
										}

										logitem.Log__c += ' ' + successcount + ' Downtime_Log__c\'s created.\r\n';

										logitem.Status__c = oneWasSuccess ? 'Process Completed' : 'Error';
									}
								}
								else {
									logitem.Log__c += ' Not able to parse csv file. Received: ' + rowdata + '.\r\n';
									logitem.Status__c = 'Error';
									emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Not able to parse csv file. Received: ' + rowdata + '\r\n');
								}

							} catch(Exception ex) {
								OP_Utility.log('***OP_IntegrationBatch Error: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
								logitem.Log__c += ' Error processing file. Error : ' + ex.getMessage() + ' line#: ' + ex.getLineNumber() + '.\r\n';
								logitem.Status__c = 'Error';
								emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "Process Ignition Downtime Export" Exception: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
							}
							logitem.Log__c = OP_Utility.trimChar(logitem.Log__c, 131091);
							OP_Utility.log('***OP_IntegrationBatch logitem: ' + logitem);
							update logitem;
						}
					}
				}
				else if (jobType == 'Prepare Downtime Logs for ProCount') {

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

					OP_Utility.log('***OP_IntegrationBatch headers:' + headers);

					list<list<String>> downtimedata = new list<list<String>> ();
					List<Downtime_Log__c> targets = new List<Downtime_Log__c> ();

					//List<String> pickListValuesList= new List<String>();
					//Schema.DescribeFieldResult fieldResult = ObjectApiName.FieldApiName.getDescribe();
					//List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
					//for( Schema.PicklistEntry pickListVal : ple){
					//pickListValuesList.add(pickListVal.getLabel());
					//}     


					for (Sobject s : scope) {
						if (s.getsObjectType() == Downtime_Log__c.sObjectType) {
							Downtime_Log__c dtlog = (Downtime_Log__c) s;
							list<String> dtlogdata = new list<String> ();
							targets.add(new Downtime_Log__c(Id = dtlog.Id));

							dtlogdata.add(dtlog.integration_id__c);
							dtlogdata.add(String.valueOf(dtlog.Date__c));
							if (dtlog.Asset__r.Equip_ID__c == '99999') {
								dtlogdata.add(dtlog.integration_equip_name__c);
								dtlogdata.add(dtlog.integration_equip_id__c);
							} else {
								dtlogdata.add(dtlog.Asset__r.Name);
								dtlogdata.add(dtlog.Asset__r.Equip_ID__c);
							}

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
						}
					}

					String csvdata = createcsvdata(headers, downtimedata, true, true);
					OP_Utility.log('***OP_IntegrationBatch csvdata:' + csvdata);



					Integration_Log__c logitem = new Integration_Log__c();
					logitem.Type__c = 'ProCount Export';
					logitem.Status__c = 'Pending';
					//logitem.FTP_File_Path__c = ftoption.path;
					//logitem.FTP_File_Name__c = ftoption.file;
					logitem.Log__c = 'Found ' + scope.size() + '  downtime logs to process.';

					insert logitem;

					OP_Utility.log('***OP_IntegrationBatch logitem:' + logitem);

					Attachment att1 = new Attachment();
					att1.Name = 'ProCount.csv';
					att1.ParentId = logitem.Id;
					att1.Body = Blob.valueOf(csvdata);
					insert att1;
					OP_Utility.log('***OP_IntegrationBatch att1:' + att1);


					logitem.Log__c += ' Attachment added Id: ' + att1.Id + '.\r\n';
					logitem.Status__c = 'Ready to Process';


					OP_Utility.log('***OP_IntegrationBatch logitem 2:' + logitem);
					update logitem;

					for (Downtime_Log__c item : targets) {
						item.Send_To_ProCount__c = false;
					}
					OP_Utility.log('***OP_IntegrationBatch targets:' + targets);
					update targets;
				}
				else if (jobType == 'Process Downtime Logs for ProCount') {
					for (Sobject s : scope) {
						if (s.getsObjectType() == Integration_Log__c.sObjectType) {
							Integration_Log__c logitem = (Integration_Log__c) s;
							logitem.Log__c = String.isNotBlank(logitem.Log__c) ? logitem.Log__c : '';
							try
							{
								ftpOptions ftoption = new ftpOptions();
								ftoption.server = OP_Utility.OPIntegrationSettings.REST_FTP_server__c;
								ftoption.port = Integer.valueOf(OP_Utility.OPIntegrationSettings.REST_FTP_server_port__c);
								ftoption.username = OP_Utility.OPIntegrationSettings.REST_FTP_server_username__c;
								ftoption.password = OP_Utility.OPIntegrationSettings.REST_FTP_server_password__c;
								ftoption.path = OP_Utility.OPIntegrationSettings.REST_FTP_ProCount_Upload_Path__c;
								ftoption.useTLS = OP_Utility.OPIntegrationSettings.REST_FTP_server_useTLS__c;
								//ftoption.file = 'ProCount_' + logitem.Id + '.csv';


								ResponseResult getfilelistresults = callFtpApi(ftoption, 'listfiles');
								OP_Utility.log('***OP_IntegrationBatch getfilelistresults:' + getfilelistresults);
								set<String> ftpfiles = new set<String> ();
								if (getfilelistresults.success == true && !getfilelistresults.files.isEmpty()) {
									//cleaning list and only choosing .csv files

									for (string filename : getfilelistresults.files) {

										if (filename.endsWith('.csv')) {
											ftpfiles.add(filename);
										}
									}
								}

								if (ftpfiles.contains(OP_Utility.OPIntegrationSettings.ProCount_File_Name__c))
								{
									logitem.Status__c = 'Holding';
									logitem.Log__c += ' Not uploading file because ' + OP_Utility.OPIntegrationSettings.ProCount_File_Name__c + ' allready exist.\r\n';

								} else {


									ftoption.file = OP_Utility.OPIntegrationSettings.ProCount_File_Name__c;

									logitem.FTP_File_Path__c = ftoption.path;
									logitem.FTP_File_Name__c = ftoption.file;


									Attachment att1 = [Select Id, Name, Body from Attachment where ParentId = :logitem.Id];

									String csvdata = att1.Body.toString();
									ftoption.data = EncodingUtil.base64Encode(att1.Body);

									OP_Utility.log('***OP_IntegrationBatch csvdata:' + csvdata);

									OP_CsvReader csvreader = new OP_CsvReader(csvdata, ',');
									OP_Utility.log('***OP_IntegrationBatch csvreader:' + csvreader);
									string[] rowdata = csvreader.readLine();

									if (rowdata != null) {

										Map<String, Integer> headermap = new Map<String, Integer> ();
										for (Integer i = 0; i<rowdata.size(); i++) {
											headermap.put(rowdata.get(i), i);
										}
										OP_Utility.log('***OP_IntegrationBatch headermap:' + headermap);
										//get second line
										rowdata = csvreader.readLine();
										Set<Id> Downtime_LogIds = new Set<Id> ();
										while (rowdata != null) {
											OP_Utility.log('***OP_IntegrationBatch rowdata:' + rowdata);
											Downtime_LogIds.add(rowdata.get(headermap.get('SF_Id')));
											rowdata = csvreader.readLine();
										}

										ResponseResult uploadfilelistresults = callFtpApi(ftoption, 'addfile');
										OP_Utility.log('***OP_IntegrationBatch uploadfilelistresults:' + uploadfilelistresults);
										if (uploadfilelistresults.success == true) {

											logitem.Log__c += ' File uploaded to ' + ftoption.path + ftoption.file + '.\r\n';
											logitem.Status__c = 'Process Completed';
											List<Downtime_Log__c> toupdate = new List<Downtime_Log__c> ();

											for (Id dtId : Downtime_LogIds) {
												//to be implemented
												toupdate.add(new Downtime_Log__c(Id = dtId, ProCount_Last_Update__c = Datetime.now()));
											}
											update toupdate;

										} else {

											logitem.Status__c = 'Error';
											logitem.Log__c += ' Not able to upload file.\r\n File path: ' + ftoption.path + ' File name: ' + ftoption.file + '  Error : ' + uploadfilelistresults.errors + '.\r\n';
											emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Not able to upload file.\r\n File path: ' + ftoption.path + ' File name: ' + ftoption.file + '  Error : ' + uploadfilelistresults.errors + '\r\n');
										}

									} else {
										logitem.Status__c = 'Error';
										logitem.Log__c += ' Not able to parse file.\r\n';
										emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Not able to parse file\r\n');
									}
								}

							} catch(Exception ex) {
								OP_Utility.log('***OP_IntegrationBatch Error: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
								logitem.Log__c += ' Error processing file. Error : ' + ex.getMessage() + ' line#: ' + ex.getLineNumber() + '.\r\n';
								logitem.Status__c = 'Error';
								emailErrors('Salesforce Integration Batch Job Error Occured', 'Job Type: "' + jobType + '" Exception: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
							}
							logitem.Log__c = OP_Utility.trimChar(logitem.Log__c, 131091);
							OP_Utility.log('***OP_IntegrationBatch logitem: ' + logitem);
							update logitem;
						}
					}
				}
				else if (jobType == 'Cleanup Integration Logs' || jobType == 'Cleanup Downtime Logs') {
					delete scope;
				}
			}
		}
		catch(Exception ex) {
			OP_Utility.log('***OP_IntegrationBatch Exception: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
			continueToNextJob = false;
			emailErrors('Salesforce Integration Batch Job Fatial Error Occured', 'Job Type: "' + jobType + '" Exception: ' + ex.getMessage() + ' line#: ' + ex.getLineNumber());
		}
	}

	public static void emailErrors(String subject, string body) {

		if (String.isNotBlank(OP_Utility.OPIntegrationSettings.Ignition_ProCount_Send_Errors_to_Email__c)) {

			body += String.isNotBlank(body) ? body : '' + ' \r\n\r\nOrg Id: ' + UserInfo.getOrganizationId();
			OP_Utility.sendEmail(new set<string> { OP_Utility.OPIntegrationSettings.Ignition_ProCount_Send_Errors_to_Email__c }, subject, body);
		}

	}

	@TestVisible
	private string createcsvdata(Map<String, Integer> headers, list<list<String>> data, Boolean includeHeader, Boolean includeData) {

		string header = '';
		string row = '';

		Map<Integer, String> headermap = new Map<Integer, String> ();
		for (string key : headers.keySet()) {
			Integer keyval = headers.get(key);
			headermap.put(keyval, key);
		}

		for (Integer i = 0; i<headermap.size(); i++) {
			if (header.length()> 0) { header += ','; }
			if (row.length()> 0) { row += ','; }
			string myheadercol = headermap.get(i);
			header += String.format('"{0}"', new List<String> { myheadercol });
		}

		if (includeData) {
			for (list<String> rowdata : data) {
				string myrow = '';
				for (Integer i = 0; i<headermap.size(); i++) {
					if (myrow.length()> 0) { myrow += ','; }
					string myheadercol = headermap.get(i);
					String mydata = rowdata.get(headers.get(myheadercol));
					mydata = String.isNotBlank(mydata) ? mydata.replace('"', '""') : '';
					myrow += String.format('"{0}"', new List<String> { mydata });
				}
				row += String.format('{0}\r\n', new List<String> { myrow });
			}
		}
		return includeHeader ? (includeData ? String.format('{0}\r\n{1}', new List<String> { header, row }) : String.format('{0}', new List<String> { header })) : String.format('{0}', new List<String> { row });

	}


	@TestVisible
	private static Map<String, HttpResponse> testresponse { get; set; }

	@TestVisible
	private static ResponseResult callFtpApi(ftpOptions options, string method)
	{
		ResponseResult results = new ResponseResult();

		Http http = new Http();
		HttpResponse response = new HttpResponse();
		HttpRequest request = new HttpRequest();

		string surl = OP_Utility.OPIntegrationSettings.REST_FTP_URL__c + '/' + method + '?key=' + OP_Utility.OPIntegrationSettings.REST_FTP_api_Key__c;
		//OP_Utility.log('***callFtpApi surl: ' + surl);
		request.setEndpoint(surl);
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		String sbody = '{"ftpOptions":' + JSON.serialize(options) + '}';
		//OP_Utility.log('***callFtpApi sbody: ' + sbody);
		request.setBody(sbody);
		request.setMethod('POST');
		request.setCompressed(true);
		request.setTimeout(60000);
		try {
			response = Test.isRunningTest() ? (testresponse != null && testresponse.containskey(method) ? testresponse.get(method) : null) : http.send(request);
		} catch(System.CalloutException e) {
			OP_Utility.log('***OP_IntegrationBatch execute Callout error: ' + e);
			//OP_Utility.log('***callFtpApi: ' + response.toString());
		}
		// If the request is successful, parse the JSON response.
		if (response != null && response.getBody() != null) { //response.getStatusCode() == 200) {
			//OP_Utility.log('**callFtpApi response.getBody(): ' + response.getBody());
			// Deserialize the JSON string into collections of primitive data types.

			results = parseFTPresult(response.getBody());
			//Map<String, Object> tresults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		}
		else {
			results.errors.add('Error Status Code: ' + response.getStatusCode());
			results.success = false;
			//results.put('success', false);
			//results.put('errors', new List<String> { 'Error Status Code: ' + response.getStatusCode() });
		}
		//OP_Utility.log('**callFtpApi results: ' + results);
		return results;
	}


	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	public void finish(Database.BatchableContext context) {
		OP_Utility.log('***OP_IntegrationBatch finish jobType:' + jobType + ' filestoprocess: ' + this.filestoprocess + ' continueToNextJob: ' + continueToNextJob);


		if (continueToNextJob) {
			OP_IntegrationBatch batch = null;
			Integer batchsize = 1;
			if (jobType == 'Ignition Downtime Export Download' && (this.filestoprocess != null && !this.filestoprocess.isEmpty()))
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Ignition Downtime Export Download';
				batch.filestoprocess = this.filestoprocess;
				batchsize = 1;
			}
			else if (jobType == 'Ignition Downtime Export Download' && (this.filestoprocess == null || this.filestoprocess.isEmpty()))
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Ignition Downtime Export Download Delete FTP Files';
				batchsize = 1;
			}
			else if (jobType == 'Ignition Downtime Export Download Delete FTP Files')
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Process Ignition Downtime Export';
				batchsize = 1;
			}
			else if (jobType == 'Process Ignition Downtime Export')
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Prepare Downtime Logs for ProCount';
				batchsize = 2000;
			}
			else if (jobType == 'Prepare Downtime Logs for ProCount')
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Process Downtime Logs for ProCount';
				batchsize = 1;
			}
			else if (jobType == 'Process Downtime Logs for ProCount')
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Cleanup Integration Logs';
				batchsize = 200;
			}
			else if (jobType == 'Cleanup Integration Logs')
			{
				batch = new OP_IntegrationBatch();
				batch.jobType = 'Cleanup Downtime Logs';
				batchsize = 2001;
			}
			if (batch != null && !Test.isRunningTest()) {
				OP_Utility.log('***OP_IntegrationBatch finish batch:' + batch);
				database.executebatch(batch, batchsize);
			}

		}

	}
}