caaApp.service('serviceProductSelect', ['$q', '$rootScope', function ($q, $rootScope) {
        this.GetProductSuitability = function()
        {
            var deferred = $q.defer();
            CAA_Core_Controller.GetProductSuitability(function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }
        
        this.SendProductSelected= function(data,sessionId, hasEmail, hasMail, hasPhone, hasSMS)
        {
            var deferred = $q.defer();
			//added 4 new parameters for data protection SBC
		    CAA_Core_Controller.ProductSelected(data, sessionId, hasEmail, hasMail, hasPhone, hasSMS, function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }
    
    }]);