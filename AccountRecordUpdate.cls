public without sharing class  AccountRecordUpdate {
    @AuraEnabled
    public static string ejecutarUpdateAccount(string PersonHomePhone,string PersonMobilePhone,
                                              string PersonOtherPhone,string BP_ShippingLocation,string BP_ShippingStreet01,
                                              string BP_ShippingStreet02,string BP_ShippingReference,string BP_BillingLocation,
                                              string BP_BillingStreet01,string BP_BillingStreet02,string BP_BillingReference,
                                              string BP_MaritalStatus,string BP_PersonEmail,string BP_LevelStudy,string BP_PersonTitle,string CurrentEmployer,
                                              string BP_JobTitle,string BP_Occupation,string BP_EconomicActivity,string CustomerID,string BP_IDType,
                                              string BP_OccupationDetails,string NumberOfChildren,string NumberOfDependents, string IDCliente){
        
        string respuesta;
                                                  system.debug('nivel de estudio'+BP_LevelStudy);
        list<user> validuser=[select id,alias,UsuarioRed__c,BP_CodeAgency__c from user where id=:UserInfo.getUserId()];
        list<LoginHistory>loghis=[Select Id,UserId,LoginTime,LoginType,SourceIp,LoginUrl,AuthenticationServiceId,LoginGeoId,Browser,
                               Platform,Status,Application,ClientVersion,ApiType,ApiVersion from LoginHistory 
                               where UserId=:validuser[0].id order by LoginTime desc limit 1];
        list<LoginGeo>geolog=[SELECT Latitude ,Longitude FROM LoginGeo WHERE Id =:loghis[0].LoginGeoId]; 
        Datetime fechahoy = Datetime.now();
        String fecheenviar = fechahoy.format('yyyyMMddHHmmssSSSS');  
        BP_JsonAccoutUpdate jsonsend = new BP_JsonAccoutUpdate();
        BP_JsonAccoutUpdate.Header cab = new BP_JsonAccoutUpdate.Header();
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
        cab.canal=BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_Channel__c; 			//Solicitar Canal de Todos los servicios
        cab.medio=BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_Way__c; 				//Solicitar medio de todos los servicios
        cab.aplicacion=BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_Application__c; 	//Solicitar aplicación de todos los servicios
        cab.agencia=validuser[0].BP_CodeAgency__c; 														//Codigo de Agencia en Usuario
        cab.geolocalizacion=geolocalizacion; 															//Colocar valor de Wso2, sino, como estaba
        cab.usuario=usuario; 																			//Colocar valor de WSO2, si no, User.usuarioRed__c
        cab.unicidad=wsBlockOfferCallout.generateRandomString(70);										//Hash random 70 caracteres
        cab.guid=GuidUtil.NewGuid().replace('-',''); 													//Guid standard removiendo los separadores
        cab.fechaHora=fecheenviar; 																		//Formato cambiado yyyyMMddHHmmssSSSS
        cab.idioma=idioma; 																				//Colocar valor de WSo2, si no, defecto es-EC
        cab.sesion=sesion; 																				//Colocar valor de WS02, si no, mandar valor fijo
        cab.ip=loghis[0].SourceIp;
            
            BP_JsonAccoutUpdate.Telefonos telefonos = new BP_JsonAccoutUpdate.Telefonos();
            telefonos.domicilio=PersonHomePhone !=null ? PersonHomePhone : '';
            telefonos.celular=PersonMobilePhone !=null ? PersonMobilePhone : '';
            telefonos.trabajo=PersonOtherPhone  !=null ? PersonOtherPhone : '';
            //direccion domicilio
            BP_JsonAccoutUpdate.Direccion dirdom = new BP_JsonAccoutUpdate.Direccion();
           if(BP_ShippingLocation!=null){
            BP_AddressCatalog__c codigosdom = AccountRecordUpdate.getcodigos(BP_ShippingLocation);          
            dirdom.pais=codigosdom.BP_CountryCode__c !=null ? codigosdom.BP_CountryCode__c : '';
            dirdom.provincia=codigosdom.BP_ProvinceCode__c !=null ? codigosdom.BP_ProvinceCode__c : '';
            dirdom.ciudad=codigosdom.BP_CityCode__c !=null ? codigosdom.BP_CityCode__c.substringAfter('-') : '';
            dirdom.canton=codigosdom.BP_CantonCode__c !=null ? codigosdom.BP_CantonCode__c : '';
            dirdom.parroquia=codigosdom.BP_ParishCode__c !=null ? codigosdom.BP_ParishCode__c : '';
          }                                      
            dirdom.callePrincipal=BP_ShippingStreet01 !=null ? BP_ShippingStreet01 : '';
            dirdom.calleSecundaria=BP_ShippingStreet02 !=null ? BP_ShippingStreet02 : '';
            dirdom.referencias=BP_ShippingReference !=null ? BP_ShippingReference  : '';
            
           //direccion trabajo
           BP_JsonAccoutUpdate.Direccion dirtra = new BP_JsonAccoutUpdate.Direccion();
           if(BP_BillingLocation!=null){
            BP_AddressCatalog__c codigostrab = AccountRecordUpdate.getcodigos(BP_BillingLocation);  
            dirtra.pais=codigostrab.BP_CountryCode__c !=null ? codigostrab.BP_CountryCode__c : '';
            dirtra.provincia=codigostrab.BP_ProvinceCode__c !=null ? codigostrab.BP_ProvinceCode__c : '';
            dirtra.ciudad=codigostrab.BP_CityCode__c !=null ? codigostrab.BP_CityCode__c.substringAfter('-') : '';
            dirtra.canton=codigostrab.BP_CantonCode__c !=null ? codigostrab.BP_CantonCode__c : '';
            dirtra.parroquia=codigostrab.BP_ParishCode__c !=null ? codigostrab.BP_ParishCode__c : '';
           }                                                    
           dirtra.callePrincipal=BP_BillingStreet01 !=null ? BP_BillingStreet01 : '';
           dirtra.calleSecundaria=BP_BillingStreet02 !=null ? BP_BillingStreet02 : '';
           dirtra.referencias=BP_BillingReference !=null ? BP_BillingReference : '';
           
           //body
            BP_JsonAccoutUpdate.Body cuerpo = new BP_JsonAccoutUpdate.Body();
            cuerpo.tipoIdentificacion=BP_IDType;
            cuerpo.identificacion=CustomerID;
            cuerpo.estadoCivil=BP_MaritalStatus !=null ? BP_MaritalStatus : '';
            cuerpo.email=BP_PersonEmail !=null ? BP_PersonEmail  : '';
            cuerpo.telefonos = telefonos;
            cuerpo.direccionDomicilio =dirdom;
            cuerpo.direccionTrabajo=dirtra;
            cuerpo.nivelEstudios=BP_LevelStudy !=null ? BP_LevelStudy: '';                                      
            cuerpo.profesion=BP_PersonTitle !=null ? BP_PersonTitle: '';
            cuerpo.lugarTrabajo=CurrentEmployer !=null ? CurrentEmployer : '';
            cuerpo.cargo=BP_JobTitle !=null ? BP_JobTitle : '';                                       
            
           if(BP_Occupation!='3'){
              BP_JsonAccoutUpdate.SituacionLaboral situacion1 = new BP_JsonAccoutUpdate.SituacionLaboral();
              BP_JsonAccoutUpdate.SituacionLaboral situacion2 = new BP_JsonAccoutUpdate.SituacionLaboral();
              if(BP_Occupation=='0'){
               situacion1.situacionLaboral=BP_Occupation;   
               situacion1.actividadEconomicaPrincipal=BP_EconomicActivity;
               situacion2.situacionLaboral='';
               situacion2.actividadEconomicaPrincipal='';
              }
              if(BP_Occupation=='1'){
               situacion1.situacionLaboral='';   
               situacion1.actividadEconomicaPrincipal=''; 
               situacion2.situacionLaboral=BP_Occupation; 
               situacion2.actividadEconomicaPrincipal=BP_EconomicActivity;  
              }
              if(BP_Occupation=='2'){
               situacion1.situacionLaboral='0';
               situacion1.actividadEconomicaPrincipal=BP_EconomicActivity; 
               situacion2.situacionLaboral='1'; 
               situacion2.actividadEconomicaPrincipal=BP_EconomicActivity;    
                  
              }
            list<BP_JsonAccoutUpdate.SituacionLaboral>listasitlab= new list<BP_JsonAccoutUpdate.SituacionLaboral>();
            listasitlab.add(situacion1);
            listasitlab.add(situacion2);  
            cuerpo.situacionLaboral=listasitlab;
            BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja listasitlabnotrabvacia = new BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja();         
            cuerpo.situacionLaboralNoTrabaja=listasitlabnotrabvacia;  
          }
          if(BP_Occupation=='3'){
            BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja situacionlabnotrab = new BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja();
            BP_JsonAccoutUpdate.SituacionLaboralDetalle sitnotdet = new BP_JsonAccoutUpdate.SituacionLaboralDetalle();
            sitnotdet.situacionLaboral='';
            sitnotdet.detalle=BP_OccupationDetails !=null ? BP_OccupationDetails : '';
            situacionlabnotrab.situacionLaboralDetalle = sitnotdet;
            BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja notrabaja = new BP_JsonAccoutUpdate.SituacionLaboralNoTrabaja();
            notrabaja=situacionlabnotrab;
            cuerpo.situacionLaboralNoTrabaja=notrabaja;
            list<BP_JsonAccoutUpdate.SituacionLaboral>listatrabajavacia= new list<BP_JsonAccoutUpdate.SituacionLaboral>();  
            cuerpo.situacionLaboral=listatrabajavacia;  
          }
            cuerpo.numHijos=NumberOfChildren !=null ? string.valueof(NumberOfChildren): '';
            cuerpo.numCargas=NumberOfDependents !=null ? string.valueof(NumberOfDependents): '';
           
            //json completo                                      
            jsonsend.header = cab;
            jsonsend.body=cuerpo;                                        
            //llamada al servicio  
          try{         
            HttpRequest req = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http h = new Http();
           //req.setEndpoint('https://ServiciosExternosTest.pichincha.com:8081/dp/wrapper/WSAP0010001/M001');
            req.setEndpoint(BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_URL__c);    
            req.setMethod('POST');
            req.setTimeout(120000);        
            String username = BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_User__c;
            String password = BP_EndpointsConfiguration_List__c.getValues('BP_UpdateCustomer').BP_Password__c;  
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);       
            req.setHeader('Authorization', authorizationHeader);            
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(jsonsend));
            system.debug('json enviado'+JSON.serialize(jsonsend));
            response = h.send(req);
            system.debug(response.getBody()); 
          string codigorespuesta;
          string mensajeservicio;    
          if (response.getStatusCode() == 200) {
               System.debug(response.getBody());
               JSONParser parser = JSON.createParser(response.getBody());           
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'codError')) { 
                         parser.nextToken();    
                         codigorespuesta= parser.getText(); 
                        }
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'descError')) {
                         parser.nextToken();  
                        mensajeservicio= parser.getText(); }
                    }   
            } else {
               System.debug('The status code returned was not expected: ' +
               response.getStatusCode() + ' ' + response.getStatus());  
            }
          respuesta = JSON.serialize(new Map<String,Object> {
           'codError' => codigorespuesta,
           'MensajeError' => mensajeservicio
           });    
          }catch(System.CalloutException e) 
            {    
             System.debug('A ocurrido un error en el webservice: ' + e.getMessage());
             respuesta = JSON.serialize(new Map<String,Object> {
               'codError' => '1',
               'MensajeError' => e.getMessage()
               });
           }
        return respuesta;
    }
    public static BP_AddressCatalog__c getcodigos(Id catalogoid){
        BP_AddressCatalog__c catalogo =[select id,BP_CountryCode__c,BP_ProvinceCode__c,BP_CityCode__c,
                                        BP_CantonCode__c,BP_ParishCode__c from BP_AddressCatalog__c where id=:catalogoid];
        return catalogo;
    }
}