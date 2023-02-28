/**
 * @author Bruce Behrens Opportune LLP
 * @description unit test for OP_IntegrationStatusController
 * @date 1-30-2020
*/
@isTest 
private class OP_IntegrationStatusControllerTest {

	@isTest
	private static void controllerTest() {

		Test.startTest();

		OP_IntegrationStatusController.addNewSchedule('test 504',2,0);

		OP_IntegrationStatusController.getScheduledJobs();
		OP_IntegrationStatusController.getApexJobs();
		OP_IntegrationStatusController.getIntegrationLogs();
		OP_IntegrationStatusController.runJobNow();
		OP_IntegrationStatusController.getReadyForProCount();
		OP_IntegrationStatusController.getRecentDowntimeLogs();


		Test.stopTest();
	}
}