import ballerina/http;
import ballerina/io;
import ballerina/random;

const string jsonFilePath = "./requests.json";

service /cms on new http:Listener(9090) {
    resource function post creditcardrequest_application(@http:Payload json request) returns json|error {
        json|io:Error applicationRequests = io:fileReadJson(jsonFilePath);

        int application_id = check random:createIntInRange(10000, 1000000);

        json additionalProperties = {
            "application_id": application_id.toString(),
            "status": "inapproval",
            "message": "Credit card request is currently being processed for approval"
        };

        json|error response = additionalProperties.mergeJson(request);

        if applicationRequests is json[] {
            applicationRequests.push((check response).toJson());
            json _ = check io:fileWriteJson(jsonFilePath, applicationRequests);
        }

        return response;
    }

    // Get Status function
    resource function get creditcardrequest_application/[string application_id]() returns json|error? {
        json|io:Error applicationRequests = io:fileReadJson(jsonFilePath);

        if applicationRequests is json[] {

            json? result = ();

            foreach var item in applicationRequests {
                if (item is json) {
                    string applicationIdFromDataSet = (check item.application_id).toString();
                    if (applicationIdFromDataSet == application_id) {
                        result = {
                            "application_id": application_id,
                            "status": (check item.status).toString(),
                            "message": "Credit card request (Application ID: " + application_id + ") is in " + (check item.status).toString()
                        };
                        return result;
                    }
                }
            }
        }
            return error("Invalid application Id");
    }


    //update status function
    isolated resource function put updateStatus/[string application_id](@http:Payload json updateStatus) returns json|error {
        json|io:Error applicationRequests = io:fileReadJson(jsonFilePath);

        if applicationRequests is json[] {
            foreach var item in applicationRequests {
                if (item is json) {
                    string applicationIdFromDataSet = (check item.application_id).toString();

                    if (applicationIdFromDataSet == application_id) {
                        string status = (check updateStatus.status).toString();
                        map<json> mapResult = check item.ensureType();
                        mapResult["status"] = status;

                        json _ = check io:fileWriteJson(jsonFilePath, applicationRequests);

                        return item;
                    }
                }
            }
        }
            return error("Invalid application Id");
    }
}
