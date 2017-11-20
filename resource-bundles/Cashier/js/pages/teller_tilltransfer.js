       


app1.controller('TellerTillTransferController', ['$scope', function($scope,$sce){ 
        $scope.stage =  stage;
        $scope.till = till;
        
                
        
        $scope.headerTemplate = '<div class="row k-state-deta"><div class="col-sm-3">Name</div><div class="col-sm-3">Cash</div><div class="col-sm-3">User</div></div>';
        //$scope.templ = '<div class="row"><div class="col-xs-3">{{dataItem.Name}} - {{dataItem.StorageType}}</div><div class="col-xs-3">{{dataItem.Cash}}</div> <div class="col-xs-3">{{dataItem.UserName}}</div>  </div>';
        $scope.templ = '<div class="row"><div class="col-xs-6">{{dataItem.StorageType}} </div><div class="col-xs-6"> {{dataItem.UserName}}</div></div>';        
        $scope.templ2 = '<span class="selected-value">{{dataItem.StorageType}} - {{dataItem.UserName}}</span>';
        
        $scope.LoadData = function(){
            if($scope.stage)
            {
                switch($scope.stage)
                {
                    case '10':
                        $scope.LoadCreateTransfer ();
                    break;
                
                }
            }        
        }
        
        $scope.$watch("tills", function(newValue, oldValue) {
              if($scope.tills != null)
              {
                $scope.tillData = new kendo.data.ObservableArray( $scope.tills);
                $scope.toStorage= $scope.tillData[0].Id;
                }                
                
                });
        
        $scope.LoadCreateTransfer = function()
        {
            Teller_TillTransferController.GetTillData($scope.till,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                       $scope.tills =  result;
                    } // End else
                    $scope.$apply();
                });
        } 
        
        $scope.ApproveTransfer = function()
        {
            $scope.overrideSuccess = false;
            $scope.overrideError = null;
            Teller_TillTransferController.ApproveTransfer($scope.transferId,$scope.username,$scope.password,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {     
                        if(result)
                        {
                            $scope.overrideSuccess = result.Success;
                            if(!result.Success)
                            {
                                $scope.overrideError = result.Error;
                            } 
                        }
                        else
                        {
                            $scope.overrideError = 'Didnt get a return value';
                        }
                    
                                               
                    } // End else
                    $scope.$apply();
                });
        }
        
        $scope.DeclineTransfer = function()
        {
            Teller_TillTransferController.DeclineTransfer($scope.transferId,$scope.username,$scope.password,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {     
                        $scope.overrideSuccess = result.Success;
                        if(!result.Success)
                        {
                            $scope.overrideError = result.Error;
                        }     
                    } // End else
                    $scope.$apply();
                });
        }
               
        
        $scope.CreateTransfer = function()
        {            
            Teller_TillTransferController.CreateTransfer($scope.transferValue,$scope.till,$scope.toStorage,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {            
                        if(result.TransferId)
                        {
                            $scope.transferId = result.TransferId;
                            $scope.stage = '30';
                            parent.window.RefreshTransfers();
                        }
                        else
                        {
                            $scope.error=result.Error;
                        }
                            
                       
                    } // End else
                    $scope.$apply();
                });
        }
        
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
    }]);