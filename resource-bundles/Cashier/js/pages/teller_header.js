 function refreshTillData()
        {
          /*
            var scope = angular.element(
                            document.getElementById("Teller_TillData")).
                            scope();
                            scope.$apply(function () {
                                scope.LoadData ();
                            });
 */
        }


 var response = {
                    data:{
                      d:{
                        results:[{id:1,Name: "Test1"},{id:2,Name: "Test2"},{id:3,Name: "Test3"}]
                      }
                    }
                  };


                

     
app1.controller('Teller_HeaderController', ['$scope', function($scope){       

    //$scope.tillData = response;// new kendo.data.ObservableArray(response.data.d.results );

    $scope.tillData = [
  { id: 1, name: "Apples" },
  { id: 2, name: "Oranges" }
];

  /*$scope.tillData = [
          "Albania",
          "Andorra",
          "Armenia",
          "Austria",
          "Azerbaijan",
          "Belarus",
          "Belgium",
          "Bosnia & Herzegovina"];
*/

     $scope.refreshList = function(){

        var autocomplete = $("#CustomerSearch").data("kendoAutoComplete");
        if(autocomplete)
        {
            if(autocomplete.dataSource)
            autocomplete.dataSource.read();
        }

        

           // var grid = $('#CustomerSearch').data('kendoGrid');
            //if(grid)
            //{P
                //$('#CustomerSearch').data('kendoGrid').dataSource.read();
                //$('#CustomerSearch').data('kendoGrid').mefresh();
            //}   

        }


    $scope.$watch("SFind", function(newValue, oldValue) {
              $scope.refreshList();
                });


    $scope.template = '<span class="k-state-default" style="text-weight:bold;"><a> #: data.Name #</a></span><span class="pull-right">#: EBSId #</span><div><span class="k-state-default"><p>#: data.Address #</p></span></div>';


    $scope.DS = new kendo.data.DataSource({
        
        schema: {
  data: "Items"
 },
 serverFiltering: true,
    transport: {
      read: function(options) {      
      
        //options.success(response);

      
      
      Teller_Header_Controller.FindCustomer($scope.SFind,  function (result, event) {
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

        



/*

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


*/
       $scope.LoadData = function(){
           $scope.loading = true;
           Visualforce.remoting.Manager.invokeAction(
                    "Teller_Header_Controller.GetTillStatus",  function (result, event) {
                    if (event.type == 'exception') {
                        alert(event.message);
                    } else {                    
                       $scope.TillData= result;
                    } // End else
                    $scope.$apply();
                });
            }
    }]);