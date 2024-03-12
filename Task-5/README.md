
# Table of Contents

1.  [Local installation](#org032dfee)
    1.  [Building FC service](#org094c561)
    2.  [Example for testing self description locally:](#orgc44d832)
    3.  [Further examples](#org4f84169)


<a id="org032dfee"></a>

# Local installation


<a id="org094c561"></a>

## Building FC service

-   Follow the instruction to build fc-service locally from here [link](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/blob/main/docker/README.md#build-test-procedure)
    -   Note:
        -   Please use the following credentials when creating the new account in the keyclock in order to follow along the examples later on.
            
            > Username: test-user
            > Password: Test@123
        
        -   Configure the keyclock
            -   make sure email is verified for new user
            -   copy the `client-secret` because it will be used for creating `ACCESS_TOKEN` later on.
        
        -   Here are some information of services running on different ports:
            
            <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
            
            
            <colgroup>
            <col  class="org-left" />
            
            <col  class="org-right" />
            </colgroup>
            <thead>
            <tr>
            <th scope="col" class="org-left">Services</th>
            <th scope="col" class="org-right">Port</th>
            </tr>
            </thead>
            
            <tbody>
            <tr>
            <td class="org-left">keyserver/keyclock</td>
            <td class="org-right">8080</td>
            </tr>
            
            
            <tr>
            <td class="org-left">demo portal</td>
            <td class="org-right">8088</td>
            </tr>
            
            
            <tr>
            <td class="org-left">catalog</td>
            <td class="org-right">8081</td>
            </tr>
            </tbody>
            </table>
        
        -   Upload the postman script with localhost and link to the examples of TechWorkshop in the end.


<a id="orgc44d832"></a>

## Example for testing self description locally:

1.  Find the demo VC in directory `tools/signer` or can be generated from directory `tools/sd-generator`
2.  Check if following is present in the SD&rsquo;s `@context` for VC/VP credentials: `https://w3id.org/security/suites/jws-2020/v1`
    
        "@context": [
            "https://www.w3.org/2018/credentials/v1", "https://w3id.org/security/suites/jws-2020/v1"
3.  Now go to the signer directory and check if keys are present in `/home/rkumar/project/fc/fc-service/fc-tools/signer/src/main/resources` folder. If not present then generate it using following command:
    
        openssl req -x509 -newkey rsa:4096 -keyout prk.ss.pem -out cert.ss.pem -sha256 -days 365 -nodes
    
    After that you need to build the project again with these new keys.
4.  Sign the VC:
    
        java -jar fc-tools-signer-<project.version>-full.jar <path_to_original_SD_file> <path_to_signed_SD_file>
    
    -   Note: original SD should be in `jsonld` format.

5.  Verification
    1.  Generate the `Token`
        
            ACCESS_TOKEN=$(
                curl -s \
                    -d "client_id=federated-catalogue" \
                    -d "client_secret=x5Xvpu3VU0SQRMPfe9puwMKD8NhrHGwX" \
                    -d "username=test-user" \
                    -d "password=Test@123" \
                    -d "grant_type=password" \
                    "http://key-server:8080/realms/gaia-x/protocol/openid-connect/token" | jq '.access_token' | tr -d '"'
                        )
            echo $ACCESS_TOKEN
        
        -   Note: *client-secret , Username, password* are only require attention.
    
    2.  Verification of SD
        
            curl --location 'http://localhost:8081/verification?verifySemantics=true&verifySchema=true&verifySignatures=true' \
                --header 'accept: application/json' \
                --header 'Content-Type: application/json' \
                --header 'Authorization: Bearer $ACCESS_TOKEN' \
                --data '@<full_path_to_the_signed_VC.json>'
        
        if the result is successful then it is verified.

6.  Uploading the signed SD to catalog:
    1.  Post request to catalog by a uploading the signed<sub>VC.json</sub> file
        
            curl --location 'http://localhost:8081/self-descriptions' \
                --header 'accept: application/json' \
                --header 'Content-Type: application/json' \
                --header 'Authorization: Bearer $ACCESS_TOKEN' \
                --data '@<full_path_to_the_signed_VC.json>'
    
    2.  Verifying the SD is uploaded
        
            curl --location 'http://localhost:8081/self-descriptions?statuses=REVOKED%2CACTIVE%2CDEPRECATED' \
                --header 'accept: application/json' \
                --header 'Authorization: Bearer $ACCESS_TOKEN' \
                --data ''


<a id="org4f84169"></a>

## Further examples

-   There are more examples and detail instructions given in workshop here link:[workshop](https://gitlab.eclipse.org/eclipse/xfsc/cat/fc-service/-/tree/main/examples/TechWorkshop?ref_type=heads)
-   Please find the postman&rsquo;s API request script for local version in this repository under folder `/resources` . It has been adapted for the local version for the same workshop mentioned above.
