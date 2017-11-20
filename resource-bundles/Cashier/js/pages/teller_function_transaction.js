app1.controller('teller_function_transaction', ['$scope', function($scope){

    // ***** Watches *****

    $scope.$watch('pageData.Denominations.TransactionDenonminations', function(){

        if ($scope.displayDenominations==true){
            $scope.pageData.Denominations.TotalSelectedValue = 0;

            $scope.pageData.Denominations.TransactionDenonminations.forEach(function(item) 
            {
                item.TotalValue = item.NumberSelected * item.DenominationValue;
                $scope.pageData.Denominations.TotalSelectedValue += item.TotalValue;
            }   
        )}; 
    }, true);

    // ***** VF Remoting Calls *****

    $scope.LoadFunctionPageData = function(){
        var functionId = getParameterByName('functionId');
        var accountNo = getParameterByName('accountNo');
        $scope.testing = getParameterByName('testing');
        console.log('$scope.testing: ' + $scope.testing);
        $scope.working = true;

        Teller_Function_Controller.LoadFunctionPageData(functionId, accountNo, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.working = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.pageData=result;
                $scope.working = false;
                $scope.Response_Success = true;
            }

            $scope.$apply(); 
        });

        Teller_Function_Controller.LoadFunctionPageDefinitionData(functionId, accountNo, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.pageDefinition=result;
                $scope.CurrentStageOrder=0; 

                $scope.Response_Success = true;

                // Need to setup page for next/initial stage
                setupPageForNextStage();
            }

            $scope.$apply(); 
        });
    }

    $scope.LoadDenominations = function(){
        console.log('Teller_Function_Controller.LoadDenominations Entry');
        $scope.working = true;

        Teller_Function_Controller.LoadDenominations($scope.pageData.DepositoryId, $scope.pageData.AccountCurrency, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.working = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.pageData.Denominations=result;
                $scope.working = false;
                $scope.Response_Success = true;
            }

            $scope.$apply(); 
        });   
    }

    $scope.LoadSignatories = function(){
        console.log('teller_function_transaction.LoadSignatories Entry');
        $scope.working = true;

        var accountNo = $scope.pageData.CreditAccountNo;
        if($scope.pageData.MandateCheckedAgainst.indexOf('Debit') > -1){
            accountNo = $scope.pageData.DebitAccountNo;
        }

        Teller_Function_Controller.LoadSignatories(accountNo, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.working = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.signatoriesResponse = result;

                if (!$scope.signatoriesResponse.Success){
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = result.ErrorMessage;
                }
                else
                {
                    $scope.Response_Success = true;
                }
            }
            $scope.working = false;
            $scope.$apply();
        });   
    }

    $scope.MandatesCheck = function(){
        console.log('teller_function_transaction.MandatesCheck Entry');

        $scope.working = true;

        Teller_Function_Controller.CheckMandates($scope.pageData, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.working = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.checkMandatesResponse = result;

                if ($scope.checkMandatesResponse.Success)
                {
                    $scope.Response_Success = true;
                    moveToNextStage();
                }
                else
                {
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = result.ErrorMessage;
                }
            }
            $scope.working = false;
            $scope.$apply();
        }); 
     }

    $scope.ProcessStage = function(stageId){
        console.log('teller_function_transaction.ProcessStage Entry');

        var data = $scope.pageData;
        $scope.working = true;

        Teller_Function_Controller.ProcessStage(data, stageId,  function (result, event) {
            if (event.type == 'exception') 
            {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                if (!result.Response_Success)
                {
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = result.Response_StatusDescription;
                }
                else
                {
                    $scope.pageData = result;
                    $scope.Response_Success = true;
                    moveToNextStage();
                }
            }
            $scope.working = false;
            $scope.$apply();
        });   
    }

    $scope.CreateTransactionRecord = function(){
        console.log('teller_function_transaction.CreateTransactionRecord Entry');

        var data = $scope.pageData;
        $scope.working = true;

        Teller_Function_Controller.CreateTransactionRecord(data, function (result, event) {
            if (event.type == 'exception') 
            {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.pageData = result;
                $scope.Response_Success = true;
                moveToNextStage();
            }
            $scope.working = false;
            $scope.$apply();
        }); 
    }

    $scope.DenominationsCheck = function(){
        console.log('teller_function_transaction.DenominationsCheck Entry');

        $scope.working = true;

        Teller_Function_Controller.CheckDenominations($scope.pageData, function (result, event) {
            if (event.type == 'exception')
            {
                $scope.Response_Success = false;
                $scope.working = false;
                $scope.Response_StatusDescription = event.message;
                alert(event.message);
            }
            else
            {
                $scope.checkDenominationsResponse = result;

                if ($scope.checkDenominationsResponse.Success)
                {
                    $scope.Response_Success = true;
                    moveToNextStage();
                }
                else
                {
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = result.ErrorMessage;
                }
            }
            $scope.working = false;
            $scope.$apply();
        }); 
     }

    // ***** Page Validation Functions *****
    $scope.selectedSignatories = [];
    var updateSelected = function (action, id) {
        if (action == 'add' & $scope.selectedSignatories.indexOf(id) == -1) { $scope.selectedSignatories.push(id); }
        if (action == 'remove' && $scope.selectedSignatories.indexOf(id) != -1) { $scope.selectedSignatories.splice($scope.selectedSignatories.indexOf(id), 1); }
    };

    $scope.updateSelection = function ($event, id) {
        var checkbox = $event.target;
        var action = (checkbox.checked ? 'add' : 'remove');
        updateSelected(action, id);
    };

    $scope.getSelectedClass = function (entity) { 
        return $scope.isSelected(entity.id) ? 'selected' : '';
    };

    $scope.isSelected = function (id) {
        return $scope.selectedSignatories.indexOf(id) >= 0;
    };

    $scope.CheckMandates= function(){
        console.log('teller_function_transaction.CheckMandates Entry');

        var accountNo = $scope.pageData.CreditAccountNo;
        if($scope.pageData.MandateCheckedAgainst.indexOf('Debit') > -1){
            accountNo = $scope.pageData.DebitAccountNo;
        }

        $scope.pageData.SelectedSignatoryId = new Array();
        $scope.pageData.SelectedSignatoryId = $scope.selectedSignatories;


        // Perform validation checks
        var validationErrors = false;
        var validationErrorMessage = '';
        if ($scope.pageData.AccountNo == ''){
            validationErrors = true;
            validationErrorMessage = 'Account Number has not been set';
        }
        else if ($scope.pageData.TransactionAmount == ''){
            validationErrors = true;
            validationErrorMessage = 'Transaction Amount has not been set';
        }
        else if ($scope.pageData.SelectedSignatoryId.length < 1)
        {
            validationErrors = true;
            validationErrorMessage = 'No Customer has been selected';
        }

        if (!validationErrors){
            $scope.Response_Success = true;
            $scope.MandatesCheck();
        }
        else
        {
            $scope.Response_Success = false;
            $scope.Response_StatusDescription = validationErrorMessage;
        }
    }

    $scope.CheckDenominations = function(){
        // Perform validation checks
        var validationErrors = false;
        var validationErrorMessage = '';

        $scope.pageData.Denominations.TransactionAmount=$scope.pageData.TransactionAmount;

        if ($scope.pageData.Denominations.TotalSelectedValue != $scope.pageData.Denominations.TransactionAmount)
        {
            validationErrors = true;
            validationErrorMessage = 'Denominations selected do not add up to Transaction Amount';
        }

        if (!validationErrors){
            $scope.Response_Success = true;
            $scope.DenominationsCheck();
        }
        else
        {
            $scope.Response_Success = false;
            $scope.Response_StatusDescription = validationErrorMessage;
        }
    }


    // ***** Page Functions *****

    $scope.previousButtonEventHandler=function()
    {
        // Cancel
        console.log('teller_function_transaction.previousButtonEventHandler Entry');
    }

    $scope.nextButtonEventHandler=function()
    {
        console.log('teller_function_transaction.nextButtonEventHandler Entry');

        // Process Current Stage
        var currentStageObject=getStageObject($scope.CurrentStageOrder);
        switch(currentStageObject.MappingStageName){
            case 'Initial':
                $scope.CreateTransactionRecord();
                break;
            case 'Denominations':
                $scope.CheckDenominations();
                break;
            case 'MandateCheck':
                $scope.CheckMandates();
                break;
            case 'LimitCheck':
                break;
            case 'SendToEBS':
                $scope.ProcessStage(currentStageObject.StageId);
                break;
            case 'Completion':
                break;
        }
    }

    function moveToNextStage()
    {
        if ($scope.Response_Success)
        {
            // If Process Stage successful, perform Pre-Stage Checks for Next Stage
            var nextStageObject=getStageObject($scope.CurrentStageOrder+1);
            switch(nextStageObject.MappingStageName){
                case 'Initial':
                    break;
                case 'Denominations':
                    $scope.LoadDenominations();
                    break;
                case 'MandateCheck':
                    $scope.LoadSignatories();
                    break;
                case 'LimitCheck':
                    break;
                case 'SendToEBS':
                    break;
                case 'Completion':
                    break;
            }

            // If Pre-Stage Checks for Next Stage successful
            if ($scope.Response_Success)
            {
                if(nextStageObject.AlwaysShow==false){
                    // Perform Checks whether stage needs to be shown or not
                }
                setupPageForNextStage();
            }
            else
            {
                // Display Errors

            }
        }
        else
        {
            // Display Errors

        }
    }

    function setupPageForNextStage()
    {
        $scope.CurrentStageOrder+=1;
        var currentStageObject=getStageObject($scope.CurrentStageOrder);
        var previousStageObject=null;

        if($scope.CurrentStageOrder > 1){
            previousStageObject=getStageObject($scope.CurrentStageOrder-1);
        }

        if (currentStageObject==null){
            // Stage not present
            // ??? To Do ???
        }
        else{
            switch(currentStageObject.MappingStageName){
                case 'Initial':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displayInitial=true;
                    break;
                case 'Denominations':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displayDenominations=true;
                    break;
                case 'MandateCheck':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displayMandateCheck=true;
                    break;
                case 'LimitCheck':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displayLimitCheck=true;
                    break;
                case 'SendToEBS':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displaySendToEBS=true;
                    break;
                case 'Completion':
                    disablePreviousStage(previousStageObject);
                    displayCurrentStageFields(currentStageObject);
                    $scope.displayCompletion=true;
                    break;

            }

            // Other Settings

            // Previous Button Title
            $scope.PreviousButtonTitle=currentStageObject.PreviousButtonTitle;
            // Previous Button Routing

            // Next Button Title
            $scope.NextButtonTitle=currentStageObject.NextButtonTitle;
            // Next Button Routing

        }

    }

    function getStageObject(stageOrder)
    {
        var stageObject=null;

        for(i=0; i<$scope.pageDefinition.Stages.length;i++)
        {
            if($scope.pageDefinition.Stages[i].StageOrder==stageOrder){
                stageObject=$scope.pageDefinition.Stages[i];
            }
        }

        return stageObject;
    }

    function disablePreviousStage(previousStageObject)
    {
        if (previousStageObject!=null){
            if(!previousStageObject.KeepOnScreen){
                switch(previousStageObject.MappingStageName){
                    case 'Initial':
                        $scope.displayInitial=false;
                        break;
                    case 'Denominations':
                        $scope.displayDenominations=false;
                        break;
                    case 'MandateCheck':
                        $scope.displayMandateCheck=false;
                        break;
                    case 'LimitCheck':
                        $scope.displayLimitCheck=false;
                        break;
                    case 'SendToEBS':
                        $scope.displayLimitCheck=false;
                        break;
                    case 'Completion':
                        $scope.displayLimitCheck=false;
                        break;
                }
            }
        }
    }

    function displayCurrentStageFields(currentStageObject)
    {
        for(i=0;i<$scope.pageDefinition.Fields.length;i++)
        {
            if($scope.pageDefinition.Fields[i].MappingStageName==currentStageObject.MappingStageName){
               displayField($scope.pageDefinition.Fields[i]);
            }
        }
    } 

    function displayField(field)
    {
        switch(field.MappingField_Name){
            case 'CreditAccountNo':
                $scope.displayCreditAccountNo=field.Visible;
                $scope.labelCreditAccountNo=field.MappingField_Label;
                if(field.Enabled){$scope.disableCreditAccountNo=false;}else{$scope.disableCreditAccountNo=true;}
                break;
            case 'DebitAccountNo':
                $scope.displayDebitAccountNo=field.Visible;
                $scope.labelDebitAccountNo=field.MappingField_Label;
                if(field.Enabled){$scope.disableDebitAccountNo=false;}else{$scope.disableDebitAccountNo=true;}
                break;
            case 'AccountName':
                $scope.displayAccountName=field.Visible;
                $scope.labelAccountName=field.MappingField_Label;
                if(field.Enabled){$scope.disableAccountName=false;}else{$scope.disableAccountName=true;}
                break;
            case 'TransactionAmount':
                $scope.displayTransactionAmount=field.Visible;
                $scope.labelTransactionAmount=field.MappingField_Label;
                if(field.Enabled){$scope.disableTransactionAmount=false;}else{$scope.disableTransactionAmount=true;}
                break;
            case 'ChargeAmount':
                $scope.displayChargeAmount=field.Visible;
                $scope.labelChargeAmount=field.MappingField_Label;
                if(field.Enabled){$scope.disableChargeAmount=false;}else{$scope.disableChargeAmount=true;}
                break;
            case 'PaymentPurpose':
                $scope.displayPaymentPurpose=field.Visible;
                $scope.labelPaymentPurpose=field.MappingField_Label;
                $scope.paymentPurposeValues=field.MappingField_Picklist;
                $scope.pageData.PaymentPurpose=field.MappingField_PicklistDefault;
                if(field.Enabled){$scope.disablePaymentPurpose=false;}else{$scope.disablePaymentPurpose=true;}
                break;
            case 'AmountType':
                $scope.displayAmountType=field.Visible;
                $scope.labelAmountType=field.MappingField_Label;
                $scope.amountTypeValues=field.MappingField_Picklist;
                $scope.pageData.AmountType=field.MappingField_PicklistDefault;
                if(field.Enabled){$scope.disableAmountType=false;}else{$scope.disableAmountType=true;}
                break;
            case 'PaymentDetails':
                $scope.displayPaymentDetails=field.Visible;
                $scope.labelPaymentDetails=field.MappingField_Label;
                if(field.Enabled){$scope.disablePaymentDetails=false;}else{$scope.disablePaymentDetails=true;}
                break;
            case 'BeneficiaryDetails':
                $scope.displayBeneficiaryDetails=field.Visible;
                $scope.labelBeneficiaryDetails=field.MappingField_Label;
                if(field.Enabled){$scope.disableBeneficiaryDetails=false;}else{$scope.disableBeneficiaryDetails=true;}
                break;
            case 'BeneficiaryAccountNo':
                $scope.displayBeneficiaryAccountNo=field.Visible;
                $scope.labelBeneficiaryAccountNo=field.MappingField_Label;
                if(field.Enabled){$scope.disableBeneficiaryAccountNo=false;}else{$scope.disableBeneficiaryAccountNo=true;}
                break;
            case 'BeneficiarySortCode':
                $scope.displayBeneficiarySortCode=field.Visible;
                $scope.labelBeneficiarySortCode=field.MappingField_Label;
                if(field.Enabled){$scope.disableBeneficiarySortCode=false;}else{$scope.disableBeneficiarySortCode=true;}
                break;
            case 'TransferType':
                $scope.displayTransferType=field.Visible;
                $scope.labelTransferType=field.MappingField_Label;
                if(field.Enabled){$scope.disableTransferType=false;}else{$scope.disableTransferType=true;}
                break;
            case 'NoOfCheques':
                $scope.displayNoOfCheques=field.Visible;
                $scope.labelNoOfCheques=field.MappingField_Label;
                if(field.Enabled){$scope.disableNoOfCheques=false;}else{$scope.disableNoOfCheques=true;}
                break;
            case 'ChequeSerialNo':
                $scope.displayChequeSerialNo=field.Visible;
                $scope.labelChequeSerialNo=field.MappingField_Label;
                if(field.Enabled){$scope.disableChequeSerialNo=false;}else{$scope.disableChequeSerialNo=true;}
                break;
            case 'ChequeType':
                $scope.displayChequeType=field.Visible;
                $scope.labelChequeType=field.MappingField_Label;
                if(field.Enabled){$scope.disableChequeType=false;}else{$scope.disableChequeType=true;}
                break;
            case 'IssuingBank':
                $scope.displayIssuingBank=field.Visible;
                $scope.labelIssuingBank=field.MappingField_Label;
                if(field.Enabled){$scope.disableIssuingBank=false;}else{$scope.disableIssuingBank=true;}
                break;
            case 'Reference':
                $scope.displayReference=field.Visible;
                $scope.labelReference=field.MappingField_Label;
                if(field.Enabled){$scope.disableReference=false;}else{$scope.disableReference=true;}
                break;
            case 'NarrativeLines':
                $scope.displayNarrativeLines=field.Visible;
                $scope.labelNarrativeLines=field.MappingField_Label;
                if(field.Enabled){$scope.disableNarrativeLines=false;}else{$scope.disableNarrativeLines=true;}
                break;
            case 'ValueDate': 
                $scope.displayValueDate=field.Visible;
                $scope.labelValueDate=field.MappingField_Label;
                if(field.Enabled){$scope.disableValueDate=false;}else{$scope.disableValueDate=true;}
                break;
        }
    }

    // ***** Utility Routines *****

   function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }
}]); 