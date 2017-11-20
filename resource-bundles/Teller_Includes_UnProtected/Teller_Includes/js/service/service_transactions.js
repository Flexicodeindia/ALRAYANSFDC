tellerApp.service('serviceTransactions', ['$q', '$rootScope', function ($q, $rootScope) {

	this.LoadFunctionPageDefinitionData = function(functionId, accountNo)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.LoadFunctionPageDefinitionData(functionId, accountNo, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}


	this.LoadFunctionPageData = function(functionId, accountNo, account)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.LoadFunctionPageData(functionId, accountNo, account, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}
    
    this.LoadFunctionPageDataByTransactionId = function(transactionId)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.LoadFunctionPageDataByTransactionId(transactionId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

	this.LoadDenominations = function(depositoryId, accountCurrency) 
	{
		var deferred = $q.defer();
        Teller_Core_Controller.LoadDenominations(depositoryId, accountCurrency, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

	this.ProcessStage = function(functionPageData, stageId)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.ProcessStage(functionPageData, stageId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

	this.CreateTransactionRecord = function(functionPageData)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.CreateTransactionRecord(functionPageData, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	} 

    this.CheckDenominations = function(functionPageData)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.CheckDenominations(functionPageData, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.LoadLimits = function(functionPageData)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.LoadLimits(functionPageData, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.PasswordVerification = function(userName, password)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.PasswordVerification(userName, password, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.SubmitForApproval = function(functionPageData, limitData)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.SubmitForApproval(functionPageData, limitData, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.LimitCheck = function(functionPageData, limits)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.LimitCheck(functionPageData, limits, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.CancelTellerTransaction = function(transactionId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.CancelTellerTransaction(transactionId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
    
    this.GetFunctionPrintTemplate = function(functionId, printTemplateType)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetFunctionPrintTemplate(functionId, printTemplateType, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.UpdateTellerTransactionPrintedReciept = function(transactionId, printedReciept)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.UpdateTellerTransactionPrintedReciept(transactionId, printedReciept, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetPreApprovedCases = function(pageData, authorisorNo, authorisorId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetPreApprovedCases(pageData, authorisorNo, authorisorId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
}]);
