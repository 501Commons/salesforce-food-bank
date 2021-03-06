@isTest(SeeAllData=false)
public with sharing class FoodBankManagerTest {

    @isTest
    private static void testCheckOutIn() {
        // New Household insert then update
        Client_Household__c cHh = new Client_Household__c();
        insert(cHh);

        // Test CheckIn & CheckOut
        FoodBankManager.checkIn(cHh.Id);
        System.assert(Food_Bank_Checkin__c.getInstance(cHh.Id) != null);

        // Attempt to CheckIn again should throw error
        try {
            FoodBankManager.checkIn(cHh.Id);
            System.assert(false, 'Error should have occured');
        } catch (Exception ex) {
            // Nothing to see here
            // TODO: check to see if correct error is thrown
        }

        FoodBankManager.cancelCheckIn(cHh.Id);
        System.assert(Food_Bank_Checkin__c.getInstance(cHh.Id) == null);
    }

    @isTest
    private static void testSaveHouseHold() {
        Client_Household__c cHh = new Client_Household__c(
            Inactive__c = false
        );
        
        // Check insert of Household
        Client_Household__c cHh0 = FoodBankManager.saveHousehold(cHh);
        System.assert(cHh0.Id != null, 'Id should not be null');

        // Check update of Household
        cHh.Address__c = '101 1st St';
        cHh0 = FoodBankManager.saveHousehold(cHh);
        System.assert(cHh0.Address__c == cHh.Address__c, 'Method did not update Household: ' + cHh0.Children__c);

        // Insert Client
        Client__c c1 = new Client__c( Client_Household__c = null, last_name__c = 'Test1', birthdate__c = System.today().addyears(-50) );
        cHh0 = FoodBankManager.saveHouseholdMembers(cHh.Id, new List<Client__c> { c1 });
        System.assert(cHh0.Client_Names__c != null, 'Method did not update Household: ' + cHh0.Client_Names__c);

        // Update Client
        c1.first_name__c = 'Test2';
        cHh0 = FoodBankManager.saveHouseholdMembers(cHh.Id, new List<Client__c> { c1 });
        System.assert(cHh0.Client_Names__c != null, 'Method did not update Household: ' + cHh0.Client_Names__c);
        System.debug('***** Client Name: ' + cHh0.Client_Names__c);
        System.debug('***** Inactive: ' + cHh0.Inactive__c);

        List<FoodBankManager.ClientHousehold> cHs = FoodBankManager.queryHouseholds(cHh0.Client_Names__c);
// TODO     // system.assertEquals(1, cHs.size(), 'Could not find: ' + cHh0.Client_Names__c);   

        // Save new Household and Client
        Client_Household__c cHh1 = new Client_Household__c();
        Client__c c2 = new Client__c( Client_Household__c = null, last_name__c = 'Test1', birthdate__c = System.today().addyears(-50) );
        Client_Household__c cHh2 = FoodBankManager.saveHouseholdAndMembers(cHh1, new List<Client__c> { c2 });       
        System.assert(cHh2.Id != null, 'Id should not be null');
        
        FoodBankManager.AppSettings appSettings = FoodBankManager.getAppSettings();
        system.assert(appSettings.general != null);
    }


	@isTest
	private static void testCheckInsVisits() {
		Client_Household__c household1 = new Client_Household__c(
			Inactive__c = false
		);
		
		// Check insert of Household
		household1 = FoodBankManager.saveHousehold(household1);

		Food_Bank_Checkin__c checkin1 = new Food_Bank_Checkin__c(
			Name = household1.Id,
            Client_Name__c = 'Household 1',
            Points_Remaining__c = 15,
            Box_Size__c = 'small',
            Check_In_Time__c = Datetime.now()
        );

		insert checkin1;

		Client_Household__c household2 = new Client_Household__c(
			Inactive__c = false
		);
		
		// Check insert of Household
		household2 = FoodBankManager.saveHousehold(household2);

		Food_Bank_Checkin__c checkin2 = new Food_Bank_Checkin__c(
			Name = household2.Id,
            Client_Name__c = 'Household 2',
            Points_Remaining__c = 15,
            Box_Size__c = 'small',
            Check_In_Time__c = Datetime.now()
        );
		insert checkin2;

		List<FoodBankManager.ClientCheckin> cc = FoodBankManager.getCheckedInList();
		System.assertEquals(2, cc.size(), 'Two households are currently checked in');

		Map<String, Integer> commU = new Map<String, Integer>();
		commU.put('Meat', 2);
		commU.put('Bread', 1);
		Id cVId = FoodBankManager.logVisit(household1.Id, 'Big', 5, commU, 'These are notes');
		System.assert(cVId != null);

		List<Client_Visit__c> cV = FoodBankManager.getVisitHistory(household1.Id);
		system.assert(cV.size() == 1);	
	}	

    @isTest
    private static void testHHBatch() {
        // New Household insert then update
        Client_Household__c cHh = new Client_Household__c();
        insert(cHh);
        FoodBankHouseholds.runBatchManually();
     }
}