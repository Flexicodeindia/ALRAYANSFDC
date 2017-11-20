app1.controller('Teller_BranchController', ['$scope','$sce', function($scope,$sce){
        $scope.stage = '10';
        $scope.action = null;
        $scope.accountId = accountId;
        $scope.customerId = customerId;       
        $scope.SelectAction = function(action){
            $scope.action = action;
            
            switch(action)
            {
                case 'Cash':
                    $scope.stage = '20';
                    break;
                    
                case 'Cheque':
                    $scope.stage = '30';
                    break;
                    
                case 'Currency':
                    $scope.stage = '40';
                    break;
            }
            
        
        }
        
        $scope.ValueEntered = function(){            
  
            
            Teller_Function_Deposit_Controller.PostDeposit($scope.accountId,$scope.functionValue,$scope.action,$scope.customerId,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        //options.success(result);
                       
                       $scope.response= result;
                       
                       $scope.errorMessage = result.Error; 
                        
                        window.parent.testIframe ();
                        window.parent.refreshTillData();
                                           
                    } // End else
                    $scope.$apply();
                });
            
                  
        }
        
        
        
        $scope.CreateDeposit= function(){            
            $scope.stage = '';
            Teller_Function_Deposit_Controller.CreateDeposit($scope.accountId,$scope.functionValue,$scope.action,$scope.customerId,  function (result, event) {
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
        
        $scope.ProcessDeposit= function(){        
            $scope.stage = '';                    
            Teller_Function_Deposit_Controller.PostDeposit($scope.paymentId,  function (result, event) {
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