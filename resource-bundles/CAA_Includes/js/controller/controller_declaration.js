caaApp.controller('controllerDeclaration', ['$scope','$window','serviceDeclaration','serviceEBS', 'serviceApplication',
        function ($scope,$window,serviceDeclaration,serviceEBS,serviceApplication) 
        {
        
            $scope.CallDe= function(){
		$scope.Data = null;
                if(!$scope.EventLogId) return null;
                
                serviceApplication.LoadShow('Processing...');
                serviceDeclaration.CallDe($scope.EventLogId,$scope.SessionId)
                .then(
                    function(result){
                        if(result.Success)
                        {
							if(result.URL && !result.CallEBS)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {                                
								if(result.CallEBS)
								{
									// C0592 No longer make call to CallEbs
									$scope.CompleteSummaryExternal();
								}
								else
								{
									serviceApplication.LoadHide(false);
								}
							}
                        }
                        else
                        {
							$scope.Error = result.Error;
							$scope.Data = result;
							$scope.Decision = result.Decision;
							serviceApplication.LoadHide(false);
                        }
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }


		$scope.CallEBS= function(){
                if(!$scope.EventLogId) return null;
                
                
                serviceEBS.CallEBSDE($scope.EventLogId,$scope.SessionId)
                .then(
                    function(result){
                        if(result.Success)
                        {
							if(result.Data)
							{
								if(result.Data.Complete)
								{
									$scope.CompleteExternal();
									return;
								}
								else
								{
									$scope.Error = ' ';						
								}

								if(result.Data.NextEventUrl)
								{
									$window.location.href = result.Data.NextEventUrl.FormatURL();
								}
							}

                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }                             
                        }
						else
						{
							$scope.Error = ' ';
						}
                        
						serviceApplication.LoadHide(false);
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }


		$scope.CompleteExternal= function(){
			if(!$scope.EventLogId) return null;
                
                
			serviceEBS.CompleteExternal($scope.EventLogId,$scope.SessionId)
			.then(
				function(result){
					if(result.Success  && result.Data && result.Data.NextEventUrl)
					{
				
					$window.location.href = result.Data.NextEventUrl.FormatURL();
						return;
					}
					else
					{
						$scope.Error = ' ';
					}
                        
					serviceApplication.LoadHide(false);
                },
                function(error){
				 	serviceApplication.LoadHide(false);
                }
		       );
         }

		$scope.CompleteSummaryExternal= function(){
			if(!$scope.EventLogId) return null;
                
			serviceEBS.CompleteSummaryExternal($scope.EventLogId,$scope.SessionId)
			.then(
				function(result){
					if(result.Success  && result.Data && result.Data.NextEventUrl)
					{
						$window.location.href = result.Data.NextEventUrl.FormatURL();
						return;
					}
					else
					{
						$scope.Error = ' ';
					}
                        
					serviceApplication.LoadHide(false);
                },
                function(error){
				 	serviceApplication.LoadHide(false);
                }
		       );
         }













            
            
        }
    ]);