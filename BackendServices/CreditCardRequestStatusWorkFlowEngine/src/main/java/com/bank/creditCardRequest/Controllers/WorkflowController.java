package com.bank.creditCardRequest.Controllers;

import com.bank.creditCardRequest.Responses.Response;
import com.bank.creditCardRequest.Tasks.BusinessRulesEngineCreditLimitRequestTask;
import com.bank.creditCardRequest.Tasks.CIBCreditScoreRequestTask;
import com.bank.creditCardRequest.Tasks.CoreBankCreditRatingRequestTask;
import org.activiti.engine.RepositoryService;
import org.activiti.engine.RuntimeService;
import org.activiti.engine.delegate.DelegateExecution;
import org.activiti.engine.delegate.JavaDelegate;
import org.activiti.engine.repository.Deployment;
import org.activiti.engine.runtime.ProcessInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.xml.sax.SAXException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import javax.xml.parsers.ParserConfigurationException;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("/workflow")
public class WorkflowController implements JavaDelegate {
    @Autowired
    private RuntimeService runtimeService;
    @Autowired
    private RepositoryService repositoryService;

    @Autowired
    private BusinessRulesEngineCreditLimitRequestTask businessRulesEngineCreditLimitRequestTask;
    @Autowired
    CIBCreditScoreRequestTask cibCreditScoreRequestTask;

    @Autowired
    CoreBankCreditRatingRequestTask coreBankCreditRatingRequestTask;

    public WorkflowController() throws IOException, ParserConfigurationException, SAXException {
    }

    @Override
    public void execute(DelegateExecution execution) {

    }

    @PostMapping("/start/{application_id}")
    public Response startWorkflow(@PathVariable("application_id") String application_id) {
        String requestsFilePath = "/app/requests.json";

        Response response = new Response();
        try {
            List<Deployment> deployments = repositoryService.createDeploymentQuery()
                    .deploymentName("CreditCardRequestWorkflow")
                    .list();

            if (deployments.isEmpty()) {
                repositoryService.createDeployment()
                        .name("CreditCardRequestWorkflow")
                        .addClasspathResource("processes/CreditCardRequestWorkflow.bpmn20.xml")
                        .deploy();

                System.out.println("Process deployed successfully.");
            } else {
                System.out.println("Process is already deployed.");
            }

            ProcessInstance processInstance = runtimeService.startProcessInstanceByKey("CreditCardRequestWorkflow", application_id);

            try {
                // Read the JSON file into a JsonNode
                ObjectMapper objectMapper = new ObjectMapper();
                byte[] jsonData = Files.readAllBytes(Paths.get(requestsFilePath));
                JsonNode requestDetails = objectMapper.readTree(new ByteArrayInputStream(jsonData));


                if (requestDetails.isArray()) {
                    for (JsonNode req : requestDetails) {
                        if (req.isObject()) {
                            String applicationIdFromDataSet = req.path("application_id").asText();

                            if (applicationIdFromDataSet.equals(application_id)) {
                                ObjectNode additionalProperties = objectMapper.createObjectNode();
                                String workflowStatus = "Workflow started for application id " + application_id + " pending at CIB score request approval";
                                additionalProperties.put("workflow_status", workflowStatus);
                                ObjectNode result = (ObjectNode) req;
                                result.putAll(additionalProperties);
                                Files.write(Paths.get(requestsFilePath), objectMapper.writeValueAsBytes(requestDetails));
                                response.setWorkflow_status(workflowStatus);
                                System.out.println(workflowStatus);
                            }
                        }
                    }
                }

            } catch (IOException e) {
                e.printStackTrace();
            }

            return response;

        } catch (Exception e) {
            e.printStackTrace();
            response.setWorkflow_status("Error: " + e.getMessage());
            return response;
        }
    }

    @PostMapping("/cibRequest/{application_id}")
    public Response CIBRequest(@PathVariable("application_id") String application_id, @RequestBody JsonNode requestBody) {
        Response response = new Response();
        try {
            cibCreditScoreRequestTask.execute(null);
            response = cibCreditScoreRequestTask.updateStatus(requestBody);

        } catch (Exception e) {
            e.printStackTrace();

        }
        return response;
    }

    @PostMapping("/creditRating/{application_id}")
    public Response requestCreditRating(@PathVariable("application_id") String application_id, @RequestBody JsonNode requestBody) {
        Response response = new Response();
        try {
            coreBankCreditRatingRequestTask.execute(null);
            response = coreBankCreditRatingRequestTask.updateStatus(requestBody);

        } catch (Exception e) {
            e.printStackTrace();

        }
        return response;
    }

    @PostMapping("/creditLimit/{application_id}")
    public Response requestCreditLimit(@PathVariable("application_id") String application_id, @RequestBody JsonNode requestBody) {
        Response response = new Response();
        try {
            businessRulesEngineCreditLimitRequestTask.execute(null);
            response = businessRulesEngineCreditLimitRequestTask.updateStatus(requestBody);

        } catch (Exception e) {
            e.printStackTrace();

        }
        return response;
    }

    @GetMapping("/status/{application_id}")
    public Response checkWorkflowStatus(@PathVariable("application_id") String application_id) {
        Response response = new Response();
        try {
            String requestsFilePath = "/app/requests.json";

            // Read the JSON file into a JsonNode
            ObjectMapper objectMapper = new ObjectMapper();
            byte[] jsonData = Files.readAllBytes(Paths.get(requestsFilePath));
            JsonNode requestDetails = objectMapper.readTree(new ByteArrayInputStream(jsonData));

            if (requestDetails.isArray()) {
                for (JsonNode req : requestDetails) {
                    if (req.isObject()) {
                        String applicationIdFromDataSet = req.path("application_id").asText();

                        if (applicationIdFromDataSet.equals(application_id)) {
                            String workflowStatus = req.path("workflow_status").asText();
                            System.out.println("Workflow status for application id " + application_id + ": " + workflowStatus);
                            response.setWorkflow_status(workflowStatus);
                            return response;
                        }
                    }
                }
            }

            // If no matching application_id is found
            response.setWorkflow_status("Invalid application id " + application_id);
            return response;

        } catch (IOException e) {
            e.printStackTrace();
            response.setWorkflow_status("Error: " + e.getMessage());
            return response;
        }
    }


}