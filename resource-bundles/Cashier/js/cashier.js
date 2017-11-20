//kendo.culture("en-GB");
var app1 = angular.module('cashier',[ 'kendo.directives' ]);


$(document).ready(function() {
                    $("#treeview").kendoTreeView();
                });

angular.module('cashier').directive('ngEnter', function() {
        return function(scope, element, attrs) {
            element.bind("keydown keypress", function(event) {
                if(event.which === 13) {
                    scope.$apply(function(){
                        scope.$eval(attrs.ngEnter, {'event': event});
                    });

                    event.preventDefault();
                }
            });
        };
    });



 function refreshTillData()
        {
            var scope = angular.element(
                            document.getElementById("Teller_TillData")).
                            scope();
                            scope.$apply(function () {
                                scope.LoadData ();
                            });
        }

     
app1.controller('Teller_TillDataController', ['$scope', function($scope){         
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


app1.controller('Teller_MenuController', ['$scope', function($scope){   

        $scope.test = 1;

       $scope.OpenFunction = function(functionId,url,title){
            var f = $("#dialog").data("kendoWindow");
            if (f === undefined) {
                 var d =$("#dialog1").kendoWindow({
            content: url + "?fnc=" + functionId,
            iframe: true,
            title: title,
            width: "700px",
            height: "500px",
            actions: [],
            

            modal:true


            })}}


    }]);




$(function(){

$("#site-menu").swipe( {
        //Generic swipe handler for all directions
        swipe:function(event, direction, distance, duration, fingerCount, fingerData) {
          //$(this).text("You swiped " + direction );  
          
            if(direction  == 'left')
          {
                  $('#site-wrapper').removeClass('show-nav');
                $('#thinMenu').removeClass('hide-nav');
                $('#contDiv').removeClass('hide-nav');
          }          
        },
         threshold:25
      });
      
      
      $("#thinMenuExpand").click(function(){
           $('#site-wrapper').addClass('show-nav');
                $('#thinMenu').addClass('hide-nav');
                $('#contDiv').addClass('hide-nav');
      });
      
$("#thinMenu").swipe( {
        //Generic swipe handler for all directions
        swipe:function(event, direction, distance, duration, fingerCount, fingerData) {
          //$(this).text("You swiped " + direction );  
          
            if(direction  == 'right')
          {
                  $('#site-wrapper').addClass('show-nav');
                $('#thinMenu').addClass('hide-nav');
                $('#contDiv').addClass('hide-nav');
          }          
        },
         threshold:25
      });      
      
      
      $(document).keyup(function(e) {
    if (e.keyCode == 27) {
        if ($('#site-wrapper').hasClass('show-nav')) {
             $('#site-wrapper').removeClass('show-nav');
                $('#thinMenu').removeClass('hide-nav');
                $('#contDiv').removeClass('hide-nav');
        }
        
        if ($('#rightm').hasClass('show-nav')) {
             $('#rightm').removeClass('show-nav');
        $('#site-wrapper').removeClass('show-right');
        $('#rr').removeClass('hide-nav');
        }
    } 
});


/*====================================
=            ON DOM READY            =
====================================*/
    $('.toggle-nav').click(function() {
        // Calling a function in case you want to expand upon this.
        toggleNav();
    });
    $('.toggle-right').click(function() {
        // Calling a function in case you want to expand upon this.
        toggleRight();
    });




function toggleNav() {
    if ($('#site-wrapper').hasClass('show-nav')) {
        // Do things on Nav Close
        $('#site-wrapper').removeClass('show-nav');
        $('#thinMenu').removeClass('hide-nav');
        $('#contDiv').removeClass('hide-nav');
    } else {
        // Do things on Nav Open
        $('#site-wrapper').addClass('show-nav');
        $('#thinMenu').addClass('hide-nav');
        $('#contDiv').addClass('hide-nav');
    }
}
});