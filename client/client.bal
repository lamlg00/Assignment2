import ballerina/http;
import ballerina/io;

public class GraphQLClient {
    private http:Client httpClient;

    public function init() returns error? {
        self.httpClient = check new("http://localhost:9090");
    }
public function getAllObjectives() returns json|error {
        var query = "query { getAllObjectives { id name weight } }";
        var response = self.httpClient->post("/graphql", query);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function addKPI() returns json|error {
        var mutation = "mutation { addKPI(newkpi: { name: \"Peer Recognition\", unit_of_measurement: \"percentage\", weight: 0.2 }) { message } }";
        var response = self.httpClient->post("/graphql", mutation);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function getKPIsEmployeeID(string employee_id) returns json|error {
        var query = "query { getKPIsEmployeeID(employee_id: \"" + employee_id + "\") { kpi_id name value } }";
        var response = self.httpClient->post("/graphql", query);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function addObjective() returns json|error {
        var mutation = "mutation { addObjective(newobjective: { name: \"Improve Customer Satisfaction\", weight: 0.3 }) { message } }";
        var response = self.httpClient->post("/graphql", mutation);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function deleteObjective() returns json|error {
        var mutation = "mutation { deleteObjective(oldobjective: { id: \"O_1\", name: \"Improve Customer Satisfaction\", weight: 0.3 }, token: \"token\") { message } }";
        var response = self.httpClient->post("/graphql", mutation);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function assignEmployeeToSupervisor() returns json|error {
        var mutation = "mutation { assignEmployeeToSupervisor(employee: { employee_id: \"E001\", first_name: \"John\", last_name: \"Doe\", job_title: \"Software Engineer\", position: \"Senior\", role: \"Developer\", department_id: \"D001\", supervisor_id: \"S001\", kpi_data: [] }, supervisor: { _id: \"S001\", employee_id: \"E002\", assigned_employees: [\"E001\"], kpi_approval_history: [] }, HOD: { username: \"admin\", isHOD: true, isSupervisor: false, isEmployee: false } ) { message } }";
        var response = self.httpClient->post("/graphql", mutation);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }

    public function login() returns json|error {
        var mutation = "mutation { login(user: { username: \"user\", password: \"password\" }) { username isHOD isSupervisor isEmployee } }";
        var response = self.httpClient->post("/graphql", mutation);
        if (response is http:Response) {
            return response.getJsonPayload();
        } else {
            return response;
        }
    }
}




