public class BP_OffersCustomers {
    @AuraEnabled
    public static List<OpportunityLineItem> getAccountOffers(Id idcliente) {
        list<OpportunityLineItem> ofertas  = [SELECT Id,Name,OpportunityId,Opportunity.Name,Opportunity.Description,Opportunity.Amount,Opportunity.BP_Priority__c,
                                             tolabel(Opportunity.BP_Channel__c),Opportunity.BP_ShowCarousel__c,Opportunity.BP_Deadline__c,Opportunity.BP_Rwarranty__c,Opportunity.BP_Campaign__c,product2.Name,product2.BP_ImageUrl__c,Opportunity.Campaign.Name 
                                             FROM OpportunityLineItem WHERE OpportunityId in (Select Id from opportunity where accountId=:idcliente and stagename='Contacto' and RecordType.developerName='BP_Oferta') and Opportunity.CloseDate >= TODAY
                                             order by Opportunity.BP_Priority__c,Opportunity.Closedate asc];
       return ofertas;
    }
    @AuraEnabled
    public static List<OpportunityLineItem> getproductoferta(Id oportunidad) {
       list<OpportunityLineItem> oferta  = [SELECT Id,Name,OpportunityId,Opportunity.Name,Opportunity.StageName,
                                             product2.Name, product2.BP_LinkProduct__c, product2.BP_LinkGeneralOffer__c, Opportunity.recordType.Name
                                             FROM OpportunityLineItem WHERE OpportunityId=:oportunidad limit 1];
       return oferta;
    }
    @AuraEnabled
    public static string ReagendarOferta(Id OId, String newDate, String newComm) {
        Date d = Date.valueOf(newDate);
        list<user>userlog=[select id from user where id=:UserInfo.getUserId()];
        list<Opportunity>oferta=[select id,closedate,description,stagename,accountid from Opportunity where id=:OId];
        oferta[0].closedate=d;
        update oferta;
        Id RecordTypeIdEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Visitas').getRecordTypeId();   
        Event nuevoevento = new Event(
            RecordTypeId=RecordTypeIdEvent,OwnerId = userlog[0].Id,WhatId = oferta[0].accountid,BP_Opportunity__c=OId,
            StartDateTime = d+1, EndDateTime = d+1, ActivityDateTime = d+1,Subject = 'Visita/Llamada',
            Description=newComm
         );
        insert nuevoevento; 
        return 'exito';
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> RechazarOportunidad(Id OId, string Comment,string motrechazo) {
        list<Opportunity>oferta=[select id,closedate,BP_RejectionComment__c,BP_RejectionMotive__c,stagename,accountid from Opportunity where id=:OId];
        oferta[0].closedate=system.today();
        oferta[0].BP_RejectionComment__c=Comment;
        oferta[0].stagename='Cerrado Perdido';
        oferta[0].BP_RejectionMotive__c=motrechazo;
        update oferta; 
        return [SELECT Id,Name,OpportunityId,Opportunity.Name,Opportunity.Description,product2.Name,product2.BP_ImageUrl__c 
                                             FROM OpportunityLineItem 
                WHERE OpportunityId in (Select Id from opportunity where accountId=:oferta[0].accountid and stagename='Contacto')];
    }
    @AuraEnabled
    public static string AceptarOportunidad(Id OId) {
        list<Opportunity>oferta=[select id,closedate,BP_RejectionComment__c,stagename,accountid from Opportunity where id=:OId];
        oferta[0].closedate=system.today();
        oferta[0].stagename='Instrumentacion';
        update oferta; 
        return 'exito';
    }
    @AuraEnabled        
    public static List<String> getPickListMotivoRechazo(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Opportunity');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('BP_RejectionMotive__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
}
}