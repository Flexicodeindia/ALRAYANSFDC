function RefreshTransfers()
        {
            var scope = angular.element(
                            document.getElementById("TillController")).
                            scope();
                            scope.$apply(function () {
                                scope.TransfersToday();
                            });
        }  
    
  
  $(function(){
      $("#transferBtn").click(function(){
          $("#transferModal").modal();
      });
  });


app1.controller('Teller_Transfers', ['$scope', function($scope){
    $scope.till = till.substring(0,15);  
    $scope.tillLong = till; 

              $scope.LoadData = function(){
                $scope.TransfersToday();
              }


              $scope.CancelTransfer = function(transferId){
                  var data = {TillId:$scope.tillLong,TransferId:transferId};

                          var request = {ClassName:"Teller_Till_Helper", Method:"CancellTransferRefresh",Data:JSON.stringify(data) }; 
                          Teller_Header_Controller.GenericRemoting(request,  function (result, event) {
                              if (event.type == 'exception') {
                                  alert(event.message);
                              } else {                    
                                  $scope.transfers=  result;
                          }            
                          $scope.$apply();            
                          });     

              }

               $scope.CreateTransfer = function()
        {
            var url = '/apex/Teller_TillTransfer?till=' + $scope.till + '&create=10';
        
            $scope.URLPopup(url);
        }
        
        
        
        
        $scope.URLPopup= function(url)
        {
            var f = $("#dialog").data("kendoWindow");
            if (f === undefined) {
                 var d =$("#dialog").kendoWindow({
            content: url,
            iframe: true,
            width: "700px",
            height: "500px",
            

            modal:true
        });
            
            }
            else
            {
                f.content('Loading...');
                f.refresh({
                    url: url
                });
                
                f.open();
            }
  
          var d = $("#dialog").data("kendoWindow");
          d.center();
       }


              $scope.TransfersToday = function(){
                    var data = $scope.tillLong;
                          var request = {ClassName:"Teller_Till_Helper", Method:"GetTillTransfersToday",Data:JSON.stringify(data) }; 
                          Teller_Header_Controller.GenericRemoting(request,  function (result, event) {
                              if (event.type == 'exception') {
                                  alert(event.message);
                              } else {                    
                                  $scope.transfers=  result;
                          }            
                          $scope.$apply();            
                          });       
                     }
}]);


app1.controller('Teller_Transactions', ['$scope', function($scope){
    $scope.till = till.substring(0,15);  
    $scope.tillLong = till; 

    
    

              $scope.LoadData = function(){
                $scope.TransactionsToday();
              }


              $scope.CancelTransaction = function(transferId){
                  var data = {TillId:$scope.tillLong,TransferId:transferId};

                          var request = {ClassName:"Teller_Till_Helper", Method:"CancellTransactionRefresh",Data:JSON.stringify(data) }; 
                          Teller_Header_Controller.GenericRemoting(request,  function (result, event) {
                              if (event.type == 'exception') {
                                  alert(event.message);
                              } else {                    
                                  $scope.transfers=  result;
                          }            
                          $scope.$apply();            
                          });     

              }


              $scope.TransactionsToday = function(){
                    var data = $scope.tillLong;
                          var request = {ClassName:"Teller_Transaction_Helper", Method:"GetTransactionsByTill",Data:JSON.stringify(data) }; 
                          Teller_Header_Controller.GenericRemoting(request,  function (result, event) {
                              if (event.type == 'exception') {
                                  alert(event.message);
                              } else {      

                                $scope.DSCreated = result.Created;
                                $scope.DSCancelled = result.Cancelled;                                  
                          }            
                          $scope.$apply();            
                          });       
                     }



            $scope.DSCreated = new kendo.data.DataSource({
    pageSize: 20,
    serverPaging: true,
    serverSorting: true,

    schema: {
        total: "total",
        data: "Items",
        model: {
            fields: {
                Description: {
                    type: "string"
                },
                Value: {
                    type: "number"
                },
                CreatedTime: {
                    type: "string"
                },
                Status: {
                    type: "string"
                }
            }

        }

    },
    transport: {
        read: function(options) {

            options.data.sortField = options.data.sort;

            var data = {
                KendoOptions: JSON.stringify(options.data),
                tillId: $scope.tillLong,
                ShowCreated: true
            };



            var request = {
                ClassName: "Teller_Transaction_Helper",
                Method: "GetTransactionsByStageKendo",
                Data: JSON.stringify(data)
            };
            Teller_Header_Controller.GenericRemoting(request, function(result, event) {

                if (event.type == 'exception') {
                    alert(event.message);
                } else {
                    options.success(result);
                    transactionsCreated = result.total;
                    //options.data = result;
                    var ff = 2;
                } // End else

            });
        }
    }
});

$scope.CreatedGridOptions = {
dataSource: $scope.DSCreated,
detailTemplate: kendo.template($("#detailtemplate").html()),
pageable: {
refresh: true,
pageSizes: true,
buttonCount: 5
},
sortable: false,

columns: [{
    field: "Description",
    title: "Description"


}, {
    field: "Status",
    title: "Status"


}, {
    field: "Value",
    title: "Value",
    format: "{0:c2}"
}, {
    field: "CreatedTime",
    title: "CreatedTime"


}


]
};



            $scope.DSError = new kendo.data.DataSource({
    pageSize: 20,
    serverPaging: true,
    serverSorting: true,

    schema: {
        total: "total",
        data: "Items",
        model: {
            fields: {
                Description: {
                    type: "string"
                },
                Value: {
                    type: "number"
                },
                CreatedTime: {
                    type: "string"
                },
                Status: {
                    type: "string"
                }
            }

        }

    },
    transport: {
        read: function(options) {

            options.data.sortField = options.data.sort;

            var data = {
                KendoOptions: JSON.stringify(options.data),
                tillId: $scope.tillLong,
                ShowError: true
            };



            var request = {
                ClassName: "Teller_Transaction_Helper",
                Method: "GetTransactionsByStageKendo",
                Data: JSON.stringify(data)
            };
            Teller_Header_Controller.GenericRemoting(request, function(result, event) {

                if (event.type == 'exception') {
                    alert(event.message);
                } else {
                    options.success(result);
                    //options.data = result;
                    var ff = 2;
                } // End else

            });
        }
    }
});

$scope.ErrorGridOptions = {
dataSource: $scope.DSError,
detailTemplate: kendo.template($("#detailtemplate").html()),
pageable: {
refresh: true,
pageSizes: true,
buttonCount: 5
},
sortable: false,

columns: [{
    field: "Description",
    title: "Description"


}, {
    field: "Status",
    title: "Status"


}, {
    field: "Value",
    title: "Value",
    format: "{0:c2}"
}, {
    field: "CreatedTime",
    title: "CreatedTime"


}


]
};


$scope.DSCancelled = new kendo.data.DataSource({
    pageSize: 20,
    serverPaging: true,
    serverSorting: true,

    schema: {
        total: "total",
        data: "Items",
        model: {
            fields: {
                Description: {
                    type: "string"
                },
                Value: {
                    type: "number"
                },
                CreatedTime: {
                    type: "string"
                },
                Status: {
                    type: "string"
                }
            }

        }

    },
    transport: {
        read: function(options) {

            options.data.sortField = options.data.sort;

            var data = {
                KendoOptions: JSON.stringify(options.data),
                tillId: $scope.tillLong,
                ShowCancelled: true
            };



            var request = {
                ClassName: "Teller_Transaction_Helper",
                Method: "GetTransactionsByStageKendo",
                Data: JSON.stringify(data)
            };
            Teller_Header_Controller.GenericRemoting(request, function(result, event) {

                if (event.type == 'exception') {
                    alert(event.message);
                } else {
                    options.success(result);
                    //options.data = result;
                    var ff = 2;
                } // End else

            });
        }
    }
});

$scope.CancelledGridOptions = {
dataSource: $scope.DSCancelled,
detailTemplate: kendo.template($("#detailtemplate").html()),
pageable: {
refresh: true,
pageSizes: true,
buttonCount: 5
},
sortable: false,

columns: [{
    field: "Description",
    title: "Description"


}, {
    field: "Status",
    title: "Status"


}, {
    field: "Value",
    title: "Value",
    format: "{0:c2}"
}, {
    field: "CreatedTime",
    title: "CreatedTime"


}


]
};


$scope.DSPending = new kendo.data.DataSource({
    pageSize: 20,
    serverPaging: true,
    serverSorting: true,

    schema: {
        total: "total",
        data: "Items",
        model: {
            fields: {
                Description: {
                    type: "string"
                },
                Value: {
                    type: "number"
                },
                CreatedTime: {
                    type: "string"
                },
                Status: {
                    type: "string"
                }
            }

        }

    },
    transport: {
        read: function(options) {

            options.data.sortField = options.data.sort;

            var data = {
                KendoOptions: JSON.stringify(options.data),
                tillId: $scope.tillLong,
                ShowPendingAuth: true
            };



            var request = {
                ClassName: "Teller_Transaction_Helper",
                Method: "GetTransactionsByStageKendo",
                Data: JSON.stringify(data)
            };
            Teller_Header_Controller.GenericRemoting(request, function(result, event) {

                if (event.type == 'exception') {
                    alert(event.message);
                } else {
                    options.success(result);
                    //options.data = result;
                    var ff = 2;
                } // End else

            });
        }
    }
});

$scope.PendingGridOptions = {
dataSource: $scope.DSPending,
detailTemplate: kendo.template($("#detailtemplate").html()),
pageable: {
refresh: true,
pageSizes: true,
buttonCount: 5
},
sortable: false,

columns: [{
    field: "Description",
    title: "Description"


}, {
    field: "Status",
    title: "Status"


}, {
    field: "Value",
    title: "Value",
    format: "{0:c2}"
}, {
    field: "CreatedTime",
    title: "CreatedTime"


}


]
};




$scope.DSCompleted = new kendo.data.DataSource({
    pageSize: 20,
    serverPaging: true,
    serverSorting: true,

    schema: {
        total: "total",
        data: "Items",
        model: {
            fields: {
                Description: {
                    type: "string"
                },
                Value: {
                    type: "number"
                },
                CreatedTime: {
                    type: "string"
                },
                Status: {
                    type: "string"
                }
            }

        }

    },
    transport: {
        read: function(options) {

            options.data.sortField = options.data.sort;

            var data = {
                KendoOptions: JSON.stringify(options.data),
                tillId: $scope.tillLong,
                ShowCompleted: true
            };



            var request = {
                ClassName: "Teller_Transaction_Helper",
                Method: "GetTransactionsByStageKendo",
                Data: JSON.stringify(data)
            };
            Teller_Header_Controller.GenericRemoting(request, function(result, event) {

                if (event.type == 'exception') {
                    alert(event.message);
                } else {
                    options.success(result);
                    //options.data = result;
                    var ff = 2;
                } // End else

            });
        }
    }
});

$scope.CompletedGridOptions = {
dataSource: $scope.DSCompleted,
detailTemplate: kendo.template($("#detailtemplate").html()),
pageable: {
refresh: true,
pageSizes: true,
buttonCount: 5
},
sortable: false,

columns: [{
    field: "Description",
    title: "Description"


}, {
    field: "Status",
    title: "Status"


}, {
    field: "Value",
    title: "Value",
    format: "{0:c2}"
}, {
    field: "CreatedTime",
    title: "CreatedTime"


}


]
};




}]);



app1.controller('Teller_HomeCtl', ['$scope', function($scope){
        
        $scope.loading = null;
        
        $scope.till = tillId;
        $scope.tillShort = tillId.substring(0,15);
        $scope.showCompleted = true;
        $scope.showError = false;
        $scope.showPending = false;
        $scope.showMovement = false;
        
        $scope.refreshGrid = function(){
            var grid = $('#myGrid').data('kendoGrid');
            if(grid)
            {
                $('#myGrid').data('kendoGrid').dataSource.read();
                $('#myGrid').data('kendoGrid').refresh();
            }   
        }
                
        
        $scope.$watch("branch", function(newValue, oldValue) {
              if($scope.branch != null)
              {
                $scope.tillData = new kendo.data.ObservableArray( $scope.branch.Tills);
                $scope.still = $scope.tillData[0].Name;
                }                
                
                });
               
        $scope.$watch("showCompleted", function(newValue, oldValue) {
              $scope.refreshGrid();
                });    
        $scope.$watch("showError", function(newValue, oldValue) {
              $scope.refreshGrid();
                });
        $scope.$watch("showPending", function(newValue, oldValue) {
              $scope.refreshGrid();
                });   
               
                
        $scope.ShowMovementToggle = function(){  
             $scope.showMovement = !$scope.showMovement;
        }         
        
        
        $scope.CreateTransfer = function()
        {
            var url = '/apex/Teller_TillTransfer?till=' + $scope.till + '&create=10';
        
            $scope.URLPopup(url);
        }
        
        
        
        
        $scope.URLPopup= function(url)
        {
            var f = $("#dialog").data("kendoWindow");
            if (f === undefined) {
                 var d =$("#dialog").kendoWindow({
            content: url,
            iframe: true,
            width: "700px",
            height: "500px",
            

            modal:true
        });
            
            }
            else
            {
                f.content('Loading...');
                f.refresh({
                    url: url
                });
                
                f.open();
            }
  
          var d = $("#dialog").data("kendoWindow");
          d.center();
       }
        
          
               
        
        $scope.headerTemplate = '<div class="row k-state-deta"><div class="col-sm-3">Name</div><div class="col-sm-3">Cash</div><div class="col-sm-3">User</div></div>';
        $scope.templ = '<div class="row"><div class="col-sm-3">{{dataItem.Name}}</div><div class="col-sm-3">{{dataItem.Cash}}</div><div class="col-sm-3">{{dataItem.Username}}</div>  </div>';
        
        
        
        $scope.templ2 = '<span class="selected-value"> {{dataItem.Name}}</span>';
        
        
        $scope.DS = new kendo.data.DataSource({
        
        pageSize: 20,
          serverPaging: true,
          serverSorting: true,
          
        schema: {
               total: "total",
               data: "Items",
               model:{
                   fields:{
                       Description:{type:"string"},
                       Value:{type:"number"},
                       CreatedTime:{type:"string"},
                       Status:{type:"string"}
                   }
               
               }
               
            },
    transport: {
      read: function(options) {
      
      options.data.sortField = options.data.sort;
      
      
      Teller_TillController.GetTrans(JSON.stringify(options.data),$scope.showCompleted,$scope.showPending,$scope.showError,$scope.till,
          function(result,event){
              if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        options.success(result);
                        //options.data = result;
                        var ff = 2;
                    } // End else

        });
      
/*
      
      Visualforce.remoting.Manager.invokeAction(
          "{!$RemoteAction.Teller_TillController.GetTrans}",JSON.stringify(options.data),$scope.showCompleted,$scope.showPending,$scope.showError,$scope.till,  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        options.success(result);
                        //options.data = result;
                        var ff = 2;
                    } // End else


                      

            });*/
      }
      
      
            
           
      
      
    }
    
  });
     
     
     
     $scope.mainGridOptions = {
            dataSource: $scope.DS, 
            detailTemplate: kendo.template($("#detailtemplate").html()),           
            pageable: {
                            refresh: true,
                            pageSizes: true,
                            buttonCount: 5
                        }, 
                        toolbar: kendo.template($("#template").html()),
            sortable: false,  
                          
            columns: [{
                field: "Description",
                title: "Description"
            
            
            },{
                field: "Status",
                title: "Status"
            
            
            },
            {
            field: "Value",
                title: "Value" ,                
                format:"{0:c2}"            
            },
            {
                field:"CreatedTime",
                title:"CreatedTime"
                
                
            }
            
            
            ]
        };
                
      
       
       $scope.TransfersToday = function(){
            Teller_TillController.GetTillTransfersToday($scope.till,  
              function (result, event) {
                if (event.type == 'exception') {
                    alert(event.message);
                } else {                    
                    $scope.transfers=  result;
            }            
            $scope.$apply();            
            });       
       }
       
       $scope.CancelTransfer = function(transfer){
           $scope.win2.center();
           $scope.win2.open();  
           $scope.transferToCancel = transfer;
           $scope.cancelTransferSuccess = null;
           $scope.cancelTransferError = null;         
       }
       
       $scope.ApproveOverrideTransfer = function(transfer){
           $scope.win3.center();
           $scope.win3.open();  
           $scope.transferToCancel = transfer;
           $scope.cancelTransferSuccess = null;
           $scope.cancelTransferError = null;       
       }
       
       
       
       
       
       $scope.CallCancelTransfer = function(transferId){
           Teller_TillController.CancelTransfer(transferId,  function (result, event) {
                if (event.type == 'exception') {
                    alert(event.message);
                } else {                    
                    if(result.Success)
                    {
                        $scope.cancelTransferSuccess = true;
                        RefreshTransfers();
                    }
                    else
                    {
                        $scope.cancelTransferError = result.Error;
                    }
            }            
            $scope.$apply();            
            });       
       }
       
       $scope.CallApproveOverrideTransfer = function(transferId){
           Teller_TillController.ApproveOverride(transferId,$scope.username + '@islamic-bank.com.baa',$scope.password,  function (result, event) {
                if (event.type == 'exception') {
                    alert(event.message);
                } else {                    
                    if(result.Success)
                    {
                        $scope.cancelTransferSuccess = true;
                        RefreshTransfers();
                    }
                    else
                    {
                        $scope.cancelTransferError = result.Error; 
                        $scope.cancelTransferSuccess = false;                       
                    }
            }    
                    
            $scope.$apply();            
            });       
       }
                
        
       $scope.LoadData = function(){
           $scope.loading = true;
           $scope.branch = null;
           $scope.still = null;
           
           $scope.TransfersToday();
           
           Teller_TillController.GetTillData(function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                        //options.success(result);
                       
                       $scope.data=  result;
                        
                                           
                    } // End else
                    $scope.loading=null;
                    $scope.$apply();
                    //setTimeout(SetupPopup, 1000);
                });
                
                
            }
      
       
    }]);