# Assessment

The techchallenge application has been hosted successfully in AKS cluster. Please refer to the screenshot below,

![TechChallenge Application](/doc/images/techchallengeapp-aman.JPG)

The connection is not secure, as, I don't have any ssl certificate to bind.

## Prerequisities:

 1. You should have a git repository to store the application code, IAC and pipeline yaml. 
 2. You should have an valid Azure Account
 3. You should have an Azure DevOps subscription to deploy the solution.


 ## Azure-pipeline details

 Multistage azure devops yaml pipeline is used to depoly the infrastructure along with the build and deployment of the techchallenge application into AKS. 

* Terraform files are stored in `iac` folder in repository.
* Pipeline yamls are stored in `pipeline` folder in repository.
* Pipeline auto trigger is in place for any change in `master`, `*feature` and `PR to master`

 The pipeline looks like below.

 ![pipeline](/doc/images/techchallengepipeline.JPG)

 ### The architecture diagram of deployment looks like below

 #### IAC pipeline

![Deployment IAC Architecture Diagram](/doc/images/IAC-pipelineflow.JPG)

*  Stage `Terraform file publish `: Publish the terraform files as artifact for the deployment
*  Stage `Infra Deployment`: Terraform IAC deployment in azure

##### Azure resources created after IAC pipeline run

![Azure techchallenge rg](/doc/images/techchallenge-azure-rg.JPG)

![Azure AKS configuration rg](/doc/images/aks_configuration_rg.JPG)

 #### App build and deployment pipeline

![Deployment App Architecture Diagram](/doc/images/deployAppPipeline.JPG)

*  Stage `Build the app and push the image to acr`: Build the app and docker image. Publish the docker image to ACR.
*  Stage `App Deployment`: Deploying the aks manifest file in AKS along with the image from ACR.

 __Few key points to be taken into consideration__,

  * All the application secrets are maintainaed in Azure DevOps variables as a secret.
  * Terraform has been used to implement IAC
  * Three service connection is required to be created (owner/contributor access to the subscription/resource group for azure) in azure pipelines name `visual-studio-professional-azure-service-connection(azure service connection)`, `techchallenge-app-aks-service-connection(Kubernetes service connection)`, `techchallenge-app-acr-service-connection(docker registry service connection)`.

  ![Service Connections screenshot ](/doc/images/azurepipeline_svc_connections.JPG)

  * Azure Storage account is used to store the terraform state file.
  * Manual check has been put after the infra deployment step to feed in the prerequisites for the app deployment such as acr and aks   service connections mentioned above along with the few variables i.e. `techChallengeACR`, `psqldbUser`
  * Namespace used in the kubernetes is `default` for this application.

## Steps for provisioning the solution.

 1. Create the following variables before running the pipeline `psqlAdminPassword (this is a secret)`,  `psqlDb`, `psqlDb`, `psqldbUser`, `techChallengeACR`, `terraformStorageKey`, `tfStorageAccount`, `tfStorageAccountRG`

 ![Pipeline variables screeshot](/doc/images/pipeline_variables.JPG)
 
 2. Provision the infrastructure by running the infra deployment stage. After the deployment Approval and Check will be there for build and deployment of app.
 3. Create the service connection required for the App deployment i.e. `techchallenge-app-aks-service-connection(Kubernetes service connection)` and `techchallenge-app-acr-service-connection(docker registry service connection)`
 4. Modify `aksmanifest.yaml` to map to your ACR and AKS namespace along with the pod requirements and push it to github.
 5. Run the Build and App deployment stage by approving the check. 
 6. Get the loadbalance Ip out of pipeline output and browse the same using the port 3000. For my application its `http://20.73.197.167:3000/`

 ![loadbalance ip as task output](/doc/images/pipeline_application_task_output.JPG)


## Application Resiliency

- AKS have the auto scaling feature that can be configured through IAC and spinning the number of pods configured through aks manifest file. For this case, update the `enable_auto_scaling=true` in `main.tf` file and update the `replicas: 2` in `aksmanifest.yaml`.

![AKS pods for tech challenge AKS](/doc/images/aks_pods.JPG)

- Highly available Database solution has been achieved through `Azure Database for PostgreSQL server` PAAS service with `Hyperscale (Citus) server group` plan using `Geo Redundant Feature`.

![psql ha diamgram](/doc/images/postgress_sql_HA.JPG)

## Security

* NSG is in place for AKS where all the calls are blocked except for the inbound calls for loadbalancer ip. Please refer to the screenshot below for more details:

![AKS NSG](/doc/images/aks-nsg-rule.JPG)

* Configured the postgress sql server's firewall to accept connections only from Azure resources.
* Suggestion: Ip restriction firewall rule can be placed on Postgress sql server. This can be easily done by updating the  `start_ip_address    = "0.0.0.0"` and `end_ip_address      = "0.0.0.0"` of `azurerm_postgresql_server` block in `main.tf`
* We are not storing any acr credential in the repository and the authentication is being done azure-devops service-principle, however, a user-assigned manage identity can be created and assigned to acr identity with `ACR Pull` role to to authenticate to acr from aks. 
* Private endpoints can also be used for secure connection, but acr is required to be on `Premium SKU`

## Github branching strategy practice followed.

 * Branch restriction policy has been applied to prevent direct commits to `master` branch.
 * Any change required to created in feature branch cloned from master and once changes are done PR is required to be created with all the associated details mentioned in the PR details which is further required to be assigned to some other devs for review.
 * For the Pull Requests github checks has been enabled to check the build status. Please refer to the screen shot below for the branch protection rules.
 
![githubSecurity](/doc/images/github_branch_restrictions.JPG)

* Once the check is passed and PR is approved preffered way to merge is `squash and merge` 


