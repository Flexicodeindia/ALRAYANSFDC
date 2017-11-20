$(document).ready(function(){
    $("div#contDiv").fadeIn();
});

app1.controller('Teller_Mandates', ['$scope', function($scope){

    function closeDialog()
    {
        console.log('teller_mandates.closeDialog Entry'); 

        var f = $("#dialog").data("kendoWindow");
        if(f)
        {
          f.close();
        }
    };

 
  $scope.SFind = '';

  $scope.LoadMandatesAndSignatories= function(){  
     Teller_Mandates_Controller.LoadMandatesAndSignatories($scope.SFind, function (result, event) {
        if (event.type == 'exception') {
            alert(event.message);
        } else {
            $scope.response= result;

            if ($scope.response.Success){
                if ($scope.response.signatories.length > 1){
                    document.getElementById("NewMandateButton").style.visibility="visible";
                }
                else{
                    document.getElementById("NewMandateButton").style.visibility="hidden";
                }
                $scope.stage = '20';
            }
            else{
                $scope.stage = '99';
                
                //error message here
                $scope.FindAccountError = result.ErrorMessage;
            }
        } // End else
        $scope.$apply();
    });        
  }

  $scope.DeleteMandate= function(MandateId){  
    Teller_Mandates_Controller.DeleteMandate(MandateId, function (result, event) {
        if (event.type == 'exception') {
            alert(event.message);
        } else {
            if (result.Success){
                // Remove Mandate from $scope
                removeRow(MandateId);
            }
            else{
                //$scope.stage = '';
                
                //error message here
                $scope.FindAccountError = result.ErrorMessage;
            }
        } // End else
        $scope.$apply();
    });        
  }

    function removeRow(name){              
        var index = -1;     
        var comArr = eval( $scope.response.mandates );
        for( var i = 0; i < comArr.length; i++ ) {
            if( comArr[i].MandateId === name ) {
                index = i;
                break;
            }
        }
        if( index === -1 ) {
            alert( "Something gone wrong" );
        }
        $scope.response.mandates.splice( index, 1 );        
    }
/*
    $scope.init= function(){  
        var accountId = getParameterByName(accountId);
        console.log('accountId: ' + accountId);
        if (accountId != null)
        {
            $scope.SFind = accountId;
            $scope.stage = '20';
        }
    }
*/


   
   function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

/*
    function cancelFunction(accountWithIBBId)
    {
        console.log('teller_mandates.cancelfunction Entry');

        if(accountWithIBBId)
        {              
            Teller_Mandates_Controller.LoadMandatesAndSignatories(accountWithIBBId,  function (result, event) {
            if (event.type == 'exception') {
                alert(event.message);
            } else {
                $scope.response= result;
            } // End else
            $scope.$apply();
            });  
            }

        closeDialog();
    }
*/

}]);

