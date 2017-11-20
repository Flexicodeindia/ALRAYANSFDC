mandateApp.controller('controllerMandates', ['$scope', '$timeout', 'serviceMandates', function ($scope, $timeout, serviceMandates) {
	
	//Views: 'View', 'Edit', 'AccountEdit'
	$scope.CurrentView = "View";
	$scope.accountNumber = null;
    $scope.SelectedMandateId = null;
    
    //Listeners ---------------------------------------------------------------------------------------
    
    $scope.$watch("CurrentView",
        function watchCurrentView(newValue, oldValue)
        {
            switch (newValue) {
                case 'AccountEdit':
                {
                    $scope.LoadSignatoriesAndGroups();
                    break;
                }
                
                case 'Edit':
                {                    
                    $scope.LoadMandateItems();
                    break;
                }
                
                case 'NewMandate':
                {
                    $scope.SelectedMandateId = undefined;
                    $scope.CurrentView = "Edit";
                    break;
                }
                
                case 'View':
                {
                    $scope.LoadMandatesAndSignatories();
                    break;
                }
            }
        } 
     );
    
    //-------------------------------------------------------------------------------------------------

	$scope.GetAccountNumber = function()
	{
		var accElement = angular.element(document.getElementById("BAA_AccountNumber"));
		$scope.accountNumber = accElement[0].innerText;
	}

	$scope.LoadMandatesAndSignatories = function () {
		$scope.GetAccountNumber();
        $scope.LoadMandatesAndSignatoriesInternal();
    }

	$scope.LoadMandatesAndSignatoriesInternal = function () {
        $scope.ShowDocumentLoad('Please wait', 'Loading Mandates');  
        
        $timeout(function() {
                serviceMandates.LoadMandatesAndSignatories($scope.accountNumber)
                .then(
                    function (result) {		
                        $scope.response = result;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        $scope.HideDocumentLoad(); 
                    },
                    function (error) {
                        alert(event.message);
                        $scope.HideDocumentLoad(); 
                    }
            );
        }, 1000);
    }
    
    $scope.GotoMandateEdit = function(mandateId)
    {
        $scope.SelectedMandateId = mandateId;
        $scope.CurrentView = 'Edit';
    }
	
	$scope.LoadMandateItems = function()
    {
        $scope.ShowDocumentLoad('Please wait', 'Loading Mandate Item');       
        $scope.mandateRuleForm = {};        
        $scope.mandateRuleForm.ruleType = "signatoryGroup";
        $scope.mandateRuleForm.signatory = "";
        $scope.mandateRuleForm.signatoryGroup = "";
        $scope.mandateRuleForm.relationshiptype = "";
        $scope.mandateRuleForm.nofromgroup = "";
        $scope.responseMandate = null;

        var request = {MandateId: $scope.SelectedMandateId, AccountWithIBBId: $scope.response.AccountWithIBBId}; 
        
        serviceMandates.LoadMandateItems(request)
            .then(
                    function (result) {
                        $scope.responseMandate = result;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }       
                         $scope.HideDocumentLoad();                   
                    },
                    function (error) {
                         $scope.HideDocumentLoad(); 
                         alert(error.message);
                    }
                ); 
    }
    
    
    $scope.DeleteMandate = function(mandateId)
    {
        $scope.ShowDocumentLoad('Please wait', 'Updates Mandates'); 
        serviceMandates.DeleteMandate(mandateId) 
            .then(
                    function (result) {
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        if(result.Success){
                            $scope.LoadMandatesAndSignatoriesInternal();                            
                        }
                    },
                    function (error) {
                        alert(event.message);
                    }
                ); 
    }
    
    $scope.SaveMandateRule = function(closeAfterSave)
    {
        var request = {
            MandateId : $scope.responseMandate.MandateId,
            AccountWithIBBId : $scope.response.AccountWithIBBId,
            MandateLimit : $scope.responseMandate.MandateLimit,
            MandateItems : new Array()
        };

        var mandateError = false;
        var mandateErrorMessage = '';

        if ((request.MandateLimit == null) || (request.MandateLimit == '')){
            mandateError=true;
            mandateErrorMessage='Mandate Limit not set';
        }
        if ($scope.responseMandate.MandateItems.length < 1){
            mandateError=true;
            mandateErrorMessage='No mandate items have been selected';
        }

        if (!mandateError){
            for( var i = 0; i < $scope.responseMandate.MandateItems.length; i++ ) {

                var mandateItem = {
                    Signatory : $scope.responseMandate.MandateItems[i].Signatory,
                    SignatoryGroup : $scope.responseMandate.MandateItems[i].SignatoryGroup,
                    RelationshipType : $scope.responseMandate.MandateItems[i].RelationshipType,
                    NoFromGroup : $scope.responseMandate.MandateItems[i].NoFromGroup
                };
                
               request.MandateItems[request.MandateItems.length] = mandateItem;
            }

            $scope.ShowDocumentLoad('Please wait', 'Saving Mandate Item'); 
            serviceMandates.SaveMandateItems(request)
                .then(
                        function (result) {                        
                            if (!$scope.$$phase) {
                                $scope.$apply();
                            }

                            if (result.Success){
                                $scope.HideDocumentLoad();
                                $scope.CurrentView = 'View';
                            }
                            else{
                                $scope.HideDocumentLoad();
                                alert(result.ErrorMessage);
                            }
                        },
                        function (error) {
                            $scope.HideDocumentLoad();
                            alert(error.message);
                        }
                    ); 
        }
        else {
            alert(mandateErrorMessage);
        }

    }
    
    $scope.LoadSignatoriesAndGroups = function() {
        $scope.ShowDocumentLoad('Please wait', 'Loading Signatories and Groups'); 
        serviceMandates.LoadSignatoriesAndGroups($scope.accountNumber)
            .then(
                    function (result) {
                        $scope.response = result;
                        if ($scope.response.Success) {
                            $scope.HideDocumentLoad();
                        }
                        else{
                            $scope.HideDocumentLoad();
                            alert(result.ErrorMessage);
                        }

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function (error) {
                        $scope.HideDocumentLoad();
                        alert(error.message);
                    }
                );
    }
    
    $scope.SaveSignatories = function() {
        $scope.ShowDocumentLoad('Please wait', 'Updating Signatories'); 
        serviceMandates.SaveSignatories($scope.response.SignatoryList)
            .then(
                    function (result) {
                        $scope.response = result;
                        if ($scope.response.Success) {
                            $scope.CurrentView = 'View';
                        }
                        else {
                            $scope.HideDocumentLoad();
                            alert('Error saving Signatories');
                        }
    
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function (error) {
                        $scope.HideDocumentLoad();
                        alert(event.message);
                    }
                );
    }   
    
    $scope.AddMandateRule = function()
    {
        if( $scope.mandateRuleForm.ruleType == 'signatory')
        {
            if (($scope.mandateRuleForm.signatory.Value == null) || ($scope.mandateRuleForm.signatory.Value == '')){
                alert('No signatory selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'SignatoryId' : $scope.mandateRuleForm.signatory.Value,
                    'Signatory' : $scope.mandateRuleForm.signatory.Label
                });
            }
        }
        else if ( $scope.mandateRuleForm.ruleType == 'signatoryGroup')
        {
            if (($scope.mandateRuleForm.signatoryGroup.Value == null) || ($scope.mandateRuleForm.signatoryGroup.Value == '')){
                alert('No signatory group selected');
            }
            else if (($scope.mandateRuleForm.nofromgroup == null) || ($scope.mandateRuleForm.nofromgroup == '')){
                alert('No numbers from group selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'SignatoryGroup' :  $scope.mandateRuleForm.signatoryGroup.Value,
                    'NoFromGroup' : $scope.mandateRuleForm.nofromgroup
                });
            }
        }
        else if ( $scope.mandateRuleForm.ruleType == 'relationship')
        {
            if (($scope.mandateRuleForm.relationshiptype.Value == null) || ($scope.mandateRuleForm.relationshiptype.Value == '')){
                alert('No relationship type selected');
            }
            else if (($scope.mandateRuleForm.nofromgroup == null) || ($scope.mandateRuleForm.nofromgroup == '')){
                alert('No numbers from group selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'RelationshipType' :  $scope.mandateRuleForm.relationshiptype.Value,
                    'NoFromGroup' : $scope.mandateRuleForm.nofromgroup
                });
            }
        }
    } 
    
    $scope.RemoveMandateRule = function(index)
    {
        if (index === -1) {
            alert("Failed to remove Mandate");
        }
        else {
            $scope.responseMandate.MandateItems.splice(index, 1);
        }
    }
   
    $scope.ShowDocumentLoad = function(title, body)
    {
       angular.element(document.getElementById('popupTitle')).html(title);
       angular.element(document.getElementById('popupBody')).html(body);
       angular.element(document.getElementById('overlay')).show('slow');
       angular.element(document.getElementById('fade')).show('slow');
    }
    
    $scope.HideDocumentLoad = function()
    {
       angular.element(document.getElementById('overlay')).hide('slow');
       angular.element(document.getElementById('fade')).hide('slow');
    }
    
}]);