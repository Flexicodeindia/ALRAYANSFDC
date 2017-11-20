app1.controller('Teller_BranchController', ['$scope','$sce', function($scope,$sce){
        $scope.stage = '20';
        $scope.action = null;
        $scope.accountId = accountId;
        $scope.customerId = customerId; 
        $scope.pageData = functiondata;   
        $scope.Currency = $scope.pageData.CurrentCurrency;

        
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


        $scope.ValueEntered = function(){   
          $scope.PendingRequest = true;
            var request = {ClassName:"Teller_ChequeDeposit", Method:"PostDeposit",Data:{paymentId:$scope.paymentId} } 
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        //options.success(result);
                       
                       $scope.response= result;
                       
                       $scope.errorMessage = result.Error; 
                        
                        window.parent.testIframe ();
                        window.parent.refreshTillData();
                                           
                    } // End else
                    $scope.PendingRequest = false;
                    $scope.$apply();
                    
                });
        }


        
        
        $scope.CreateDeposit= function(){   
            $scope.PendingRequest = true;         
            $scope.stage = '31';

            var data = {AccountId:$scope.accountId, Value:$scope.ChequeDepositValue,Reference:$scope.Reference,CustomerId: $scope.customerId
                        ,Narrative1:$scope.Narrative1,Narrative2:$scope.Narrative2,Narrative3:$scope.Narrative3,Narrative4:$scope.Narrative4,    
                         SourceOfFundsType:$scope.SourceOfFundsType, SourceOfFundsDetails:$scope.SourceOfFundsType};
            var request = {ClassName:"Teller_ChequeDeposit", Method:"CreateDeposit",Data: JSON.stringify(data)}  ;    

            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        $scope.fatalMessage = event.message;
                        $scope.PendingRequest = false;
                        $scope.stage = '321';
                    } else {                    
                        //options.success(result);
                       
                       if(result.PaymentID)
                       {
                           //sending to ebs
                           $scope.paymentId = result.PaymentID;
                          $scope.ProcessDeposit();

                           //$scope.stage = '100'; //Print recepit
                           //$scope.message = result.Message;
                           //$scope.paymentId = result.PaymentID;
                           //$scope.pdfUrl = $sce.trustAsResourceUrl('/apex/Teller_Print_Withdraw?paymentId=' + result.PaymentID);
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
            
                  
        }
        
        $scope.ProcessDeposit= function(){    
            $scope.PendingRequest = true;    
            $scope.stage = '32';        



            var data = {paymentId:$scope.paymentId};
            var request = {ClassName:"Teller_ChequeDeposit", Method:"PostDeposit",Data:JSON.stringify(data) }; 
            Teller_Function_Controller.GenericRemoting(request,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                        $scope.PendingRequest = false;
                    } else {
                       //$scope.approval= result; 
                       if(result.Success)
                       {
                           $scope.stage = '300';
                           
                           try {
                                window.parent.testIframe ();
                                window.parent.refreshTillData();
                                window.parent.refreshRecentTransData();
                                //window.parent.centerDialog();
                            }
                            catch(err) {
                                // Handle error(s) here
                            }                     
                       }
                       else
                       {
                           $scope.stage = '310';
                       }
                       $scope.PendingRequest = false;
                    } // End else

                    $scope.$apply();
                });
              }
        
        
        $scope.$watch('stage', function(newVal, oldVal){
    if(newVal!=oldVal && $scope.stage=='300')
        $scope.$broadcast('printDocs',{"val":$scope.paymentId})
});
        
        $scope.$watch("ChequeDepositValue", function(newValue, oldValue) {
              if($scope.ChequeDepositValue!= null)
              {
                $scope.DepositNumberValue = parseFloat($scope.ChequeDepositValue).toFixed(2);

                if($scope.ChequeDepositValue.indexOf("T") > -1 || $scope.ChequeDepositValue.indexOf("t") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 1000).toFixed(2);
                  $scope.ChequeDepositValue = $scope.DepositNumberValue;
                }

                if($scope.ChequeDepositValue.indexOf("H") > -1 || $scope.ChequeDepositValue.indexOf("h") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 100).toFixed(2);
                  $scope.ChequeDepositValue = $scope.DepositNumberValue;
                }

                if($scope.ChequeDepositValue.indexOf("M") > -1 || $scope.ChequeDepositValue.indexOf("m") > -1)
                {
                  $scope.DepositNumberValue = ($scope.DepositNumberValue * 1000000).toFixed(2);
                  $scope.ChequeDepositValue = $scope.DepositNumberValue;
                }


                if($scope.ChequeDepositValue == '')
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
                      $scope.AmountValidation = null;
                      //$scope.DepositNumberValue = '£' + $scope.DepositNumberValue;
                      //$scope.ChequeDeposit = $scope.DepositNumberValue;
                    }
                }



                //$scope.ChequeDeposit = $scope.ChequeDeposit.replace('T','000');
                //$scope.ChequeDeposit = $scope.ChequeDeposit.replace('t','000');               
                
                //$scope.DepositNumberValue = parseFloat($scope.ChequeDeposit).toFixed(2);
                
                //$scope.$apply();
                }
                
                
                });
        
       
        
        
        
       $scope.LoadData = function(){
           $scope.loading = true;
           
  
                
           
                
                 
            }
    }]);