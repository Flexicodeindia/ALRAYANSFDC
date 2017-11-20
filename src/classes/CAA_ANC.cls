public class CAA_ANC
{
    public static CAA_Data.GenericResponse Create(String ancType,String Id)
    {
        if(string.isBlank(ancType)) return null;
        
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        //get the product
        IBB_Product__c product = [select id from IBB_Product__c where name=:ancType]; 
        
        
        CAA_Data.ProductSelectedData data = new CAA_Data.ProductSelectedData();
        data.numberofApplicants = 1;
        data.Over16 = 'yes';
        data.ProductId = product.id;
        
        
        system.debug('accid:' + id );
        if(string.isNotBlank(id))
            data.Accountid = id;
        
        //Added 4 new parameters for Data protection changes
        response.url = CAA_Product.ProductSelected(data,null,'false','false','false','false');       
        return response;      
        
    }
}