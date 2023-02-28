/**
 * @author Bruce Behrens Opportune LLP
 * @date 1-27-2020
 * @description Unit test for OP_Utility
 */
@isTest
private class OP_UtilityTest {

	@isTest
	private static void logtest() {
		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		OP_Utility.log('test');
		System.debug('***logtest test complete');
		Test.stopTest();
	}

	@isTest
	private static void OPIntegrationSettingstest() {
		Test.startTest();
		System.debug('***OPIntegrationSettingstest:  ' + OP_Utility.OPIntegrationSettings.Enabled__c);
		Test.stopTest();
	}

	@isTest
	private static void getMetadatatest() {
		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;

		Ignition_ProCount_Integration_Settings__mdt test1 = (Ignition_ProCount_Integration_Settings__mdt) OP_Utility.getMetadata('Ignition_ProCount_Integration_Settings__mdt', new Map<String, Object> { 'Enabled__c' => true });
		
		System.assertEquals(true, test1.Enabled__c);

		Ignition_ProCount_Integration_Settings__mdt test2 = (Ignition_ProCount_Integration_Settings__mdt) OP_Utility.getMetadata('Ignition_ProCount_Integration_Settings__mdt', new Map<String, Object> { 'Enabled__c' => false }); 

		System.assertEquals(false, test2.Enabled__c);
		
		Test.stopTest();
	}


	@isTest
	private static void trimCharTest() {
		Test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals('12345', OP_Utility.trimChar('123456789', 5));

		System.assertEquals('123456789', OP_Utility.trimChar('123456789', 10));


		Test.stopTest();
	}

	@isTest
	private static void sendEmailTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		OP_Utility.sendEmail(new set<string> { 'test@test.com' }, 'test subject', 'test body');
		test.stopTest();
	}

	@isTest
	private static void getExistingFieldsFromCsvTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals(true, OP_Utility.getExistingFieldsFromCsv('name,id,count', 'Account').contains('Name'));

		test.stopTest();
	}


	@isTest
	private static void getSobjectResultsTest()
	{
		Account a1 = new Account(Name = 'test 1');
		insert a1;

		Account a2 = new Account(Name = 'test 2', parentId = a1.Id);
		insert a2;

		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;


		//let searchparams = { searchfor: this.value, targetSobject:this.targetSobject,searchfields:'Name', resultfields:'Id,Name',additionalWhere:'',queryOptions:this.queryOptions,querylimit:this.querylimit};

		System.assertEquals(1, OP_Utility.getSobjectResults('test', 'Account', 'Name,ParentId', 'Name,Id', 'ParentId != null', 'Order by Name', 200).size());

		test.stopTest();
	}
	//(Map<string, string> objFieldTypeMap, map<string, string> searchfor)
	@isTest
	private static void buildWhereTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals('test__c LIKE \'%test%\'', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'string' }, new Map<string, string> { 'test__c' => 'test' }).values().get(0));
		System.assertEquals('test__c includes (\'test\')', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'MULTIPICKLIST' }, new Map<string, string> { 'test__c' => 'test' }).values().get(0));
		System.assertEquals('test__c includes (\'test\')', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'MULTIPICKLIST' }, new Map<string, string> { 'test__c' => ';test,' }).values().get(0));
		System.assertEquals('test__r.Name LIKE \'%test%\'', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'REFERENCE' }, new Map<string, string> { 'test__c' => 'test' }).values().get(0));
		System.assertEquals('test__c = 1.07', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'CURRENCY' }, new Map<string, string> { 'test__c' => '$1.07' }).values().get(0));

		Datetime dt1 = Datetime.newInstance(2017, 11, 11);
		string dt1str = dt1.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		System.assertEquals('test__c = 2017-11-11', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'DATE' }, new Map<string, string> { 'test__c' => dt1str }).values().get(0));

		System.assertEquals('(test__c >= 2017-11-11 AND test__c <= 2017-11-11)', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'DATE' }, new Map<string, string> { 'test__c' => dt1str, 'test__c_To' => dt1str }).values().get(0));

		OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'DATETIME' }, new Map<string, string> { 'test__c' => dt1str });

		OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'DATETIME' }, new Map<string, string> { 'test__c' => dt1str, 'test__c_To' => dt1str });

		System.assertEquals('test__c = true', OP_Utility.BuildWhere(new Map<string, string> { 'test__c' => 'boolean' }, new Map<string, string> { 'test__c' => 'true' }).values().get(0));

		test.stopTest();
	}

	@isTest
	private static void getQueryDateTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Datetime dt1 = Datetime.now();
		System.assert(OP_Utility.getQueryDate(dt1) != '');

		test.stopTest();
	}

	@isTest
	private static void padStringTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		Datetime dt1 = Datetime.now();
		System.assertEquals('000', OP_Utility.padString('0', '0', 3));

		test.stopTest();
	}

	@isTest
	private static void isBooleanTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals(false, OP_Utility.IsBoolean('aa'));
		System.assertEquals(true, OP_Utility.IsBoolean('true'));
		test.stopTest();
	}

	@isTest
	private static void toBooleanTest()
	{
		test.startTest();
		System.assertEquals(true, OP_Utility.ToBoolean('1'));
		System.assertEquals(false, OP_Utility.ToBoolean('false'));

		test.stopTest();
	}

	@isTest
	private static void isIdTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals(true, OP_Utility.isId(UserInfo.getUserId()));
		System.assertEquals(false, OP_Utility.isId('abc'));

		test.stopTest();
	}

	@isTest
	private static void isNumberTest()
	{
		test.startTest();

		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals(false, OP_Utility.IsNumber('aa'));
		System.assertEquals(true, OP_Utility.IsNumber('1'));

		test.stopTest();
	}

	@isTest
	private static void sOjectExistTest()
	{
		test.startTest();
		OP_Utility.OPSettings.Enable_Logging__c = true;
		System.assertEquals(true, OP_Utility.SOjectExist('Account'));

		test.stopTest();
	}



	@isTest
	private static void testPicklistController()
	{
		Test.startTest();
		Map<Object, List<String>> result = OP_Utility.getDependentPicklistValues('Downtime_Log__c', 'Parent_Code__c');
		Test.stopTest();
		//List<String> resultList = result.get( 'Well Downtime' );
		//System.assert( resultList != null );
		//System.assert( resultList.size() == 1 );
		//System.assert( resultList[0] == 'Ugly' );
		//resultList = result.get( 'Compressor Downtime' );
		//System.assert( resultList != null );
		//System.assert( resultList.size() == 2 );
		//System.assert( resultList[0] == 'Good' );
		//System.assert( resultList[1] == 'Bad' );
		//resultList = result.get( 'Unused' );
		// System.assert( resultList == null );
	}


}