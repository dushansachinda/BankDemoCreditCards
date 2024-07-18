import ballerina/http;
import ballerina/io;

string creditRatingFile = "../CoreBank/creditRating.json";

service /bre on new http:Listener(9094) {
    resource function post validate/credit_limit(@http:Payload json creditLimitRequest) returns json|error {

        if ((check creditLimitRequest.credit_rating).toString() == "Poor") {
            return {
                "message": "Poor credit rating.Application rejected"
            };
        }

        else {
            json|io:Error creditRatingDetails = io:fileReadJson(creditRatingFile);

            if creditRatingDetails is json[] {
                string userIdFromRequest = (check creditLimitRequest.user_id).toString();

                foreach var item in creditRatingDetails {
                    if (item is json) {
                        string userIdFromDataSet = (check item.user_id).toString();
                        if (userIdFromDataSet == userIdFromRequest) {
                            int approvedCreditLimit = (check item.credit_limit);
                            json additionalProperties = {
                                "approved_credit_limit": approvedCreditLimit,
                                "message": "Credit limit request approved. Approved credit limit is $" + approvedCreditLimit.toString()
                            };
                            json|error response = creditLimitRequest.mergeJson(additionalProperties);
                            return response;
                        }
                    }
                }
            }
            return error("Invalid user Id");
        }
    }
}
