app1.controller('Teller_CashWithdraw', ['$scope','$sce', function($scope,$sce){
        $scope.stage = '20';
        /*
        $scope.action = null;
        $scope.accountId = accountId;
        $scope.customerId = customerId;
        $scope.pageData = functiondata;   
        $scope.Currency = $scope.pageData.CurrentCurrency;
*/
        $scope.LoadData = function()
        {
             if (accountId != '')
            {
              $scope.FindAccountById(accountId);   
            }
          
        }
        
        $scope.ProcessWithdraw= function(){        
            $scope.stage = '32';       
            $scope.PendingRequest = true;
            var data = {paymentId:$scope.paymentId};
            var request = {ClassName:"Teller_CashWithdraw", Method:"PostWithdrawal",Data:JSON.stringify(data) };  

            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                        $scope.PendingRequest = false;
                    } else {
                       //$scope.approval= result; 
                       if(result.Success)
                       {
                           $scope.stage = '302';
                           //window.parent.testIframe ();
                           //window.parent.refreshTillData();
                           //window.parent.refreshRecentTransData();
                           $scope.PendingRequest = false;
                       }
                       else
                       {
                           $scope.stage = '310';
                           $scope.PendingRequest = false;
                       }
                       
                    } // End else
                    $scope.$apply();
                });        
             $scope.$apply();
        }

        $scope.Cancel = function()
        {
            window.parent.cancelFunction($scope.paymentId);
        }

        $scope.Close = function()
        {
            if($scope.paymentId)
            {
                window.parent.closeDialog($scope.paymentId);
            }     
        }
        
        $scope.FindAccount = function()
              {
                 var accountNo = $scope.AccBranch + $scope.AccCustomer + $scope.AccNum;
                 $scope.FindAccountById(accountNo);
              }

              $scope.FindAccountById= function(accountId){  

            $scope.PendingRequest = true;    
                          $scope.accountId = null;
                          $scope.customerId = null; 
                          $scope.pageData = null;  
                          $scope.Currency = null;     
                          $scope.FindAccountError = null;


            var data = accountId;
            //var request = {ClassName:"Teller_CashDeposit", Method:"PostDeposit",Data:JSON.stringify(data) }; 
            Teller_Function_Controller.GetAccountData(data,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                        $scope.PendingRequest = false;
                    } else {
                       //$scope.approval= result; 
                       if(result.Success)
                       {
                          $scope.accountId = result.AccountNo;
                          $scope.customerId = result.CustomerNo; 
                          $scope.pageData = result;   
                          $scope.Currency = $scope.pageData.CurrentCurrency;
                       }
                       else
                       {
                           //error message here
                           $scope.FindAccountError = result.Error;
                       }
                       $scope.PendingRequest = false;
                    } // End else

                    $scope.$apply();
                });
              }
        
        $scope.CreateWithdrawApproval= function(){
        $scope.PendingRequest = true;        
            $scope.stage = '';          

            var request = {ClassName:"Teller_CashWithdraw", Method:"PostWithdraw",Data:{AccountId:$scope.accountId, Value:$scope.CashWithdrawalValue,action:$scope.action} }      
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                        $scope.PendingRequest = false;
                    } else {
                       $scope.PendingRequest = false;
                       $scope.approval= result;                                              
                       $scope.stage = '55';
                    } // End else
                    $scope.$apply();
                });        
        }

        $scope.Approve = function(){
            $scope.stage = '';    
            $scope.PendingRequest = true;           

             var data = {
                paymentId:$scope.paymentId,
                password: $scope.CreateResult.Auth.UserPass,
                user: $scope.CreateResult.Auth.User

             } 

            var request = {ClassName:"Teller_CashWithdraw", Method:"ApprovePostWithdraw",Data:JSON.stringify(data) }      
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                        $scope.PendingRequest = false;
                    } else {
                        $scope.PendingRequest = false;
                       $scope.approval= result;                                              
                       //$scope.stage = '55';
                       $scope.ProcessWithdraw();
                    } // End else
                    $scope.$apply();
                }); 
             $scope.$apply();
        }
        
        $scope.CreateWithdraw= function(){ 
        $scope.PendingRequest = true;           
            $scope.stage = '31';

            var data = {AccountId:$scope.accountId, Value:$scope.DepositNumberValue,CustomerId:$scope.customerId};

            var request = {ClassName:"Teller_CashWithdraw", Method:"CreateWithdrawal",Data: JSON.stringify(data) }
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        $scope.fatalMessage = event.message;
                        $scope.PendingRequest = false;
                    } else {                    
                        //options.success(result);
                       
                       if(result.PaymentID)
                       {
                           $scope.CreateResult = result; 
                           $scope.message = result.Message;
                           $scope.paymentId = result.PaymentID;

                           if($scope.CreateResult.Auth)
                           {
                                $scope.stage = '90';
                                $scope.PendingRequest = false;
                           }
                           else
                           {
                                //$scope.stage = '100';
                                $scope.paymentId = result.PaymentID;
                                //$scope.ProcessWithdraw();
                                $scope.stage = '301';
                                $scope.PendingRequest = false;
                              //$scope.pdfUrl = $sce.trustAsResourceUrl('/apex/Teller_Print_Withdraw?paymentId=' + result.PaymentID);
                           }
                       }
                       else
                       {
                           $scope.stage = '310';
                           $scope.errorMessage = result.Error;
                           $scope.PendingRequest = false;
                       }
                        
                        /*
                        window.parent.testIframe ();
                        window.parent.refreshTillData();
                        */
                        
                                           
                    } // End else
                    $scope.$apply();
                });
 $scope.$apply();
        }
        
          $scope.$watch('stage', function(newVal, oldVal){
    if(newVal!=oldVal && $scope.stage=='300')
        $scope.$broadcast('printDocs',{"val":$scope.paymentId})
});
        
        $scope.$watch("CashWithdrawalValue", function(newValue, oldValue) {
              if($scope.CashWithdrawalValue!= null)
              {
                $scope.DepositNumberValue = parseFloat($scope.CashWithdrawalValue).toFixed(2);

                if($scope.CashWithdrawalValue.indexOf("T") > -1 || $scope.CashWithdrawalValue.indexOf("t") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 1000).toFixed(2);
                  $scope.CashWithdrawalValue = $scope.DepositNumberValue;
                }

                if($scope.CashWithdrawalValue.indexOf("H") > -1 || $scope.CashWithdrawalValue.indexOf("h") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 100).toFixed(2);
                  $scope.CashWithdrawalValue = $scope.DepositNumberValue;
                }

                if($scope.CashWithdrawalValue.indexOf("M") > -1 || $scope.CashWithdrawalValue.indexOf("m") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 1000000).toFixed(2);
                  $scope.CashWithdrawalValue = $scope.DepositNumberValue;
                }


                if($scope.CashWithdrawalValue == '')
                {
                    $scope.AmountValidation = 'Required';
                }
                else
                {
                    if(isNaN($scope.DepositNumberValue))
                    {                  
                          $scope.AmountValidation = 'Invalid Value';
                    }
                    else
                    {
                      //$scope.CashWithdrawalValue = $scope.DepositNumberValue;
                      $scope.AmountValidation = null;
                      //$scope.DepositNumberValue = '£' + $scope.DepositNumberValue;

                      $scope.DisplayAmount =  $scope.DepositNumberValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

                      
                    }
                }



                //$scope.CashWithdrawalValue = $scope.CashWithdrawalValue.replace('T','000');
                //$scope.CashWithdrawalValue = $scope.CashWithdrawalValue.replace('t','000');               
                
                //$scope.DepositNumberValue = parseFloat($scope.CashWithdrawalValue).toFixed(2);
                
                //$scope.$apply();
                }
                
                
                });

    }]);