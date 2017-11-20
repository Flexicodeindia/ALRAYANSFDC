
$(document).ready(function(){
    $("div#contDiv").fadeIn();
});

app1.controller('Teller_BranchController', ['$scope', function($scope){ 
        $scope.loading = null;
        $scope.imageUrl = imageUrl;
        $scope.signatureUrl = signatureUrl;
        $scope.customerId= customerId;
        
        $scope.testIframe = function(){
            alert('told to refrehs from iframe');
        }
        
       $scope.LoadData = function(){
           $scope.loading = true;
           
           
           /*
           Visualforce.remoting.Manager.invokeAction(
                    "{!$RemoteAction.Teller_CustomerDetailsController.GetData}",$scope.customerId,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        //options.success(result);
                       
                       $scope.response = result;
                        
                                           
                    } // End else
                   
                    $scope.$apply();                    
                });
             */   
                
                
                /*
           Teller_CustomerDetailsController.GetImages($scope.customerId,  function (result, event) {
                    if (event.type == 'exception') {
                        //alert(event.message);
                        $scope.imageClass="redBorder"; 
                    } else {                    
                        //options.success(result);
                       
                       $scope.imageUrl = result.ImageURL; 
                       $scope.signatureUrl = result.SignatureURL;                                             
                       $scope.imageClass="greenBorder";                    
                    } // End else
                    
                    $scope.$apply();
                });
                */
                
          }       
                
                 
            
    }]);

function closeDialog()
{
  var f = $("#dialog").data("kendoWindow");
  if(f)
  {
      f.close();
  }

}

function centerDialog()
{
  var f = $("#dialog").data("kendoWindow");
  if(f)
  {
      f.toggleMaximization();
  }

}



function cancelFunction(paymentId)
        {
          if(paymentId)
          {              
            Teller_CustomerDetailsController.CancelFunction(paymentId,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    }                     
                });
          }

          closeDialog();
        }


function testIframe()
        {
            var scope = angular.element(
                            document.getElementById("AccountListSummary")).
                            scope();
                            scope.$apply(function () {
                                scope.LoadData ();
                            });
        }


app1.controller('AccountListSummaryController', ['$scope', function($scope){
    

        $scope.AccountFunction= function(accountId,url,title)
        {
            var f = $("#dialog").data("kendoWindow");
            if (f === undefined) {
                 var d =$("#dialog").kendoWindow({
            content: url + "?acc=" + accountId + "&customer=" + $scope.customerId,
            iframe: true,
            title: title,
            width: "700px",
            height: "500px",
            actions: [],
            

            modal:true
        });
            
            }
            else
            {
                f.content('Loading...');
                f.refresh({
                    url: url + "?acc=" + accountId + "&customer=" + $scope.customerId
                });
                
                f.open();
            }
  
          var d = $("#dialog").data("kendoWindow");
          d.center();
          d.maximize();
       }
        
       $scope.LoadData = function(){
           $scope.loading = true;
           Teller_CustomerDetailsController.GetData($scope.customerId,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        //options.success(result);
                       
                       $scope.response= result;
                        
                                           
                    } // End else
                    $scope.$apply();
                });
            }
      
       
    }])

function SetupPopup()
{
    $("[rel='popover']").popover();
}

