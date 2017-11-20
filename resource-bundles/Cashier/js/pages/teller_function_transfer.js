app1.controller('Teller_Function_Transfer', ['$scope','$sce', function($scope,$sce){
        $scope.stage = '10';
        $scope.action = null;
        $scope.accountFrom = accountId;
        $scope.otherAccount = otherAccountData;
        $scope.customerId = customerId;
        $scope.accountTo=null;
        
        $scope.SelectAction = function(action){
            $scope.action = action;
            
            switch(action)
            {
                case 'Own':
                    $scope.stage = '20';
                    break;
                    
                case 'Other':
                    $scope.stage = '30';
                    break;                    

            }
        }
        
        $scope.ProcessWithdraw= function(){        
            $scope.stage = '';                    
            Visualforce.remoting.Manager.invokeAction(
                    "{!$RemoteAction.Teller_Function_AccTransfer_Controller.PostAccountTransfer}",$scope.paymentId,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {
                       //$scope.approval= result; 
                       if(result.Success)
                       {
                           $scope.stage = '300';
                           window.parent.testIframe ();
                           window.parent.refreshTillData();
                           window.parent.refreshRecentTransData();
                       }
                       else
                       {
                           $scope.stage = '310';
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
        
        
        
        
        $scope.$watch("functionValue", function(newValue, oldValue) {
              if($scope.functionValue!= null)
              {
                $scope.functionValue = $scope.functionValue.replace('T','000');
                $scope.functionValue = $scope.functionValue.replace('t','000');
                
                
                
                
                
                //$scope.$apply();
                }
                
                
                });
        
       
        
        
        
       $scope.LoadData = function(){
           $scope.loading = true;
           
  
                
           
                
                 
            }
    }]);