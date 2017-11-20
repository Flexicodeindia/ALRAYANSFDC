var myApp = angular.module('myApp', ['ui.router'])

myApp.config(function ($stateProvider, $urlRouterProvider) {

    $stateProvider
        .state('index', {
            url: "",
            views:
                {
                    "viewContent": { templateUrl: "apex/teller_test_angularindex" }
                }
        })

    .state('item1', {
        url: "item1",
        views:
             {
                 "viewContent": { templateUrl: "apex/teller_test_parent" }
             }
    })

    .state('item2', {
        url: "item2",
        views:
             {
                 "viewContent": { templateUrl: "apex/teller_test_child" }
             }
    })

    .state('Parent', {
        url: "Parent",
        views:
             {
                 "viewContent": { templateUrl: "apex/teller_test_AngularParent" }
             }
    })

    .state('Child', {
        url: "Child",
        views:
             {
                 "viewContent": { templateUrl: "apex/teller_test_AngularChild" }
             }
    });
});