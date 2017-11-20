app1.controller('Teller_FindCustomerController', ['$scope', function($scope){ 
         
        $scope.SFind = '';
        
        
       $scope.FindCustomer= function(){
           
           if($scope.SFind)
           {
           
           Teller_FindCustomer_Controller.FindCustomer($scope.SFind,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                       if($scope.SFind)
                       {
                           $scope.response = result;
                       }
                       else
                       {
                           $scope.response = null;
                       }                   
                    } // End else                   
                    $scope.$apply();                    
                });
                
                }
                else
                {
                    $scope.response = null;
                }                 
            }
    }]);