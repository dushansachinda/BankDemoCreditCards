import ballerina/http;
import ballerina/io;
import ballerina/time;

string jsonFilePath = "./applications.json";
string requestsFilePath = "../CMS/requests.json";

service /cib on new http:Listener(9091) {
    resource function post creditscore(@http:Payload json request) returns json|error {

        json|io:Error applicationDetails = io:fileReadJson(jsonFilePath);
        json|io:Error requestDetails = io:fileReadJson(requestsFilePath);

        if applicationDetails is json[] {
            string socialSecurityNumberFromRequest = (check request.social_security_number).toString();
            string applicationIdFromRequest = (check request.reference_number).toString();

            foreach var item in applicationDetails {
                if (item is json) {
                    string socialSecurityNumberFromDataSet = (check item.social_security_number).toString();
                    if (socialSecurityNumberFromDataSet == socialSecurityNumberFromRequest) {

                        json additionalProperties = {
                            "request_purpose": (check request.request_purpose).toString(),
                            "timestamp": time:utcToString(time:utcNow()).substring(0, 20)
                                                    };

                        if (requestDetails is json[]) {
                            foreach var req in requestDetails {
                                if (req is json) {
                                    string applicationIdFromRequestDataSet = (check req.application_id).toString();
                                    if (applicationIdFromRequestDataSet == applicationIdFromRequest) {
                                        json creditScoreDetails = {
                                            "credit_score": (check item.credit_score).toString()
                                        };

                                        json|error result = item.mergeJson(additionalProperties);
                                        json|error mergedRequest = req.mergeJson(creditScoreDetails);

                                        check io:fileWriteJson(requestsFilePath, requestDetails);
                                        return result;
                                    }
                                }
                            }
                            return error("Invalid reference number");
                        } else {
                            return error("Invalid data");
                        }
                    }
                }
            }
        }

        return error("Invalid Social Security Number");
    }
}
