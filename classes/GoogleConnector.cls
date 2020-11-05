public class GoogleConnector {
    @AuraEnabled
    public String code { get; set; }
    
    public PageReference authorizeNamedCredential(String authProvider, String namedCredential)
{
    AuthProvider provider = [
        SELECT Id
        FROM AuthProvider
        WHERE DeveloperName = 'Google_Connect'
    ];

    NamedCredential credential = [
        SELECT Id
        FROM NamedCredential
        WHERE DeveloperName = 'GoogleAPI'
    ];

    String oid = UserInfo.getOrganizationId();
    String domain = Url.getOrgDomainUrl().toExternalForm();
    String path = '/services/auth/xds/' + oid + '/' + authProvider;
    String startUrl = '/' + String.valueOf(credential.Id).left(15);

    PageReference redirect = new PageReference(domain + path);
    redirect.getParameters().put('startURL', startUrl);
    redirect.getParameters().put('scope', 'full refresh_token');
    return redirect;
}

}