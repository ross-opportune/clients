/**
 * @author Bruce Behrens Opportune LLP
 * @date 1-27-2020
 * @description Unit test for OP_CsvReade
 */
@isTest
private class OP_CsvReaderTest {

	@isTest
	private static void unitTest() {

		Test.startTest();
		string csvdata = 'col1,"col2",col3\r\n123,"a""bc",\r\n,,\r\n\r\n';
		OP_CsvReader csvreader = new OP_CsvReader(csvdata, ',');


		string[] rowdata = csvreader.readLine();

		Map<String, Integer> headermap = new Map<String, Integer> ();
		for (Integer i = 0; i<rowdata.size(); i++) {
			headermap.put(rowdata.get(i), i);
		}

		System.assertEquals(true, headermap.containsKey('col1'));
		System.assertEquals(true, headermap.containsKey('col2'));

		//get second line
		rowdata = csvreader.readLine();
		System.assertEquals('123', rowdata.get(headermap.get('col1')));
		System.assertEquals('a"bc', rowdata.get(headermap.get('col2')));
		while (rowdata != null) {

			

			rowdata = csvreader.readLine();
		}

		OP_CsvReader csvreader2 = new OP_CsvReader(csvdata);

		Test.stopTest();

	}
}