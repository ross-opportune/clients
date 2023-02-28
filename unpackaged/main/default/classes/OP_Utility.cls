/**
 * @author Bruce Behrens Opportune LLP
 * @description untility class
 * @date 1-24-2020
*/
public inherited sharing class OP_Utility {

	public static void log(Object v)
	{
		if (v != null && OPSettings.Enable_Logging__c == true)
		{
			System.debug(v);
		}
	}

	public static Ignition_ProCount_Integration_Settings__mdt OPIntegrationSettings
	{
		get
		{
			if (OPIntegrationSettings == null)
			{
				List<Ignition_ProCount_Integration_Settings__mdt> settings = new List<Ignition_ProCount_Integration_Settings__mdt> ([SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, REST_FTP_URL__c
				                                                                                                                    , REST_FTP_server_useTLS__c, REST_FTP_server_username__c, REST_FTP_server_port__c, REST_FTP_server_password__c
				                                                                                                                    , REST_FTP_server__c, REST_FTP_ProCount_Upload_Path__c, REST_FTP_Ignition_Download_Path__c, REST_FTP_api_Key__c
				                                                                                                                    , ProCount_File_Name__c, Ignition_ProCount_Send_Errors_to_Email__c, Delete_Integration_Logs_after_x_days__c
				                                                                                                                    , Delete_Downtime_Logs_after_x_days__c, Enabled__c FROM Ignition_ProCount_Integration_Settings__mdt where DeveloperName = 'Default']);
				OPIntegrationSettings = settings.isEmpty() ? (Ignition_ProCount_Integration_Settings__mdt)getMetadata('Ignition_ProCount_Integration_Settings__mdt', new Map<String, Object> {'Enabled__c' => false}) : settings.get(0);
			}
			return OPIntegrationSettings;
		}
		set;
	}

	public static SObject getMetadata(string sObjectApi, Map<String, Object> fields) {

		Schema.SObjectType metadataSObjectType = gd.get(sObjectApi);

		Map<String, Object> jsonFields = new Map<String, Object> {
			'attributes' => new Map<String, Object> {
				'type' => metadataSObjectType.getDescribe().getName()
			}
		};
		if (fields != null) {
			jsonFields.putAll(fields);
		}
		return(SObject) JSON.deserialize(JSON.serialize(jsonFields), SObject.class);
	}


	public static OP_Settings__c OPSettings
	{
		get
		{
			if (OPSettings == null)
			{
				OPSettings = OP_Settings__c.getInstance(UserInfo.getUserId());
				if (Test.isRunningTest())
				{
					if (OP_Settings__c.Id == null)
					{
						insert OPSettings;
					}
				}
			}
			return OPSettings;
		}
		set;
	}

	public static String trimChar(String value, Integer maxchar)
	{
		if (value != null && value.length() > maxchar)
		{
			return value.substring(0, maxchar);
		}
		return value;
	}

	public static void sendEmail(set<string> emails, string subject, string body)
	{
		log('***SendEmail emails:' + emails);
		log('***SendEmail subject:' + subject);
		log('***SendEmail body:' + body);
		try
		{
			if (!emails.isEmpty())
			{
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new List<String> (emails));
				mail.setSubject(subject);
				mail.setHtmlBody(body);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				log('***SendEmail Success');
			}
		}
		catch(Exception e)
		{
			log('***SendEmail Error sending email Error: ' + e.getMessage());
		}
	}

	/**
	 * @description returns a set of valid query fields
	 * @param fieldsCSV comma delimited list of fields
	 * @param mysObject target sobject
	 * @return 
	 */
	public static List<String> getExistingFieldsFromCsv(string fieldsCSV, string mysObject)
	{
		List<string> results = new List<string> ();
		log('***getExistingFieldsFromCsv fieldsCSV: ' + fieldsCSV + ' mysObject: ' + mysObject);
		if (SOjectExist(mysObject))
		{
			Map<String, Schema.SObjectField> targetFields = gd.get(mysObject).getDescribe().fields.getMap();
			log(JSON.serializePretty(targetFields.keySet()));
			for (String s : fieldsCSV.split(','))
			{
				log('***getExistingFieldsFromCsv s: (' + s + ') info:' + (targetFields.containsKey(s.trim().tolowercase())));

				if (String.isNotBlank(s.trim()) && targetFields.containsKey(s.trim().tolowercase()))
				{
					string fname = targetFields.get(s.trim().tolowercase()).getDescribe().getName();
					log('***getExistingFieldsFromCsv fname: (' + fname + ') results.contains(fname):' + (results.contains(fname)));
					if (!results.contains(fname)) {
						results.add(fname);
					}
				}
			}
		}
		log('***getExistingFieldsFromCsv results: (' + results + ')');
		return results;
	}

	public static Map<String, Schema.SObjectType> gd
	{
		get
		{
			if (gd == null)
			{
				gd = Schema.getGlobalDescribe();
			}
			return gd;
		}
		set;
	}

	/**
	 * @description generic method to query sObjects
	 * @param searchfor search value
	 * @param targetSobject sObject to query
	 * @param searchfields fields to search
	 * @param resultfields fields to return
	 * @param additionalWhere addatitional where to add to the query
	 * @param queryOptions - used to add to the end of soql query . example order by
	 * @param querylimit limit - null or <1 to exclude a limit
	 * @return 
	 */
	@AuraEnabled(Cacheable = true)
	public static list<SObject> getSobjectResults(string searchfor, string targetSobject, string searchfields, string resultfields, string additionalWhere, String queryOptions, Integer querylimit)
	{
		log('***getSobjectResults searchfor: ' + searchfor + ' targetSobject: ' + targetSobject + ' searchfields: ' + searchfields + ' resultfields: ' + resultfields + ' additionalWhere: ' + additionalWhere + ' querylimit: ' + querylimit);
		list<SObject> results = new list<SObject> ();
		string searchfor2 = '' + string.escapeSingleQuotes(searchfor) + '%';

		list<string> cleanSearchFields = getExistingFieldsFromCsv(searchfields, targetSobject);
		if (!cleanSearchFields.contains('Name')) { cleanSearchFields.add('Name'); }
		log('***getSobjectResults cleanSearchFields: ' + cleanSearchFields);


		list<string> cleanResultfields = getExistingFieldsFromCsv(resultfields, targetSobject);
		log('***getSobjectResults cleanResultfields: ' + cleanResultfields);

		if (!cleanResultfields.contains('Id')) { cleanResultfields.add('Id'); }
		if (!cleanResultfields.contains('Name')) { cleanResultfields.add('Name'); }
		if (!cleanResultfields.contains('CreatedDate')) { cleanResultfields.add('CreatedDate'); }

		list<string> addcleanResultfields = new list<string> ();
		for (String fieldName : cleanResultfields)
		{
			Schema.DescribeFieldResult f = gd.get(targetSobject).getDescribe().fields.getMap().get(fieldName).getDescribe();
			if (f.getType() == Schema.DisplayType.REFERENCE)
			{
				string sname = f.getRelationshipName() + '.Name';
				if (!cleanResultfields.contains(sname) && !addcleanResultfields.contains(sname)) { addcleanResultfields.add(sname); }
			}
		}
		cleanResultfields.addAll(addcleanResultfields);

		string query = 'Select ' + String.join(new list<String> (cleanResultfields), ',') + ' from ' + targetSobject + ' Where IsDeleted = false';


		Map<string, string> objFieldTypeMap = new Map<string, string> ();
		Map<string, string> searchforMap = new Map<string, string> ();
		for (String fieldName : cleanSearchFields)
		{
			Schema.DescribeFieldResult f = gd.get(targetSobject).getDescribe().fields.getMap().get(fieldName).getDescribe();
			objFieldTypeMap.put(f.getName(), String.valueOf(f.getSoapType()));
			searchforMap.put(f.getName(), searchfor);
		}

		string myqueryAdditionalWhere = String.join(new list<String> (buildWhere(objFieldTypeMap, searchforMap).values()), ' OR '); //buildWhere(objFieldTypeMap, searchforMap);
		if (String.isNotBlank(myqueryAdditionalWhere))
		{
			query += ' AND (' + myqueryAdditionalWhere + ') ';
		}

		if (String.isNotBlank(additionalWhere))
		{
			query += ' AND (' + additionalWhere + ') ';
		}

		if (String.isNotBlank(queryOptions))
		{
			query += ' ' + queryOptions;
		}

		if (querylimit != null && querylimit > 0)
		{
			query += ' LIMIT ' + String.valueOf(querylimit);
		}

		log('***getSobjectResults query: ' + query);


		return Database.query(query);

	}

	/**
	 * @description returns map of search items for soql query 
	 * @param objFieldTypeMap map of fileds to search ( field api name => field display type )
	 * @param searchfor map of fileds to search and the search value  ( field api name => search value )
	  /* if field display type is DATE or DATETIME you can include a additional value in searchfor as FieldApiName_To to include a range
	 * @return 
	 */
	public static Map<string, string> buildWhere(Map<string, string> objFieldTypeMap, map<string, string> searchfor)
	{
		set<string> usedforsearch = new set<string> ();
		map<String, string> whereclause = new map<String, string> ();
		if (objFieldTypeMap != null && searchfor != null)
		{
			for (string searchforFieldName : searchfor.keySet())
			{
				if (!objFieldTypeMap.containsKey(searchforFieldName) || usedforsearch.contains(searchforFieldName)) { continue; }

				String fieldPath = searchforFieldName;
				String fieldType = objFieldTypeMap.get(searchforFieldName);
				fieldType = fieldType.toUpperCase();
				String searchString = searchfor.get(searchforFieldName).trim();
				String keywordStr = '%' + String.escapeSingleQuotes(searchString) + '%';
				log('***buildWhere searchforFieldName: ' + searchforFieldName + ' fieldType: ' + fieldType);

				if (fieldType == 'STRING'
				    || fieldType == 'EMAIL'
				    || fieldType == 'PHONE'
				)
				{
					whereclause.put(fieldPath, fieldPath + ' LIKE \'' + keywordStr + '\'');
					usedforsearch.add(fieldPath);
				}
				else if (fieldType == 'MULTIPICKLIST')
				{
					if (searchString.startsWith(';') || searchString.startsWith(','))
					{
						searchString = searchString.substring(1);
					}
					if (searchString.endsWith(';') || searchString.endsWith(','))
					{
						searchString = searchString.substring(0, searchString.length() - 1);
					}
					searchString = searchString.replace(',', ';');
					whereclause.put(fieldPath, fieldPath + ' includes (\'' + String.escapeSingleQuotes(searchString) + '\')');
					usedforsearch.add(fieldPath);
				}
				else if (fieldType == 'PICKLIST')
				{
					boolean isMulti = searchfor.containsKey(fieldPath + '_Ismulti');
					log('***buildWhere isMulti: ' + isMulti);
					if (isMulti == true)
					{
						if (searchString.startsWith(';') || searchString.startsWith(','))
						{
							searchString = searchString.substring(1);
						}
						if (searchString.endsWith(';') || searchString.endsWith(','))
						{
							searchString = searchString.substring(0, searchString.length() - 1);
						}
						searchString = searchString.replace(',', ';');

						Set<string> mysearch = new Set<string> ();
						for (String s : searchString.split(';'))
						{
							if (String.isNotBlank(s.trim()))
							{
								mysearch.add(fieldPath + ' = \'' + String.escapeSingleQuotes(s) + '\'');
							}
						}
						if (mysearch.isEmpty() == false) {
							whereclause.put(fieldPath, '( ' + String.join(new List<String> (mysearch), ' OR ') + ' )');
							usedforsearch.add(fieldPath);
						}
					}
					else {
						whereclause.put(fieldPath, fieldPath + ' = \'' + String.escapeSingleQuotes(searchString) + '\'');
						usedforsearch.add(fieldPath);
					}

				}
				else if (fieldType == 'REFERENCE')
				{
					String searchString2 = searchfor.containsKey(fieldPath + ':id') ? searchfor.get(fieldPath + ':id').trim() : '';
					boolean isMulti = searchfor.containsKey(fieldPath + '_Ismulti');
					log('***buildWhere isMulti: ' + isMulti);
					if (isMulti && fieldPath.endsWith('RecordTypeId'))
					{
						if (searchString.startsWith(';') || searchString.startsWith(','))
						{
							searchString = searchString.substring(1);
						}
						if (searchString.endsWith(';') || searchString.endsWith(','))
						{
							searchString = searchString.substring(0, searchString.length() - 1);
						}
						searchString = searchString.replace(',', ';');

						Set<string> mysearch = new Set<string> ();
						for (String s : searchString.split(';'))
						{
							if (String.isNotBlank(s.trim()))
							{
								mysearch.add(fieldPath + ' = \'' + String.escapeSingleQuotes(s) + '\'');
							}
						}
						if (mysearch.isEmpty() == false) {
							whereclause.put(fieldPath, '( ' + String.join(new List<String> (mysearch), ' OR ') + ' )');
							usedforsearch.add(fieldPath);
						}
					}
					else if (searchfor.containsKey(fieldPath + ':id') == true && isId(searchString2) == true)
					{
						whereclause.put(fieldPath, fieldPath + ' = \'' + searchString2 + '\'');
						usedforsearch.add(fieldPath);
					}
					else
					{
						string myfield = fieldPath;
						if (myfield.endsWith('__c'))
						{
							myfield = myfield.substring(0, myfield.length() - 1) + 'r';
						}
						if (myfield.endsWith('Id'))
						{
							myfield = myfield.substring(0, myfield.length() - 2);
						}
						myfield += '.Name';
						whereclause.put(fieldPath, myfield + ' LIKE \'' + keywordStr + '\'');
						usedforsearch.add(fieldPath);
					}
				}
				else if ((fieldType == 'CURRENCY'
				          || fieldType == 'DOUBLE'
				          || fieldType == 'PERCENT'
				          || fieldType == 'INTEGER'
				)
				         && isNumber(searchString.replace('$', '').replace(',', '')) == true
				)
				{
					boolean hasrange = searchfor.containsKey(fieldPath + '_To');
					if (hasrange == true && isNumber(searchfor.get(fieldPath + '_To').replace('$', '').replace(',', '')) == true)
					{
						string tostrvalue = searchfor.get(fieldPath + '_To').replace('$', '').replace(',', '');
						whereclause.put(fieldPath, '( ' + fieldPath + ' >= ' + searchString.replace('$', '').replace(',', '') + ' and ' + fieldPath + ' <= ' + tostrvalue + ' )');
						usedforsearch.add(fieldPath);
					}
					else
					{
						whereclause.put(fieldPath, fieldPath + ' = ' + searchString.replace('$', '').replace(',', ''));
						usedforsearch.add(fieldPath);
					}
				}
				else if (fieldType == 'DATE')
				{
					boolean hasrange = searchfor.containsKey(fieldPath + '_To');
					Datetime dt1 = Datetime.valueOf(searchString.replace('T', ' ')).date();
					if (hasrange == true)
					{
						string searchString2 = searchfor.get(fieldPath + '_To');
						Datetime dt2 = Datetime.valueOf(searchString2.replace('T', ' ')).date();
						whereclause.put(fieldPath, '(' + fieldPath + ' >= ' + dt1.formatGmt('yyyy-MM-dd') + ' AND ' + fieldPath + ' <= ' + dt2.formatGmt('yyyy-MM-dd') + ')');
						usedforsearch.add(fieldPath + '_To');
					}
					else
					{
						whereclause.put(fieldPath, fieldPath + ' = ' + dt1.formatGmt('yyyy-MM-dd'));
					}
					usedforsearch.add(fieldPath);
				}
				else if (fieldType == 'DATETIME')
				{
					boolean hasrange = searchfor.containsKey(fieldPath + '_To');

					Datetime dt1 = Datetime.valueOfGmt(searchString.replace('T', ' '));

					string sdt1 = getQueryDate(dt1);
					if (hasrange == true)
					{
						string searchString2 = searchfor.get(fieldPath + '_To');
						Datetime dt2 = Datetime.valueOfGmt(searchString2.replace('T', ' '));
						string sdt2 = getQueryDate(dt2);
						whereclause.put(fieldPath, '(' + fieldPath + ' >= ' + sdt1 + ' AND ' + fieldPath + ' <= ' + sdt2 + ' )');
						usedforsearch.add(fieldPath + '_To');
					}
					else
					{
						whereclause.put(fieldPath, fieldPath + ' = ' + sdt1);
					}
					usedforsearch.add(fieldPath);
				}
				else if (fieldType == 'BOOLEAN' && isBoolean(searchString))
				{
					whereclause.put(fieldPath, fieldPath + ' = ' + toBoolean(searchString));
					usedforsearch.add(fieldPath);
				}
			}
		}
		return whereclause;
	}

	public static String getQueryDate(Datetime dt1)
	{
		string result = '';
		if (dt1 != null)
		{
			result = padstring(string.valueOf(dt1.yearGmt()), '0', 2) + '-' + padstring(string.valueOf(dt1.monthGmt()), '0', 2) + '-' + padstring(string.valueOf(dt1.dayGmt()), '0', 2) + 'T' + padstring(string.valueOf(dt1.hourGmt()), '0', 2) + ':' + padstring(string.valueOf(dt1.minuteGmt()), '0', 2) + ':' + padstring(string.valueOf(dt1.secondGmt()), '0', 2) + 'Z';
		}
		return result;
	}

	public static String padString(string z, string padchar, integer stringsize)
	{
		string result = z == null ? '' : z;
		if (padchar.length() > 0)
		{
			while (result.length() < stringsize)
			{
				result = padchar + result;
			}
		}
		return result;
	}

	public static Boolean isBoolean(string v)
	{
		boolean result = false;
		if (v != null)
		{
			set<string> truevalues = new set<string> { '1', 'on', 'true', 'yes' };
			set<string> falsevalues = new set<string> { '0', 'off', 'false', 'no' };
			v = v.toLowerCase();
			if (truevalues.contains(v) || falsevalues.contains(v))
			{
				result = true;
			}
		}
		return result;
	}

	public static Boolean toBoolean(string v)
	{
		boolean result = false;
		if (v != null)
		{
			set<string> truevalues = new set<string> { '1', 'on', 'true', 'yes' };
			set<string> falsevalues = new set<string> { '0', 'off', 'false', 'no' };
			v = v.toLowerCase();
			if (truevalues.contains(v))
			{
				result = true;
			}
			else if (falsevalues.contains(v))
			{
				result = false;
			}
		}
		return result;
	}

	public static boolean isId(String v)
	{
		try
		{
			Id test = Id.valueOf(v);
			return true;
		}
		catch(Exception e)
		{
			return false;
		}
	}

	public static Boolean isNumber(string v)
	{
		boolean result = false;
		try
		{
			if (v != null) // && v.isNumeric())
			{
				Decimal t1 = Decimal.valueOf(v);
				result = true;
			}
		}
		catch(Exception e)
		{
			result = false;
		}
		return result;
	}

	public static boolean sOjectExist(String sobjectapiname)
	{
		if (String.isNotBlank(sobjectapiname))
		{
			return gd.containsKey(sobjectapiname.toLowerCase());
		}
		return false;
	}

	@AuraEnabled
	public static List<FatchValueWrapper> fetchPickListValue(string sObjectApi, string picklistFieldApi) {
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = gd.get(sObjectApi).getDescribe(); //objInfo.getSObjectType().getDescribe();

		// Get a map of fields for the SObject
		map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

		// Get the list of picklist values for this field.
		list<Schema.PicklistEntry> values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();

		// Create a list of wrapper to store picklist value/lable
		list<FatchValueWrapper> objWrapper = new list<FatchValueWrapper> ();

		for (Schema.PicklistEntry a : values) {
			FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
			oFatchValueWrapper.label = a.getLabel();
			oFatchValueWrapper.value = a.getValue();
			objWrapper.add(oFatchValueWrapper);
		}
		return objWrapper;

	}
	// wrapper class 
	public with sharing class FatchValueWrapper {
		@auraEnabled public string label { get; set; }
		@auraEnabled public string value { get; set; }
	}

	@auraEnabled
	public static Map<Object, List<String>> getDependentPicklistValues(string targetSobject, string fieldName)
	{
		Schema.DescribeFieldResult depend = gd.get(targetSobject).getDescribe().fields.getMap().get(fieldName).getDescribe();
		Schema.sObjectField controlToken = depend.getController();
		if (controlToken == null) return null;
		Schema.DescribeFieldResult control = controlToken.getDescribe();
		List<Schema.PicklistEntry> controlEntries =
		(control.getType() == Schema.DisplayType.Boolean
		 ? null
		 : control.getPicklistValues()
		);

		String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
		Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>> ();
		for (Schema.PicklistEntry entry : depend.getPicklistValues()) if (entry.isActive())
		{
			List<String> base64chars =
			String.valueOf
			(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
			).split('');
			for (Integer index = 0; index<(controlEntries != null ? controlEntries.size() : 2); index++)
			{
				//Object controlValue =
				//(controlEntries == null
				//? (Object) (index == 1)
				//: (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
				//);
				Object controlValue =
				(controlEntries == null
				 ? (Object) (index == 1)
				 : (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
				);

				Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
				if (controlValue == null
				    || (base64map.indexOf(base64chars[bitIndex]) & (1 <<bitShift)) == 0
				) continue;
				if (!dependentPicklistValues.containsKey(controlValue))
				{
					dependentPicklistValues.put(controlValue, new List<String> ());
				}
				//dependentPicklistValues.get(controlValue).add(entry.getLabel());
				dependentPicklistValues.get(controlValue).add(entry.getValue());
			}
		}
		return dependentPicklistValues;
	}

}