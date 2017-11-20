mandateApp.service('serviceMandates', ['$q', '$rootScope', function ($q, $rootScope) {

    this.LoadMandatesAndSignatories = function(accountNo){
        var deferred = $q.defer();
        BAA_Mandates.LoadMandatesAndSignatories(accountNo, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.DeleteMandate = function (mandateId) {
        var deferred = $q.defer();
        BAA_Mandates.DeleteMandate(mandateId, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    //AccountHolder-----------------------------------
    this.LoadSignatoriesAndGroups = function(request) {
        var deferred = $q.defer();
        BAA_Mandates.LoadSignatoriesAndGroups(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.SaveSignatories = function(request) {
        var deferred = $q.defer();
        BAA_Mandates.SaveSignatories(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    //Mandate-----------------------------------------

    this.LoadMandateItems = function(request) {
        var deferred = $q.defer();
        BAA_Mandates.LoadMandateItems(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.SaveMandateItems = function(request) {
        var deferred = $q.defer();
        BAA_Mandates.SaveMandateItems(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.CheckMandates = function(request)
    {
         var deferred = $q.defer();
        BAA_Mandates.CheckMandates(request, function (result, event) {

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