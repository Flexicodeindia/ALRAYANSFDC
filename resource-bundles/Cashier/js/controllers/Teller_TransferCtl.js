app1.controller('Teller_TransferCtl', ['$scope', function($scope){    
    $scope.loading = null;
    
    // function to submit the form after all validation has occurred            
    $scope.submitForm = function(isValid) {

        // check to make sure the form is completely valid
        if (isValid) {
            alert('our form is amazing');
        }

    };
    
    $scope.LoadData = function(){
       $scope.loading = true;     
       
       Teller_TransferController.GetBranchData(null,  function (result, event) {
            if (event.type == 'exception') {
                alert(event.message);
            } else {   
               $scope.data=  result;                       
                } // End else
                $scope.loading=null;
                $scope.$apply();
            });
   }    
}])