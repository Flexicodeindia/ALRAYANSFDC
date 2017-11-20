public class HPPReceivedbyCredit extends HPPBaseEventController {
  public HPPReceivedbyCredit() {
    
  }
  
  public PageReference complete() {
    try {
      update exOpp;
      update Opp;
     
            
      CompleteEvent();
      return GoToNextEvent();
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
    return null;
  }
}