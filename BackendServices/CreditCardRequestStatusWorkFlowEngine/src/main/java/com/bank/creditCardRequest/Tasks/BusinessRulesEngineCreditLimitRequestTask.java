package com.bank.creditCardRequest.Tasks;

import com.bank.creditCardRequest.Responses.Response;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.activiti.engine.delegate.DelegateExecution;
import org.activiti.engine.delegate.JavaDelegate;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestBody;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@Component
public class BusinessRulesEngineCreditLimitRequestTask implements JavaDelegate {

    @Override
    public void execute(DelegateExecution execution) {
        System.out.println("Executing Business Rules Engine credit limit request");
    }

    public Response updateStatus(@RequestBody JsonNode requestBody) {
        System.out.println(requestBody);
        String requestsFilePath = "/app/requests.json";
        String application_id = requestBody.get("application_id").asText();
        String workflowStatus = requestBody.get("workflow_update_to").asText();
        System.out.println(workflowStatus);
        Response response = new Response();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            byte[] jsonData = Files.readAllBytes(Paths.get(requestsFilePath));
            JsonNode requestDetails = objectMapper.readTree(new ByteArrayInputStream(jsonData));

            if (requestDetails.isArray()) {
                boolean found = false;
                for (JsonNode req : requestDetails) {
                    if (req.isObject()) {
                        String applicationIdFromDataSet = req.path("application_id").asText();

                        if (applicationIdFromDataSet.equals(application_id)) {
                            found = true;
                            ObjectNode additionalProperties = objectMapper.createObjectNode();
                            additionalProperties.put("workflow_status", workflowStatus);
                            ObjectNode result = (ObjectNode) req;
                            result.putAll(additionalProperties);
                            Files.write(Paths.get(requestsFilePath), objectMapper.writeValueAsBytes(requestDetails));
                            response.setWorkflow_status(workflowStatus);
                            System.out.println(workflowStatus);
                        }
                    }
                }
                if (!found) {
                    response.setWorkflow_status("Invalid application_id");
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return response;
    }
}
