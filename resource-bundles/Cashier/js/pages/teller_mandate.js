app1.controller('Teller_Mandate', ['$scope', function($scope){

   function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    $scope.LoadMandateItems= function(){

        var mandateId = getParameterByName('mandateId');
        var accountWithIBBId = getParameterByName('accountWithIBBId');
        console.log('mandateId: ' + mandateId);
        console.log('accountWithIBBId: ' + accountWithIBBId);

        if (mandateId != ''){
            // Need to disable Mandate Name and Currency
            document.getElementById('AccountCurrency').disabled = true;
        }
        else{
            // Need to enable Mandate Name and disable Currency
            document.getElementById('AccountCurrency').disabled = true;
        }

        var request = {MandateId: mandateId, AccountWithIBBId: accountWithIBBId}; 
        Teller_Mandate_Controller.LoadMandateItems(request, function (result, event) {
            if (event.type == 'exception') {
                alert(event.message);
            } else {
                $scope.response= result;
            } // End else
            $scope.$apply();
        });  
    }

    $scope.addRow = function(){
        var rdSigOption = document.getElementById('SignatoryOptionId');
        var mandateId;

        if (rdSigOption.checked){
            var st = document.getElementById('signatoryInput');
            var signatoryType = st.options[st.selectedIndex].text;
            var signatoryId = st.options[st.selectedIndex].value;
            mandateId = signatoryType;
        }
        else{
            var rt = document.getElementById('relationshipTypeInput');
            var relationshipType = rt.options[rt.selectedIndex].text;            
            var nofromgroup = document.getElementById('noFromGroupInput').value;
            var signatoryId = '';
            mandateId = relationshipType;
        }

        // Perform validation checks
        var validationErrors = false;
        if ((rdSigOption.checked) && (signatoryType == '')){
            validationErrors = true;
            alert('Signatory Option has been selected but no signatory has been selected');
        }
        else if ((!rdSigOption.checked) && (relationshipType == '')){
            validationErrors = true;
            alert('Relationship Type Option has been selected but no relationship type has been selected');
        }
        else if ((!rdSigOption.checked) && (nofromgroup == '')){
            validationErrors = true;
            alert('Relationship Type Option has been selected but no No from Group has been input');
        }
        else if ((!rdSigOption.checked) && (!isNumeric(nofromgroup))){
            validationErrors = true;
            alert('Entry in No from Group is not numeric');
        }

        if ((!signatoryType == '') && (!validationErrors)){
            // Adding Signatory Type, need to remove 
            st.remove(st.selectedIndex);
        }
        else if (!validationErrors){
            // Adding Relationship Type, need to remove
            rt.remove(rt.selectedIndex);
            document.getElementById('noFromGroupInput').value = '';
        }


        console.log('relationshiptype: ' + relationshipType);
        console.log('nofromgroup: ' + nofromgroup);

        if (!validationErrors){
           $scope.response.MandateItems.push({'SignatoryId': signatoryId, 'Signatory': signatoryType ,'RelationshipType': relationshipType, 'NoFromGroup': nofromgroup, 'MandateItemId': mandateId});
        }
    }

    $scope.removeRow = function(name){
        var index = -1;     
        var comArr = eval( $scope.response.MandateItems );
        for( var i = 0; i < comArr.length; i++ ) {
            if( comArr[i].MandateItemId === name ) {
                index = i;
                break;
            }
        }
        if( index === -1 ) {
            alert( "Error when removing Mandate Rule" );
        } 
        else{
            // Need to add item back into drop downs
            if (typeof comArr[i].Signatory != 'undefined'){
                // Signatory
                var st = document.getElementById('signatoryInput');
                var option = document.createElement('option');
                option.text = comArr[i].Signatory;
                st.add(option);
            }
            else{
                // Relationship Type
                var rt = document.getElementById('relationshipTypeInput');
                var option = document.createElement('option');
                option.text = comArr[i].RelationshipType;
                rt.add(option);
            }

            $scope.response.MandateItems.splice( index, 1 ); 
        }
    }

    $scope.Cancel = function()
    {
        console.log('teller_mandate.Cancel Entry');
        console.log('typeof parent.window: ' + typeof parent.window);
        /*
        console.log('parent.window.closeDialog: ' + parent.window.closeDialog);
        closeDialog();

        if(typeof parent.window !== 'undefined' && typeof parent.window.closeDialog === 'closeDialog'){
            console.log('if statement entry');
            closeDialog(); //Call the function only if it exists
        }
        */
        window.parent.closeDialog();
    }

    $scope.Save= function()
    {
        console.log('teller_mandate.Save Entry');

        // Populate request message
        var request = new Mandate();

        request.MandateId = getParameterByName('mandateId');
        request.AccountWithIBBId = getParameterByName('accountWithIBBId');
        request.MandateLimit = $scope.response.MandateLimit;
        request.MandateItems = new Array();
        //request.MandateItems = $scope.response.MandateItems;

        var comArr = eval( $scope.response.MandateItems );
        for( var i = 0; i < comArr.length; i++ ) {

            var mi = new MandateItem();
            mi.Signatory = comArr[i].Signatory;
            mi.RelationshipType = comArr[i].RelationshipType;
            mi.NoFromGroup = comArr[i].NoFromGroup;
            request.MandateItems[request.MandateItems.length] = mi;
        }


        console.log('request MandateId: ' + request.MandateId);
        console.log('request AccountWithIBBId: ' + request.AccountWithIBBId);
        console.log('request MandateLimit: ' + request.MandateLimit);
        console.log('request MandateItems: ' + request.MandateItems);

        Teller_Mandate_Controller.SaveMandateItems(request, function (result, event) {
            if (event.type == 'exception') {
                alert(event.message);
            } else if (result.Success == false){
                alert(result.ErrorMessage);
            }
            else {
                $scope.response= result;
            } // End else
            $scope.$apply();
            window.parent.closeDialog();
        }); 
    }

    function isNumeric(input)
    {
        var regex=/^[0-9]+$/;
        if (input.match(regex)){
            return true;
        }
        else{
            return false;
        }

    }

    function Mandate(){
        this.MandateId=null;
        this.AccountWithIBBId=null;
        this.MandateLimit=null;
        this.MandateItems=null;
    }
    function MandateItem(){
        this.SignatoryId=null;
        this.Signatory=null;
        this.RelationshipType=null;
        this.NoFromGroup=null;
    }

    function RefreshParent() {
        if (window.opener != null && !window.opener.closed) {
            window.opener.location.reload();
        }
    }
    window.onbeforeunload = RefreshParent;
}]);


function optionClick(optionType){
    if (optionType == 'Signatory'){
        document.getElementById('signatoryInput').disabled = false;
        document.getElementById('relationshipTypeInput').disabled = true;
        document.getElementById('noFromGroupInput').disabled = true;
        document.getElementById('relationshipTypeInput').value = '';
        document.getElementById('noFromGroupInput').value = '';
    }
    else{
        document.getElementById('signatoryInput').disabled = true;
        document.getElementById('relationshipTypeInput').disabled = false;
        document.getElementById('noFromGroupInput').disabled = false;
        document.getElementById('signatoryInput').value = false;
    }
};