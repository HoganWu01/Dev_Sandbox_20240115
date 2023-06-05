@isTest(SeeAllData = true)
private class LwcProjectControllerTest {

    @isTest
    static void testGetRelatedTasks() {
        List<Object> data = LwcProjectController.getRelatedTasks('');
        // System.assertNotEquals(data.size(), 0);
        System.assert(data.size() == 0);
    }
}