import ballerina/http;
#import ballerina/log;

type Account record {
    string id;
    string 'type;
    float balance;
    string currency;
};

type NewAccount record {
    string 'type;
    float initialDeposit;
    string currency;
};

type Transaction record {
    string id;
    string accountId;
    float amount;
    string 'type;
    string timestamp;
};

type Customer record {
    string id;
    string name;
    string email;
    string phone;
};

type NewCustomer record {
    string name;
    string email;
    string phone;
};

service /bankService on new http:Listener(8080) {

    resource function get accounts(http:Caller caller, http:Request req) returns error? {
        json accounts = [
            { "id": "acc123", "type": "savings", "balance": 1000.00, "currency": "USD" },
            { "id": "acc456", "type": "checking", "balance": 2000.00, "currency": "USD" }
        ];
        check caller->respond(accounts);
    }

    resource function post accounts(http:Caller caller, http:Request req) returns error? {
        json newAccountJson = check req.getJsonPayload();
        NewAccount newAccount = check jsonToNewAccount(newAccountJson);
        // Simulate account creation logic here
        Account createdAccount = {
            id: "acc789",
            'type: newAccount.'type,
            balance: newAccount.initialDeposit,
            currency: newAccount.currency
        };
        check caller->respond(createdAccount);
    }

    resource function get accounts/[string accountId](http:Caller caller, http:Request req) returns error? {
        Account account = { id: accountId, 'type: "savings", balance: 1000.00, currency: "USD" };
        check caller->respond(account);
    }

    resource function put accounts/[string accountId](http:Caller caller, http:Request req) returns error? {
        json updatedAccountJson = check req.getJsonPayload();
        Account updatedAccount = check jsonToAccount(updatedAccountJson);
        // Simulate account update logic here
        check caller->respond(updatedAccount);
    }

    resource function delete accounts/[string accountId](http:Caller caller, http:Request req) returns error? {
        // Simulate account deletion logic here
        check caller->respond(());
    }

    resource function get transactions(http:Caller caller, http:Request req) returns error? {
        json transactions = [
            { "id": "txn123", "accountId": "acc123", "amount": 50.00, "type": "debit", "timestamp": "2024-07-19T12:34:56Z" }
        ];
        check caller->respond(transactions);
    }

    resource function get transactions/[string transactionId](http:Caller caller, http:Request req) returns error? {
        json 'transaction = { "id": transactionId, "accountId": "acc123", "amount": 50.00, "type": "debit", "timestamp": "2024-07-19T12:34:56Z" };
        check caller->respond('transaction);
    }

    resource function get customers(http:Caller caller, http:Request req) returns error? {
        json customers = [
            { "id": "cust123", "name": "John Doe", "email": "john.doe@example.com", "phone": "123-456-7890" }
        ];
        check caller->respond(customers);
    }

    resource function post customers(http:Caller caller, http:Request req) returns error? {
        json newCustomerJson = check req.getJsonPayload();
        NewCustomer newCustomer = check jsonToNewCustomer(newCustomerJson);
        // Simulate customer creation logic here
        Customer createdCustomer = {
            id: "cust456",
            name: newCustomer.name,
            email: newCustomer.email,
            phone: newCustomer.phone
        };
        check caller->respond(createdCustomer);
    }

    resource function get customers/[string customerId](http:Caller caller, http:Request req) returns error? {
        Customer customer = { id: customerId, name: "John Doe", email: "john.doe@example.com", phone: "123-456-7890" };
        check caller->respond(customer);
    }

    resource function put customers/[string customerId](http:Caller caller, http:Request req) returns error? {
        json updatedCustomerJson = check req.getJsonPayload();
        Customer updatedCustomer = check jsonToCustomer(updatedCustomerJson);
        // Simulate customer update logic here
        check caller->respond(updatedCustomer);
    }

    resource function delete customers/[string customerId](http:Caller caller, http:Request req) returns error? {
        // Simulate customer deletion logic here
        check caller->respond(());
    }
}

function jsonToAccount(json accountJson) returns Account|error {
    return accountJson.cloneWithType(Account);
}

function jsonToNewAccount(json newAccountJson) returns NewAccount|error {
    return newAccountJson.cloneWithType(NewAccount);
}

function jsonToCustomer(json customerJson) returns Customer|error {
    return customerJson.cloneWithType(Customer);
}

function jsonToNewCustomer(json newCustomerJson) returns NewCustomer|error {
    return newCustomerJson.cloneWithType(NewCustomer);
}
