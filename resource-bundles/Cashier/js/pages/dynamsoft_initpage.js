var _imageCaptureParam = {
'productKey': '8F5A39B4116149C7ECC5DB7E7CD7EB4E5E1C34157AC37E392A2DEEA05F241FEA5E1C34157AC37E394542C3F1E1DFEA245E1C34157AC37E39986B43B7AA481C365E1C34157AC37E3930B551056E4F93B95E1C34157AC37E39A09E41EDB1B51DF85E1C34157AC37E39F1F65F9D65A169795E1C34157AC37E39C59F677ABF4986015E1C34157AC37E3981EBD6584EAC3E0280000000',
'containerID': 'dwtcontrolContainer',   //The ID of ImageCapture Suite control div in HTML.This value is required.

'width': _iWidth,        //The width of ImageCapture Suite control. This value is optional. The default value is '580'.
'height': _iHeight,       //The height of  ImageCapture Suite control.This value is optional. The default value is '600'.

    /*
    'isTrial': 'true',  
    isTrial is used to judge whether ImageCapture Suite control is trial or full. This value is optional.
    The default value is 'TRUE', which means the conrol is a trial one. The value of isTrial is 'TRUE' or 'FALSE'.
    */

    /*
    'version': '9,3',   
    The version of ImageCapture Suite control, which is used to judge the version when downloading CAB.
    This value is optional. The default value is '9,3'.
    */

    /*
    'resourcesPath': 'Resources',   
    The relative path of MSI, CAB and PKG.
    This value is optional. The default value is 'Resources'.
    */

    /*  These are events. The name of ‘OnPostAllTransfer’shouldn’t be changed, but the name of ‘Dynamsoft_OnPostAllTransfers’ can be modified. 
    Please pay attention, the name of ‘Dynamsoft_OnPostAllTransfers’ and ‘function Dynamsoft_OnPostAllTransfers()’ event must be coincident.
        
    Events are as follows. You can choose one or many according to you needs.
    Once an event is added, you must make sure the corresponding function is defined in your code.
        
    'onPostTransfer':Dynamsoft_OnPostTransfer,
    'onPostAllTransfers':Dynamsoft_OnPostAllTransfers,  
    'onMouseClick':Dynamsoft_OnMouseClick,   
    'onPostLoad':Dynamsoft_OnPostLoadfunction,    
    'onImageAreaSelected':Dynamsoft_OnImageAreaSelected,   
    'onMouseDoubleClick':Dynamsoft_OnMouseDoubleClick,   
    'onMouseRightClick':Dynamsoft_OnMouseRightClick,   
    'onTopImageInTheViewChanged':Dynamsoft_OnTopImageInTheViewChanged,   
    'onImageAreaDeSelected':Dynamsoft_OnImageAreaDeselected,    
    'onGetFilePath':Dynamsoft_OnGetFilePath  
    */                              
    'onPostTransfer':Dynamsoft_OnPostTransfer,
    'onPostAllTransfers':Dynamsoft_OnPostAllTransfers,
    'onMouseClick':Dynamsoft_OnMouseClick,   
    'onPostLoad':Dynamsoft_OnPostLoadfunction,    
    'onImageAreaSelected':Dynamsoft_OnImageAreaSelected,   
    'onMouseDoubleClick':Dynamsoft_OnMouseDoubleClick,   
    'onMouseRightClick':Dynamsoft_OnMouseRightClick,   
    'onTopImageInTheViewChanged':Dynamsoft_OnTopImageInTheViewChanged,
    'onImageAreaDeSelected': Dynamsoft_OnImageAreaDeselected,
    'onGetFilePath': Dynamsoft_OnGetFilePath
   
};


var gImageCapture;
(function() {
    gImageCapture = new Dynamsoft.ImageCapture(_imageCaptureParam);
})();


//--------------------------------------------------------------------------------------
//************************** Don't change these properties *****************************
//--------------------------------------------------------------------------------------
var DWObject;            // The ICS Object
var _bInIE;               // If it is in IE
var _bInWindows;          // If it is in Windows OS
var _bInWindowsX86;       // If it is in X86 platform
var _divMessageContainer;   // For message display
var _strTempStr = "";       // Store the temp string for display
var _iWidth = 580;        // The width of the main control. User can change it.
var _iHeight = 600;       // The width of the main control. User can change it.

//--------------------------------------------------------------------------------------
//****************** Default value provided. User can change it accordingly ************
//--------------------------------------------------------------------------------------
var _bDiscardBlankImage = false;  // User can change it.
var _bShowMessagePanel = true;
var _bShowNavigatorPanel = true;
var _divICSSourceContainerID = "source";     // The ID of the container (Usually <select>) which is used to show the available sources. User must specify it.
var _iLeft, _iTop, _iRight, _iBottom; //These variables are used to remember the selected area
var _txtFileNameforSave, _txtFileName, _chkMultiPageTIFF_save, _chkMultiPagePDF_save, _chkMultiPageTIFF, _chkMultiPagePDF;
//--------------------------------------------------------------------------------------
//****************** User must specify it before using ICS *****************************
//--------------------------------------------------------------------------------------
var _divDWTContainerID = "dwtcontrolContainer"; //"DWTContainerID"; // The ID of the container (Usually a DIV) which is used to contain ICS object. User must specify it.
var _divDWTNonInstallContainerID = "DWTNonInstallContainerID" // The ID of the container (Usually a DIV) which is used to show a message if ICS is not installed. User must specify it.
var _strDefaultSaveImageName = "ICSImage";
var _strNoDrivers = "No webcams or TWAIN compatible drivers detected:";
var _strMSIPath = "Resources/ImageCaptureSuitePlugIn.msi";
var _strPKGPath = "Resources/ImageCaptureSuiteMacEdition.pkg";
var _strProductName = "ImageCapture Suite";

var _strBarcodeVersion = "9, 3, 0, 212";
var _strOCRVersion = "9, 3, 0, 217";
var _strPDFVersion = "9, 3, 0, 212";

var _strVersion = "9,3,0,212";


//Upload
var _strServerName = location.hostname; //Demo: "www.dynamsoft.com";
var _strPort = location.port == "" ? 80 : location.port; //Demo: 80;

//Sample
var _strActionPage = "SaveToFile.aspx";
//var _strActionPage = "SaveToDB.aspx";
var _strDynamsoftWithClose = "<div style='height:40px'><a href=\"http://www.dynamsoft.com/\" style='padding-right:60px'><img src=\"Images/logo.gif\" alt=\"Dynamsoft: provider of version control solution and TWAIN SDK\" name=\"logo\" width=\"159\" height=\"34\" border=\"0\" align=\"left\" id=\"logo\" title=\"Dynamsoft: provider of version control solution and TWAIN SDK\" /></a><div style='height:30px;padding-left:48px; position:absolute; top:5px; left:110px;'><a href='javascript: void(0)' style='text-decoration:none; padding-left:200px' class='ClosetblCanNotScan'>X</a></div></div>";

var _iCanNotScanDialogHeigth = 242;

// Assign the page onload fucntion.
function S_get(id) {
    return document.getElementById(id);
}

var S = KISSY, Event = S.Event, Dom = S.DOM;

var seed;
function pageonload() {
    getEnvironment();
    
    initMessageBox(false);  //Messagebox
    initCustomScan();       //CustomScan

    initiateInputs();

    seed = setInterval(controlDetect, 500);     
}


function getEnvironment() {
    // Get User Agent Value
    ua = (navigator.userAgent.toLowerCase());
    if (ua.indexOf("wow64") == -1) {
        var samplesource32bitCtr = document.getElementById("samplesource32bit");
        if (samplesource32bitCtr)
            samplesource32bitCtr.href = "http://www.dynamsoft.com/demo/DWT/Sources/twainkit.exe";
    }

    // Set the Explorer Type
    if (ua.indexOf("msie") != -1 || ua.indexOf('trident') != -1)
        _bInIE = true;
    else
        _bInIE = false;

    // Set the Operating System Type
    if (ua.indexOf("macintosh") != -1)
        _bInWindows = false;
    else
        _bInWindows = true;

    // Set the x86 and x64 type
    if (ua.indexOf("win64") != -1 && ua.indexOf("x64") != -1)
        _bInWindowsX86 = false;
    else
        _bInWindowsX86 = true;

}



function initCustomScan() {
    var ObjString = "<ul id='divTwainType' style='display:none; height:70px; background:#f0f0f0;'> ";
    ObjString += "<li style='padding-left:12px;'>";
    ObjString += "<label for = 'ShowUI'><input type='checkbox' id='ShowUI' />Show UI&nbsp;</label>";
    ObjString += "<label for = 'ADF'><input type='checkbox' id='ADF' />ADF&nbsp;</label>";
    ObjString += "<label for = 'Duplex'><input type='checkbox' id='Duplex'/>Duplex</label></li>";
    ObjString += "<li style='padding-left:15px;'>Pixel Type:";
    ObjString += "<label for='BW'><input type='radio' id='BW' name='PixelType'/>B&amp;W </label>";
    ObjString += "<label for='Gray'><input type='radio' id='Gray' name='PixelType'/>Gray</label>";
    ObjString += "<label for='RGB'><input type='radio' id='RGB' name='PixelType'/>Color</label></li>";
    ObjString += "<li style='padding-left:15px;'>";
    ObjString += "<label for='Resolution'>Resolution:<select size='1' id='Resolution'><option value = ''></option></select></label></li>";
    ObjString += "</ul>";
    if (_bInWindows)
        ObjString += "<ul id='divWebcamType' style='display:none; height:75px; background:#f0f0f0;'>";
    else
        ObjString += "<ul id='divWebcamType' style='display:none; height:20px; background:#f0f0f0;'>";
    ObjString += "<li style='padding-left:12px;'>";
    ObjString += "<label for = 'ShowUIForWebcam'><input type='checkbox' id='ShowUIForWebcam' />Show UI&nbsp;</label></li>";
    if (_bInWindows) {
        ObjString += "<li style='padding-left:15px;'>";
        ObjString += "<label for='MediaType'>Media Type:<select size='1' id='MediaType'><option value = ''></option></select></label></li>";
        ObjString += "<li style='padding-left:15px;'>";
        ObjString += "<label for='Resolution'>Resolution:&nbsp;<select size='1' id='ResolutionWebcam'><option value = ''></option></select></label></li>";
    }
    ObjString += "</ul>";
    if (document.getElementById("divProductDetail"))
        document.getElementById("divProductDetail").innerHTML = ObjString;

    var vResolution = document.getElementById("Resolution");
    if (vResolution) {
        vResolution.options.length = 0;
        vResolution.options.add(new Option("100", 100));
        vResolution.options.add(new Option("150", 150));
        vResolution.options.add(new Option("200", 200));
        vResolution.options.add(new Option("300", 300));
    }
}

function initiateInputs() {

    var allinputs = document.getElementsByTagName("input");
    for (var i = 0; i < allinputs.length; i++) {
        if (allinputs[i].type == "checkbox") {
            allinputs[i].checked = false;
        }
        else if (allinputs[i].type == "text") {
            allinputs[i].value = "";
        }
    }

    if (!_bInWindows) {
        if (document.getElementById("btnEditor"))
            document.getElementById("btnEditor").style.display = "none";
        document.getElementById("tblLoadImage").style.height = "170";
        document.getElementById("notformac1").style.display = "none";
    }

    if (_bInIE == true && _bInWindowsX86 == false) {
        document.getElementById("samplesource64bit").style.display = "inline";
        document.getElementById("samplesource32bit").style.display = "none";
    }

    vShowNoControl = false;
    vNotAllowedForChrome = false;
    vInvalidForPluginX64 = false;
    if (!_bInIE)
        vPluginLength = navigator.plugins.length;

}

function initMessageBox(bNeebBack) {
    var objString = "";

    // The container for navigator, view mode and remove button
    objString += "<div style='text-align:center; width:" + _iWidth + "px; background-color:#FFFFFF;";
    if (_bShowNavigatorPanel)
        objString += "display:block'>";
    else
        objString += "display:none'>";
    objString += "<div style='position:relative; background:white; float:left; width:430px; height:35px; z-index:2;'>";
    objString += "<input id='DW_btnFirstImage' onclick='btnFirstImage_onclick()' type='button' value=' |&lt; '/>&nbsp;";
    objString += "<input id='DW_btnPreImage' onclick='btnPreImage_onclick()' type='button' value=' &lt; '/>&nbsp;&nbsp;";
    objString += "<input type='text' size='2' id='DW_CurrentImage' readonly='readonly'/>/";
    objString += "<input type='text' size='2' id='DW_TotalImage' readonly='readonly'/>&nbsp;&nbsp;";
    objString += "<input id='DW_btnNextImage' onclick='btnNextImage_onclick()' type='button' value=' &gt; '/>&nbsp;";
    objString += "<input id='DW_btnLastImage' onclick='btnLastImage_onclick()' type='button' value=' &gt;| '/></div>";
    objString += "<div style='position:relative; background:white; float:left; width:150px; height:35px;z-index:2;'>Preview Mode";
    objString += "<select size='1' id='DW_PreviewMode' onchange ='setlPreviewMode();'>";
    objString += "    <option value='0'>1X1</option>";
    objString += "</select><br /></div>";
    objString += "<div><input id='DW_btnRemoveCurrentImage' onclick='btnRemoveCurrentImage_onclick()' type='button' value='Remove Selected Images'/>";
    if (bNeebBack) {
        objString += "<input id='DW_btnRemoveAllImages' onclick='btnRemoveAllImages_onclick()' type='button' value='Remove All Images'/><br /><br />";
        objString += "<span style=\"font-size:larger\"><a href =\"online_demo_list.aspx\"><b>Back</b></a></span><br /></div>";
    }
    else {
        objString += "<input id='DW_btnRemoveAllImages' onclick='btnRemoveAllImages_onclick()' type='button' value='Remove All Images'/><br /></div>";
    }
    objString += "</div>";

    // The container for the error message
    objString += "<div id='DWTdivMsg' style='width:" + _iWidth + "px;";
    if (_bShowMessagePanel)
        objString += "display:inline'>";
    else
        objString += "display:none'>";
    objString += "Message:<br />"
    objString += "<div id='DWTemessage' style='width:" + _iWidth + "px;height:80px; overflow:scroll; background-color:#ffffff; border:1px #303030; border-style:solid; text-align:left; position:relative' >";
    objString += "</div></div>";

    var DWTemessageContainer = document.getElementById("DWTemessageContainer");
    DWTemessageContainer.innerHTML = objString;

    // Fill the init data for preview mode selection
    var varPreviewMode = document.getElementById("DW_PreviewMode");
    varPreviewMode.options.length = 0;
    varPreviewMode.options.add(new Option("1X1", 0));
    varPreviewMode.options.add(new Option("2X2", 1));
    varPreviewMode.options.add(new Option("3X3", 2));
    varPreviewMode.options.add(new Option("4X4", 3));
    varPreviewMode.options.add(new Option("5X5", 4));
    varPreviewMode.selectedIndex = 0;

    _divMessageContainer = document.getElementById("DWTemessage");
    _divMessageContainer.ondblclick = function() {
        this.innerHTML = "";
        _strTempStr = "";
    }

}

function initDllForChangeImageSize() {

    var vInterpolationMethod = document.getElementById("InterpolationMethod");
    if (vInterpolationMethod) {
        vInterpolationMethod.options.length = 0;
        vInterpolationMethod.options.add(new Option("NearestNeighbor", 1));
        vInterpolationMethod.options.add(new Option("Bilinear", 2));
        vInterpolationMethod.options.add(new Option("Bicubic", 3));
    }

}

function setDefaultValue() {
    if (document.getElementById("Gray"))
        document.getElementById("Gray").checked = true;
    var varImgTypejpeg2 = document.getElementById("imgTypejpeg2");
    if (varImgTypejpeg2)
        varImgTypejpeg2.checked = true;
    var varImgTypejpeg = document.getElementById("imgTypejpeg");
    if (varImgTypejpeg)
        varImgTypejpeg.checked = true;

    _txtFileNameforSave = document.getElementById("txt_fileNameforSave");
    if (_txtFileNameforSave)
        _txtFileNameforSave.value = _strDefaultSaveImageName;

    _txtFileName = document.getElementById("txt_fileName");
    if (_txtFileName)
        _txtFileName.value = _strDefaultSaveImageName;

    _chkMultiPageTIFF_save = document.getElementById("MultiPageTIFF_save");
    if (_chkMultiPageTIFF_save)
        _chkMultiPageTIFF_save.disabled = true;
    _chkMultiPagePDF_save = document.getElementById("MultiPagePDF_save");
    if (_chkMultiPagePDF_save)
        _chkMultiPagePDF_save.disabled = true;
    _chkMultiPageTIFF = document.getElementById("MultiPageTIFF");
    if (_chkMultiPageTIFF)
        _chkMultiPageTIFF.disabled = true;
    _chkMultiPagePDF = document.getElementById("MultiPagePDF");
    if (_chkMultiPagePDF)
        _chkMultiPagePDF.disabled = true;
}



// Check if the control is fully loaded.
var vShowNoControl;
var vNotAllowedForChrome;
var vInvalidForPluginX64;
var vPluginLength = 0;
function controlDetect() {
    var liNoScanner = document.getElementById("pNoScanner");
    // If the ErrorCode is 0, it means everything is fine for the control. It is fully loaded.
    DWObject = gImageCapture.getInstance();
    if (DWObject) {
        if (DWObject.ErrorCode == 0) {
            clearInterval(seed);
            DWObject.MaxImagesInBuffer = 64;     // This is default value. User can change this value later
            DWObject.loglevel = 1;
            DWObject.BrokerProcessType = 1;

            initDllForChangeImageSize();
            setDefaultValue();
            
            re = /^\d+$/;
            strre = /^[\s\w]+$/;
            refloat = /^\d+\.*\d*$/i;

            _iLeft = 0;
            _iTop = 0;
            _iRight = 0;
            _iBottom = 0;   

            if (document.getElementById(_divICSSourceContainerID)) {
                document.getElementById(_divICSSourceContainerID).options.length = 0;
                // If source list need to be displayed, fill in the source items.
                if (_divICSSourceContainerID != "") {
                    if (DWObject.SourceCount == 0) {

                        if (_bInWindows) {
                            liNoScanner.style.display = "block";
                            liNoScanner.style.textAlign = "center";
                        }
                        else
                            liNoScanner.style.display = "none";
                    }
                    for (var i = 0; i < DWObject.SourceCount; i++) {
                        document.getElementById(_divICSSourceContainerID).options.add(new Option(DWObject.GetSourceNameItems(i), i));
                    }

                    if (DWObject.SourceCount > 0) {
                        source_onchange();
                    }
                }

                if (_bInWindows)
                    DWObject.MouseShape = false;

                if (DWObject.SourceCount == 0)
                    document.getElementById("btnScan").disabled = true;
                else {
                    document.getElementById("btnScan").disabled = false;
                    document.getElementById("btnScan").style.color = "#FE8E14";
                }
           
            
            

                for (var i = 0; i < document.links.length; i++) {
                    if (document.links[i].className == "ShowtblLoadImage") {
                        document.links[i].onclick = showtblLoadImage_onclick;
                    }
                    if (document.links[i].className == "ClosetblLoadImage") {
                        document.links[i].onclick = closetblLoadImage_onclick;
                    }
                }
                if (DWObject.SourceCount == 0) {
                    if (_bInWindows) {
                        document.getElementById("aNoScanner").style.color = "Red";
                        document.getElementById("aNoScanner").innerHTML = "<b>" + _strNoDrivers + "<b/>";
                        document.getElementById("Resolution").style.display = "none";
                        if (document.getElementById("div_ScanImage").style.display != "none")
                            showtblLoadImage_onclick();
                    }

                }
                else
                    if (document.getElementById("divBlank"))
                    document.getElementById("divBlank").style.display = "none";

                updatePageInfo();
                ua = (navigator.userAgent.toLowerCase());
                if (!ua.indexOf("msie 6.0")) {
                    ShowSiteTour();
                }
            }
        }
        else {
        
            if (!_bInIE) {
             if (_bInWindowsX86 == false) {
                    if (vInvalidForPluginX64 == false) {
                        invalidForPluginX64();
                        vInvalidForPluginX64 = true;

                        for (var i = 0; i < document.links.length; i++) {
                            if (document.links[i].className == "ClosetblCanNotScan") {
                                document.links[i].onclick = closetblInstall_onclick;
                            }
                        }
                    }

                    return;          
                }
                
                    for (var i = 0; i < navigator.mimeTypes.length; i++) {
                        if (navigator.mimeTypes[i].type.toLowerCase().indexOf("Application/ImageCaptureSuite-Plugin".toLowerCase()) > -1) {
                            if (vNotAllowedForChrome == false) {

                                notAllowedForChrome();
                                vNotAllowedForChrome = true;

                                for (var i = 0; i < document.links.length; i++) {
                                    if (document.links[i].className == "ClosetblCanNotScan") {
                                        document.links[i].onclick = closetblInstall_onclick;
                                    }
                                }
                            }
                            
                        }
                    }
            }

            if (vNotAllowedForChrome == false) {
                if (vShowNoControl == false) {
                    noControl();
                    vShowNoControl = true;

                    for (var i = 0; i < document.links.length; i++) {
                        if (document.links[i].className == "ClosetblCanNotScan") {
                            document.links[i].onclick = closetblInstall_onclick;
                        }
                    }
                }
            }
        }
    }
}

var dlgInstall;
function noControl() {
    ua = (navigator.userAgent.toLowerCase());
    // For mac, create the message to tell the user to install the plugin.
    if (!_bInWindows) {
        createNonInstallDivMac();
        // Display the message and hide the main control
        document.getElementById(_divDWTNonInstallContainerID).style.display = "inline";
        document.getElementById(_divDWTContainerID).style.display = "none";
        document.getElementById("DWTemessageContainer").style.display = "none";
        document.getElementById("ScanWrapper").style.display = "none";

        var logo = S.one('#divLogo');
        if (logo) {
            var vComm100 = S.one('#linkComm100');
            if (vComm100)
                vComm100.appendTo(logo);
        }

        S.use("overlay", function(S, o) {

            dlgInstall = new o.Dialog({
                srcNode: "#J_waiting",
                width: 392,
                height: 277,
                closable: false,
                mask: true,
                align: {
                    points: ['cc', 'cc']
                }
            });
            dlgInstall.show();
        });
    }
    // For other browsers on Windows, create the message to tell the user to install the plugin.
    else if (ua.match(/chrome\/([\d.]+)/) || ua.match(/opera.([\d.]+)/) || ua.match(/version\/([\d.]+).*safari/) || ua.match(/firefox\/([\d.]+)/)) {
        createNonInstallDivPlugin();

        // Display the message and hide the main control
        document.getElementById(_divDWTNonInstallContainerID).style.display = "inline";
        document.getElementById(_divDWTContainerID).style.display = "none";
        document.getElementById("DWTemessageContainer").style.display = "none";
        document.getElementById("ScanWrapper").style.display = "none";

        var divBlankCtrl = document.getElementById("divBlank");
        if (divBlankCtrl)
            divBlankCtrl.style.display = "inline";

        var logo = S.one('#divLogo');
        if (logo) {
            var vComm100 = S.one('#linkComm100');
            if (vComm100)
                vComm100.appendTo(logo);
        }

        S.use("overlay", function(S, o) {

            dlgInstall = new o.Dialog({
                srcNode: "#J_waiting",
                width: 392,
                height: 242,
                closable: false,
                mask: true,
                align: {
                    points: ['cc', 'cc']
                }
            });
            dlgInstall.show();
        });
    }
}


function notAllowedForChrome() {
    ua = (navigator.userAgent.toLowerCase());
    // For mac, create the message to tell the user to install the plugin.
    if (ua.match(/chrome\/([\d.]+)/)) {
        createNonAllowedDivPlugin();
        // Display the message and hide the main control
        document.getElementById(_divDWTNonInstallContainerID).style.display = "inline";
        document.getElementById(_divDWTContainerID).style.display = "none";
        document.getElementById("DWTemessageContainer").style.display = "none";
        document.getElementById("ScanWrapper").style.display = "none";

        var divBlankCtrl = document.getElementById("divBlank");
        if (divBlankCtrl)
            divBlankCtrl.style.display = "inline";

        var logo = S.one('#divLogo');
        if (logo) {
            var vComm100 = S.one('#linkComm100');
            if (vComm100)
                vComm100.appendTo(logo);
        }

        S.use("overlay", function(S, o) {

            dlgInstall = new o.Dialog({
                srcNode: "#J_waiting",
                width: 392,
                height: 227,
                closable: false,
                mask: true,
                align: {
                    points: ['cc', 'cc']
                }
            });
            dlgInstall.show();
        });
    }
}

function invalidForPluginX64() {
    ua = (navigator.userAgent.toLowerCase());
    // For other browsers on Windows, create the message to tell the user to install the plugin.
    if (ua.match(/chrome\/([\d.]+)/) || ua.match(/opera.([\d.]+)/) || ua.match(/version\/([\d.]+).*safari/) || ua.match(/firefox\/([\d.]+)/)) {
        createInvalidForPluginX64();
        // Display the message and hide the main control
        document.getElementById(_divDWTNonInstallContainerID).style.display = "inline";
        document.getElementById(_divDWTContainerID).style.display = "none";
        document.getElementById("DWTemessageContainer").style.display = "none";
        document.getElementById("ScanWrapper").style.display = "none";

        var divBlankCtrl = document.getElementById("divBlank");
        if (divBlankCtrl)
            divBlankCtrl.style.display = "inline";

        var logo = S.one('#divLogo');
        if (logo) {
            var vComm100 = S.one('#linkComm100');
            if (vComm100)
                vComm100.appendTo(logo);
        }

        S.use("overlay", function(S, o) {

            dlgInstall = new o.Dialog({
                srcNode: "#J_waiting",
                width: 412,
                height: 227,
                closable: false,
                mask: true,
                align: {
                    points: ['cc', 'cc']
                }
            });
            dlgInstall.show();
        });
    }
}


function createNonAllowedDivPlugin() {
    var varHref = "";
    if (location.hostname != "")
        varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strMSIPath;
    else
        varHref = _strMSIPath;

    var ObjString = "<div class=\"D-dailog-body-NotAllowed\" style=\"width:350px\">" + _strDynamsoftWithClose + "<div class=\"box_title\">" + _strProductName + " plugin is not allowed to run on this site.</div>"
    ObjString += "<ul>";
    ObjString += "<li>Please click <img  src=\"Images/plug-in blocked.bmp\"/> at the right end of the address bar and click '<b>Always allow plug-ins</b>'. Then refresh/restart the browser.</li>";
    ObjString += "</ul>";
    ObjString += "</div>";
    document.getElementById("InstallBody").innerHTML = ObjString;
}

function createNonInstallDivPlugin() {

    var varHref = "";
    if (location.hostname != "")
        varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strMSIPath;
    else
        varHref = _strMSIPath;

    var ObjString = "<div class=\"D-dailog-body\" style=\"width:350px\">" + _strDynamsoftWithClose + "<div class=\"box_title\">" + _strProductName + " is not installed</div>"
    ObjString += "<ul>";
    ObjString += "<li>Please click the below button to start downloading. You need manually install it after the downloading.</li>";
    ObjString += "</ul>";
    ObjString += "<p class=\"red\">If you still see this dialog after the installation, please RESTART your browser.</p>";
    //ObjString += "<a href='" + varHref + "'><div class=\"button\"></div></a></div>";
    ObjString += "<a id='btnInstall' href='" + varHref + "' onclick='onClickInstallButton()'><div class=\"button\"></div></a>";
    ObjString += "</div>";
    document.getElementById("InstallBody").innerHTML = ObjString;
}

function createInvalidForPluginX64() {

    var varHref = "";
    if (location.hostname != "")
        varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strMSIPath;
    else
        varHref = _strMSIPath;

    var ObjString = "<div class=\"D-dailog-body\" style=\"width:370px; Height:185px;\">" + _strDynamsoftWithClose + "<div class=\"box_title\">64-bit Chrome & Firefox not Supported.</div>"
    ObjString += "<ul>";
    ObjString += "<li>It seems that you are running 64-bit Chrome or Firefox, which is not supported by Dynamsoft ImageCapture Suite, for now...</li>";
    ObjString += "<li>Here is <a href=\"http://kb.dynamsoft.com/questions/865/What+browsers+do+ImageCapture+Suite+support%3F\" target= \"_blank\"><u>a list of browsers supported</u></a>. </li>";
    ObjString += "<li>Or, you can try <a href=\"http://www.dynamsoft.com/demo/DWT/online_demo_scan.aspx\"  target= \"_blank\"><u>Dynamsoft Dynamic Web TWAIN demo</u></a>, which supports 64-bit Chrome & Firefox. ";
    ObjString += "<a href=\"http://www.dynamsoft.com/Products/.Net-TWAIN-Scanner-Product-Comparison.aspx\"  target= \"_blank\"><u>Comparison of ImageCapture Suite and Dynamic Web TWAIN>></u></a> </li>";
    ObjString += "</ul>";
    ObjString += "</div>";
    document.getElementById("InstallBody").innerHTML = ObjString;
}

function onClickInstallButton() {
    document.getElementById("btnInstall").style.display = "none";
    document.getElementById("txtDetect").style.display = "";
    document.getElementById("imgWait").style.display = "";
}

function createNonInstallDivMac() {

    var varHref = "";
    if (location.hostname != "")
        varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strPKGPath;
    else
        varHref = _strPKGPath;

    var ObjString = "<div class=\"D-dailog-body-Mac\" style=\"width:350px\">" + _strDynamsoftWithClose + "<div class=\"box_title\">" + _strProductName + " is not installed</div>"
    ObjString += "<ul>";
    ObjString += "<li>Please click the below button to start downloading. You need manually install it after the downloading.</li>";
    ObjString += "</ul>";
    ObjString += "<p class=\"red\">If you still see this dialog after the installation, please RESTART your browser.</p>";
    ObjString += "If you are using Safari 5.0, you need to <a href='http://kb.dynamsoft.com/questions/666/How+to+run+Safari+5.0+in+32-bit+mode+on+Mac+OS+X'><span class=\"link\">run the browser in 32-bit Mode</span></a>.";
    ObjString += "<a id='btnInstall' href='" + varHref + "' onclick='onClickInstallButton()'><div class=\"button\"></div></a>";
    ObjString += "</div>";
    document.getElementById("InstallBody").innerHTML = ObjString;
}

function closetblInstall_onclick() {
    if (dlgInstall) {
        dlgInstall.hide();
    }
}

function showtblLoadImage_onclick() {
    switch (document.getElementById("tblLoadImage").style.visibility) {
        case "hidden":
            document.getElementById("tblLoadImage").style.visibility = "visible";
            document.getElementById("Resolution").style.visibility = "hidden";
            document.getElementById("MediaType").style.visibility = "hidden";
            document.getElementById("ResolutionWebcam").style.visibility = "hidden";
            break;
        case "visible":
            document.getElementById("tblLoadImage").style.visibility = "hidden";
            document.getElementById("Resolution").style.visibility = "visible";
            document.getElementById("MediaType").style.visibility = "visible";
            document.getElementById("ResolutionWebcam").style.visibility = "visible";
            break;
        default: break;
    }
    document.getElementById("tblLoadImage").style.top = ds_gettop(document.getElementById("pNoScanner")) + pNoScanner.offsetHeight + "px";
    document.getElementById("tblLoadImage").style.left = ds_getleft(document.getElementById("pNoScanner")) + 0 + "px";
    return false;
}
function closetblLoadImage_onclick() {
    document.getElementById("tblLoadImage").style.visibility = "hidden";
    document.getElementById("Resolution").style.visibility = "visible";
    document.getElementById("MediaType").style.visibility = "visible";
    document.getElementById("ResolutionWebcam").style.visibility = "visible";
    return false;
}

function initDefault() {
    ua = (navigator.userAgent.toLowerCase());
    var ObjString = "";
    if (ua.indexOf("macintosh") != -1)
    {
        ObjString = "<ul style='list-style:circle; padding-left:20px'>";
        ObjString += "<li>To test all basic features except image upload, please click <a href='online_demo_scan.aspx' name='starthere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test the PDF Rasterizer features, please click <a href='online_demo_scan_PDFRasterizer.aspx' name='barcodeOCRhere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test all basic features including image upload, please follow the instruction below.</li>";
        ObjString += "</ul>";
    }
    else {
        ObjString = "<ul style='list-style:circle; padding-left:20px'>";
        ObjString += "<li>To test all basic features except image upload, please click <a href='online_demo_scan.aspx' name='starthere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test the barcode features, please click <a href='online_demo_scan_Barcode.aspx' name='barcodeOCRhere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test the OCR features, please click <a href='online_demo_scan_OCR.aspx' name='barcodeOCRhere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test the PDF Rasterizer features, please click <a href='online_demo_scan_PDFRasterizer.aspx' name='barcodeOCRhere'>";
        ObjString += "<span style='color: #0000ff;'><strong>here</strong></span></a>.</li>";
        ObjString += "<li>To test all basic features including image upload, please follow the instruction below.</li>";
        ObjString += "</ul>";
    
    }
    document.getElementById("divInfo").innerHTML = ObjString;
}

//--------------------------------------------------------------------------------------
//************************** Used a lot *****************************
//--------------------------------------------------------------------------------------
function updatePageInfo() {
    document.getElementById("DW_TotalImage").value = DWObject.HowManyImagesInBuffer;
    document.getElementById("DW_CurrentImage").value = DWObject.CurrentImageIndexInBuffer + 1;
}

function appendMessage(strMessage) {
    _strTempStr += strMessage;
    _divMessageContainer.innerHTML = _strTempStr;
    _divMessageContainer.scrollTop = _divMessageContainer.scrollHeight;
}

function checkIfImagesInBuffer() {
    if (DWObject.HowManyImagesInBuffer == 0) {
        appendMessage("There is no image in buffer.<br />")
        return false;
    }
    else
        return true;
}


function checkErrorString() {
    if (DWObject.ErrorCode == 0) {
        appendMessage("<span style='color:#cE5E04'><b>" + DWObject.ErrorString + "</b></span><br />");

        return true;
    }
    if (DWObject.ErrorCode == -2115) //Cancel file dialog
        return true;
    else {
        if (DWObject.ErrorCode == -2003) {
            var ErrorMessageWin = window.open("", "ErrorMessage", "height=500,width=750,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=no,location=no, status=no");
            ErrorMessageWin.document.writeln(DWObject.HTTPPostResponseString);
        }
        appendMessage("<span style='color:#cE5E04'><b>" + DWObject.ErrorString + "</b></span><br />");
        return false;
    }
}

function productUpgrade(type) {
    if (!isDWTVersionLatest(_strVersion)) {
        var strMessage = "A new version of " + _strProductName + " is available.\r \nDo you want to upgrade now?"
        if (type == 1) {
            strMessage = "It seems you are running an old version of " + _strProductName + " which doesn't support generating barcodes. \r \nWould you like to download & install the new version?"
        }
        else if (type == 2) {
            strMessage = "It seems you are running an old version of " + _strProductName + " which doesn't support rasterizing text-based PDF files. \r \nWould you like to download & install the new version?"
        }
        ua = (navigator.userAgent.toLowerCase());
        if (!_bInWindows) {

            if (confirm(strMessage)) {
                var varHref = "";
                if (location.hostname != "")
                    varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strPKGPath;
                else
                    varHref = _strPKGPath;
                window.location = varHref;
            }
            DWObject.style.display = "inline";
        }
        else if (ua.match(/chrome\/([\d.]+)/) || ua.match(/opera.([\d.]+)/) || ua.match(/version\/([\d.]+).*safari/) || ua.match(/firefox\/([\d.]+)/)) {
            if (confirm(strMessage)) {
                var varHref = "";
                if (location.hostname != "")
                    varHref = "http://" + location.host + location.pathname.substring(0, location.pathname.lastIndexOf('/')) + "/" + _strMSIPath;
                else
                    varHref = _strMSIPath;
                window.location = varHref;


            }
            DWObject.style.display = "inline";
        }
    }
}

String.prototype.replaceAll = function(str1, str2) {
    var str = this;
    var result = str.replace(eval("/" + str1 + "/gi"), str2);
    return result;
}

function isDWTVersionLatest(latest) {
    current = DWObject.VersionInfo.toLowerCase().replace(_strProductName.toLowerCase() + " ", "");
    current = current.replace("trial".toLowerCase(), "");
    current = current.replaceAll('[.]', ',');
    latest = latest.replaceAll('[.]', ',');
  
    currentArray = current.split(",");
    latestArray = latest.split(",");

    index = currentArray.length > latestArray.length ? currentArray.length : latestArray.length;
    for (var i = 0; i < index; i++) {
        if (currentArray[i] == null)
            currentArray[i] = 0;
        if (latestArray[i] == null)
            latestArray[i] = 0;

        else if (parseInt(currentArray[i]) < parseInt(latestArray[i])) {
            return false;
        }
    }
    return true;
}

//--------------------------------------------------------------------------------------
//************************** Used a lot *****************************
//--------------------------------------------------------------------------------------
function ds_getleft(el) {
    var tmp = el.offsetLeft;
    el = el.offsetParent
    while (el) {
        tmp += el.offsetLeft;
        el = el.offsetParent;
    }
    return tmp;
}
function ds_gettop(el) {
    var tmp = el.offsetTop;
    el = el.offsetParent
    while (el) {
        tmp += el.offsetTop;
        el = el.offsetParent;
    }
    return tmp;
}

function Over_Out_DemoImage(obj, url) {
    obj.src = url;
}

function initipara() {
    var barcodeContent = document.getElementById("txtBarcodeContent");
    barcodeContent.value = "Dynamsoft";

    var locationX = document.getElementById("txtLocationX");
    locationX.value = "0";

    var locationY = document.getElementById("txtLocationY");
    locationY.value = "0";

    var humanReadableText = document.getElementById("txtHumanReadableText");
    humanReadableText.value = "Dynamsoft";

    var scale = document.getElementById("txtScale");
    scale.value = "1";
}
