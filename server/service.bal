import ballerina/graphql;
import ballerinax/mongodb;
import ballerina/io;




type Employee record {
    string employee_id;
    string first_name; 
    string last_name; 
    string job_title; 
    string position; 
    string role;
    string department_id; 
    string? supervisor_id; 
    KpiData[] kpi_data; // An array of employee-specific Key Performance Indicators (KPIs)
};

type KpiData record {
    string kpi_id; // Identifier for the KPI
    string name; // Name of the KPI
    float value; // Value of the KPI
};
type Departments record {
    string department_id; // A unique identifier for each department
    string name; // The name of the department
    Objective[] objectives; // An array of departmental objectives
};
type Objective record {
    string id;
    string name; // Name of the objective
    float weight; // Weight of the objective
};
type Supervisor record {
    string _id; // A unique identifier for each supervisor
    string employee_id; // A reference to the employee they supervise
Employee[] assigned_employees; // An array of employee references under their supervision
    KpiApproval[] kpi_approval_history; // A history of approved KPIs
};
type KpiApproval record {
    string employee_id; // Employee for whom the KPI was approved
    string kpi_id; // Identifier for the approved KPI
    boolean approved; // Whether the KPI was approved (true/false)
    string approval_date; // Date and time of approval
};

type KpiMetrics record {
    string _id; // A unique identifier for each KPI metric
    string name; // Name of the KPI metric (e.g., Peer Recognition, Professional Development)
    string unit_of_measurement; // The unit used for measurement (e.g., percentage, time, score)
    float weight; // The weight assigned to this KPI in departmental objectives
};

type User record {
    string _id; // A unique identifier for each user
    string username; // The username used for authentication
    string password; // The hashed password for authentication
    string authorization; // The user's role or authorization level within the system
};

type UserDetails record {
    string username;
    string? password;
    boolean isHOD;
    boolean isSupervisor;
    boolean isEmployee;
};

type UpdatedUserDetails record {
    string username;
    string password;
};

type LoggedUserDetails record {|
    string username;
    boolean isHOD;
    boolean isSupervisor;
    boolean isEmployee;
|};
mongodb:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        port: 27017,
        auth: {
            username: "",
            password: ""
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout: 5000
        }
    },
    databaseName: "performancesystem"
};
mongodb:Client db = check new (mongoConfig);
configurable string employeesCollection = "Employees";
configurable string departmentsCollection = "Departments";
configurable string supervisorsCollection = "Supervisors";
configurable string kpi_metricsCollection = "KPI_Metrics";
configurable string usersCollection = "Users";
configurable string objectivesCollection = "Objective";
configurable string databaseName = "performancesystem";


map<string> authenticatedUsers = {};

function isAuthenticated(string token) returns boolean {
    return authenticatedUsers.hasKey(token);
}

@graphql:ServiceConfig{
     graphiql: {
        enabled: true,
    // Path is optional, if not provided, it will be dafulted to `/graphiql`.
    path: "/graphql"
    }
}
service /pmsystem on new graphql:Listener(9090){
    


    remote function addKPI(KpiMetrics newkpi) returns error|string {
        map<json> doc = <map<json>>newkpi.toJson();
        _ = check db->insert(doc, kpi_metricsCollection, "");
        return string `${newkpi.name} added successfully`;
    }
     resource function get login(User user) returns LoggedUserDetails|error {
        stream<UserDetails, error?> usersDeatils = check db->find(usersCollection,databaseName , {username: user.username, password: user.password}, {});

        UserDetails[] users = check from var userInfo in usersDeatils
            select userInfo;
        io:println("Users ", users);
        // If the user is found return a user or return a string user not found

        
        if users.length() > 0 {
        return { username: users[0].username, isHOD: users[0].isHOD, isSupervisor: users[0].isSupervisor, isEmployee: users[0].isEmployee };
        }
        return {
          username: "",
        isHOD: false,
        isSupervisor: false,
        isEmployee: false
        };
    }
    resource function getAllObjectives() returns Objective[] {
        Objective[]? result = check db->find("objectivesCollection", "performancesystem", {}, {});
        if (result != null) {
            return result;
        }
        return [];
    }
    resource function getKPIsEmployeeID(string employee_id) returns KpiData[] {
        KpiData[]? result = check db->find("kpi_metricsCollection", "performancesystem", {employee_id: employee_id}, {});
        if (result != null) {
            return result;
        }
        return [];
    }



    remote function addObjetive(Objective newobjective) returns error|string {
        map<json> doc = <map<json>>newobjective.toJson();
        _ = check db->insert(doc, objectivesCollection, "");
        return string `${newobjective.name} added successfully`;
   }
   remote function deleteObjective(Objective oldobjective,token:string) returns string|error {
    // Authentication check
    if (!isAuthenticated(token)) {
        return error("Authentication failed. Please log in.");
    }

    
    string collectionName = "objectives";


    map<json> query = {
        "_id": "O_1" 
    };

   
    stream<map<json>, error?>|error objectiveStream = db->find(objectivesCollection, query, {});

    
    error? queryError = objectiveStream is stream<map<json>, error?> ? () : objectiveStream;

    if (queryError != null) {
        return queryError;
    }

    map<json> objective = check objectiveStream.next()?;

    if (objective == null) {
        return error("Objective not found");
    }

    
    _ = check db->delete(objectivescollectionName, { "_id": _id });

    return string `${oldobjective.name} deleted successfully` ;
}

remote function assignEmployeeToSupervisor(Employee employee, Supervisor supervisor, LoggedUserDetails HOD) returns string|error {
    // Authentication check
    if (!isAuthenticated(HOD)) {
        return error("Authentication failed. Please log in.");
    }

    
    string employeesCollectionName = "Employees";
    string supervisorsCollectionName = "Supervisors";

   
    map<json> employeeQuery = {
        "employee_id": "E001"
    };

    
    map<json> supervisorQuery = {
        "_id": "S001"
    };

    stream<map<json>, error?>|error employeeStream = db->find(employeesCollectionName, employeeQuery, {});
    stream<map<json>, error?>|error supervisorStream = db->find(supervisorsCollectionName, supervisorQuery, {});

    // Check for any errors during the query executions
    error? employeeQueryError = employeeStream is stream<map<json>, error?> ? () : employeeStream;
    error? supervisorQueryError = supervisorStream is stream<map<json>, error?> ? () : supervisorStream;

    if (employeeQueryError != null) {
        return employeeQueryError;
    }

    if (supervisorQueryError != null) {
        return supervisorQueryError;
    }

    
    map<json> employee = check employeeStream.next()?;
    map<json> supervisor = check supervisorStream.next()?;

    if (employee == null) {
        return error("Employee not found");
    }

    if (supervisor == null) {
        return error("Supervisor not found");
    }

    // Add the employee to the supervisor's list of assigned employees
    string supervisorDocumentId = supervisor["_id"].toString();
    string[] assignedEmployees = supervisor["assigned_employees"];
    
    if (assignedEmployees == null) {
        assignedEmployees = [];
    }

    if (!assignedEmployees.contains(employeeId)) {
        assignedEmployees.add(employeeId);
        supervisor["assigned_employees"] = assignedEmployees;
        _ = check db->update(supervisorsCollectionName, { "_id": supervisorDocumentId }, supervisor, {});
    }

    return "Employee assigned to supervisor successfully";
}

}

  
}





