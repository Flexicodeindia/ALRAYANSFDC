app1.controller('Teller_Function_Print', ['$scope','$sce', function($scope,$sce){
        
        
        $scope.Print= function(){        
            $scope.stage = '1';  

            var data = {paymentId:$scope.paymentId};
            var request = {ClassName:"Teller_CashDeposit", Method:"PostDeposit",Data:JSON.stringify(data) }; 
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
             if (event.type == 'exception') {
                        //alert(event.message);
                        $scope.stage = '91';
                        $scope.Error = event.message;
                    } else {
                       //$scope.approval= result; 
                       if(result.Success)
                       {
                           $scope.stage = '2';                          
                       }
                       else
                       {
                           $scope.stage = '92';
                       }
                       
                    } // End else
                    $scope.$apply();
                });        
        }
        
        $scope.CreateAccountTransfer= function(){            
            $scope.stage = '';
            Teller_Function_AccTransfer_Controller.CreateAccountTransfer($scope.accountFrom,$scope.accountTo,$scope.functionValue,$scope.customerId,  function (result, event) {
                    if (event.type == 'exception') {
                        $scope.fatalMessage = event.message;
                    } else {                    
                        //options.success(result);
                       
                       if(result.PaymentID)
                       {
                           $scope.stage = '100'; //Print recepit
                           $scope.message = result.Message;
                           $scope.paymentId = result.PaymentID;
                           $scope.pdfUrl = $sce.trustAsResourceUrl('/apex/Teller_Print_Withdraw?paymentId=' + result.PaymentID);
                       }
                       else
                       {
                           $scope.stage = '310';
                           $scope.errorMessage = result.Error;
                       }
                        
                        /*
                        window.parent.testIframe ();
                        window.parent.refreshTillData();
                        */
                        
                                           
                    } // End else
                    $scope.$apply();
                });
            
                  
        }
        
        $scope.$on('printDocs', function(event, args){
    console.log("change detected");
    //alert('print detected');
    
    $scope.Print();
        //any other action can be perfomed here
});
        
        
       $scope.LoadData = function(){
           $scope.loading = true;
           
  
                
           
                
                 
            }
    }]);