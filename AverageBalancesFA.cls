public without sharing class AverageBalancesFA {
    @AuraEnabled
    public static FinServ__FinancialAccount__c activarConsultaSP(Id CuentaFin) {
       FinServ__FinancialAccount__c cuentafinan = [select id,FinServ__FinancialAccountNumber__c,FinServ__AverageBalance__c,FinServ__PrincipalBalance__c,BP_SPLastCallbackEstatus__c,
                                                        BP_MessageSP__c from FinServ__FinancialAccount__c where id=:CuentaFin];       
         cuentafinan.BP_SPLastCallbackEstatus__c = 'EN PROCESO';
         update cuentafinan;    
         AverageBalancesFA.ConsultarSaldoPromedios(cuentafinan.Id);
        return cuentafinan;
    }
    @AuraEnabled
    public static FinServ__FinancialAccount__c GetSaldosActualizados(Id CuentaFin) {
        FinServ__FinancialAccount__c cuentafinan = [select id,FinServ__FinancialAccountNumber__c,FinServ__AverageBalance__c,FinServ__PrincipalBalance__c,BP_SPLastCallbackEstatus__c,
                                                        BP_MessageSP__c from FinServ__FinancialAccount__c where id=:CuentaFin];
        return cuentafinan;
    }
    
    @Future(callout=true)
    public static void ConsultarSaldoPromedios(Id CuentaFin) {
            FinServ__FinancialAccount__c cuentafinan = [select id,FinServ__FinancialAccountNumber__c,FinServ__AverageBalance__c,FinServ__PrincipalBalance__c,BP_SPLastCallbackEstatus__c,
                                                        BP_MessageSP__c from FinServ__FinancialAccount__c where id=:CuentaFin]; 
           
            list<user> validuser=[select id,alias,UsuarioRed__c,BP_CodeAgency__c from user where id=:UserInfo.getUserId()];
            list<LoginHistory>loghis=[Select Id,UserId,LoginTime,LoginType,SourceIp,LoginUrl,AuthenticationServiceId,
                                      LoginGeoId,Browser,Platform,Status,Application,ClientVersion,ApiType,ApiVersion 
                                      from LoginHistory where UserId=:validuser[0].id order by LoginTime desc limit 1];
            list<LoginGeo>geolog=[SELECT Latitude ,Longitude FROM LoginGeo WHERE Id =:loghis[0].LoginGeoId]; 
            Datetime fechahoy = Datetime.now();
            String fecheenviar = fechahoy.format('yyyyMMddHHmmssSSSS');
            JsonInputSaldosPromedio jsonsend = new JsonInputSaldosPromedio();
            JsonInputSaldosPromedio.Header cab = new JsonInputSaldosPromedio.Header();
    
            string sesion = 'MjUxMjdDRjkxODY3MjhFMDU5Rjk0OTMwRA==';
        string empresa = '0010';
        string idioma = 'es-EC';
        string usuario = validuser[0].UsuarioRed__c;
		string geolocalizacion =  geolog[0].Latitude+' '+geolog[0].Longitude;
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getCookies().containsKey('sesion') && ApexPages.currentPage().getCookies().get('sesion')!= null){
            sesion = ApexPages.currentPage().getCookies().get('sesion').getValue();
        }
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getCookies().containsKey('empresa') && ApexPages.currentPage().getCookies().get('empresa')!= null){
            empresa = ApexPages.currentPage().getCookies().get('empresa').getValue();
        }
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getCookies().containsKey('idioma') && ApexPages.currentPage().getCookies().get('idioma')!= null){
            idioma = ApexPages.currentPage().getCookies().get('idioma').getValue();
        }
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getCookies().containsKey('usuario') && ApexPages.currentPage().getCookies().get('usuario')!= null){
            usuario = ApexPages.currentPage().getCookies().get('usuario').getValue();
        }
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getCookies().containsKey('geolocalizacion') && ApexPages.currentPage().getCookies().get('geolocalizacion')!= null){
            geolocalizacion = ApexPages.currentPage().getCookies().get('geolocalizacion').getValue();
        }
        cab.dispositivo=loghis[0].Browser.leftPad(32,'0'); 												//Rellenar a 32 caracteres con 0
        cab.empresa=empresa;																			//Si ws02 enviar valor, si no 0010
        cab.canal=BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_Channel__c; 			//Solicitar Canal de Todos los servicios
        cab.medio=BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_Way__c; 				//Solicitar medio de todos los servicios
        cab.aplicacion=BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_Application__c; 	//Solicitar aplicación de todos los servicios
        cab.agencia=validuser[0].BP_CodeAgency__c; 														//Codigo de Agencia en Usuario
        cab.geolocalizacion=geolocalizacion; 															//Colocar valor de Wso2, sino, como estaba
        cab.usuario=usuario; 																			//Colocar valor de WSO2, si no, User.usuarioRed__c
        cab.unicidad=wsBlockOfferCallout.generateRandomString(70);										//Hash random 70 caracteres
        cab.guid=GuidUtil.NewGuid().replace('-',''); 													//Guid standard removiendo los separadores
        cab.fechaHora=fecheenviar; 																		//Formato cambiado yyyyMMddHHmmssSSSS
        cab.idioma=idioma; 																				//Colocar valor de WSo2, si no, defecto es-EC
        cab.sesion=sesion; 																				//Colocar valor de WS02, si no, mandar valor fijo
        cab.ip=loghis[0].SourceIp;
        
           JsonInputSaldosPromedio.Body cuerpo = new JsonInputSaldosPromedio.Body();
           cuerpo.numeroCuenta=cuentafinan.FinServ__FinancialAccountNumber__c;
           cuerpo.opcion=BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_Option__c;
        
          jsonsend.header = cab;
          jsonsend.body=cuerpo;
           try{ 
            HttpRequest req = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http h = new Http();
            req.setEndpoint(BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_URL__c);
            req.setMethod('POST');
            req.setTimeout(120000);        
            String username = BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_User__c;
            String password = BP_EndpointsConfiguration_List__c.getValues('BP_SaldoP').BP_Password__c; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);       
            req.setHeader('Authorization', authorizationHeader);            
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(jsonsend));
            response = h.send(req);
            if (response.getStatusCode() == 200) {
             JsonOutPutSaldoP respuesta = JsonOutPutSaldoP.parse(response.getBody());
              if(respuesta.codError=='0'){ 
                  double saldoPromedioMensual=(double.valueof(respuesta.Body.saldosCuenta.saldoPromedioPrimerSemestre)+double.valueof(respuesta.Body.saldosCuenta.saldoPromedioSegundoSemestre))/12;
                  double saldoPromedioSemestral=(double.valueof(respuesta.Body.saldosCuenta.saldoPromedioPrimerSemestre)+double.valueof(respuesta.Body.saldosCuenta.saldoPromedioSegundoSemestre))/2;
                  cuentafinan.FinServ__AverageBalance__c=saldoPromedioMensual;//saldo promedio mensual
                  cuentafinan.FinServ__PrincipalBalance__c=saldoPromedioSemestral;//saldo promedio semestral
                  cuentafinan.BP_SPLastCallbackEstatus__c='EXITOSO';
                  cuentafinan.BP_MessageSP__c=respuesta.msjNegocio;
                  update cuentafinan;
              }
                else{ 
                   cuentafinan.BP_SPLastCallbackEstatus__c='ERROR'; cuentafinan.BP_MessageSP__c=respuesta.msjNegocio;  update cuentafinan; 
                }
            }
              else{ 
                cuentafinan.BP_SPLastCallbackEstatus__c='ERROR'; 
                cuentafinan.BP_MessageSP__c= response.getStatusCode() + ' ' + response.getStatus(); 
                update cuentafinan;  
              }    
           }catch(System.CalloutException e) 
            {    
             cuentafinan.BP_SPLastCallbackEstatus__c='ERROR';  cuentafinan.BP_MessageSP__c= e.getMessage(); update cuentafinan;     
           }    
        
    }
}