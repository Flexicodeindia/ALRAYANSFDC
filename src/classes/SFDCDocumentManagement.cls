/* --------------------------------------------------------------------------------------- */
/* C0530    New web service for Document Management Cases                                 */
/* --------------------------------------------------------------------------------------- */

global class SFDCDocumentManagement
{

    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static string DocumentManagementCase ( string inRequest)
    {
        string decodedRequest;
        XmlStreamReader xsr;
        DocumentManagementCase theDocumentCase = new DocumentManagementCase();
        DocumentManagementCaseResponse theResponse = new DocumentManagementCaseResponse();
        
        try
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
        }
        catch (Exception ex1)
        {
            theResponse.ResponseCode = 'FAILED';
            theResponse.ResponseMsg = 'Problem decoding request ' + ex1.GetMessage() ;
        }
 
        
        if (String.IsBlank(theResponse.ResponseCode))
        {
            try
            {
                xsr = new XmlStreamReader (decodedRequest);
                while (xsr.HasNext())
                {
                 if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        if ('MessageID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.MessageID = xsr.getText();
                            }
                        }
                        else if ('MessageType'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.MessageType = xsr.getText();
                            }
                        }
                        else if ('ReplicationType'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ReplicationType = xsr.getText();
                            }
                        }
                        else if ('CustNo'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CustNo = xsr.getText();
                            }
                        }
                        else if ('CaseDirectorCode'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseDirectorCode = xsr.getText();
                            }
                        }
                        else if ('CaseDescription'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseDescription = xsr.getText();
                            }
                        }
                        else if ('CaseSubject'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseSubject = xsr.getText();
                            }
                        }
                        else if ('CaseUser'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseUser = xsr.getText();
                            }
                        }
                        else if ('CaseStatus'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseStatus = xsr.getText();
                            }
                        }
                        else if ('CaseQueue'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseQueue = xsr.getText();
                            }
                        }
                        else if ('DocumentDefinitionName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentDefinitionName = xsr.getText();
                            }
                        }
                        else if ('DocumentName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentName = xsr.getText();
                            }
                        }
                        else if ('DocumentUDI'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentUDI = xsr.getText();
                            }
                        }
                        else if ('ProcessStatus '.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ProcessStatus  = xsr.getText();
                            }
                        }
                        else if ('CustomerNumber'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CustomerNumber = xsr.getText();
                            }
                        }
                        else if ('AccountNumber'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.AccountNumber = xsr.getText();
                            }
                        }
                        else if ('Branch'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.Branch = xsr.getText();
                            }
                        }
                        else if ('FirstName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.FirstName = xsr.getText();
                            }
                        }
                        else if ('LastName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.LastName = xsr.getText();
                            }
                        }
                        else if ('PostCode'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.PostCode = xsr.getText();
                            }
                        }
                        else if ('DocumentReference'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentReference = xsr.getText();
                            }
                        }
                        else if ('CompletionDate'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CompletionDate = xsr.getText();
                            }
                        }
                        else if ('DocumentDate'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentDate = xsr.getText();
                            }
                        }
                        
                        else if ('DocumentTime'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentTime = xsr.getText();
                            }
                        }
                        
                        else if ('ActionStatus'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ActionStatus  = xsr.getText();
                            }
                        }
                        
                        else if ('WorkLocation'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.WorkLocation  = xsr.getText();
                            }
                        }
                     }
                    xsr.next();
                }
            }
            catch (Exception e)
            {
                theResponse.ResponseCode = 'FAILED';
                theResponse.ResponseMsg = theResponse.ResponseMsg + ' - ' + e.getMessage();
            }
            
            CaseDirector caseDir = new CaseDirector();
            List<CaseDirector.ExternalCase> cases = new List<CaseDirector.ExternalCase>();
            CaseDirector.ExternalCase extCase = new CaseDirector.ExternalCase();
            caseDir.dmc = theDocumentCase;
            extCase.ExternalCaseReferenceID = theDocumentCase.MessageID;
            extCase.EBSCustomerID = theDocumentCase.CustNo;
            extCase.CaseDirectorCode = theDocumentCase.CaseDirectorCode;
            extCase.CaseDirectorDescription = theDocumentCase.CaseDescription;
            extCase.CaseDirectorSubject = theDocumentCase.CaseSubject;
            extCase.EBSUserID = '000';
            extCase.CaseDirectorPriority = theDocumentCase.CasePriority;
            extCase.CaseDirectorStatus = theDocumentCase.CaseStatus;
            extCase.CaseDirectorQueue = theDocumentCase.CaseQueue;
            
            cases.add(extCase);
            caseDir.ExternalCases = cases;
            caseDir.CreateExternalCases();
            
            for(CaseDirector.ExternalCaseResponse resp : caseDir.ExternalCaseResponses)
            {
                theResponse.messageID = resp.CaseMessageID;
                theResponse.DocumentUDI = theDocumentCase.DocumentUDI;
                theResponse.ResponseCode = resp.CaseInsertResult;
                theResponse.ResponseMsg = resp.CaseInsertResultMessage;
            }
        }
        return ResponseMessage(theResponse);
    }

    public static string ResponseMessage (DocumentManagementCaseResponse resp)
    {
        string rtv = '';
        
        rtv = '<DMCaseResponse>';
        rtv = rtv + '<MessageID>' + resp.messageId + '</MessageID>';
        rtv = rtv + '<DocumentUDI>' + resp.DocumentUDI + '</DocumentUDI>';
        rtv = rtv + '<ResponseCode>' + resp.ResponseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + resp.ResponseMsg + '</ResponseMsg>';
        rtv = rtv + '</DMCaseResponse>';
        
        return rtv;
    }

}