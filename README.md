# DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/a1499207-326a-45e6-8ca5-fa1fceeded34)
<br><br/>
End-to-end Architecture diagram is as shown in the screenshot attached above. For this demonstration source code is present in GitHub Repository and Jenkins uses this source code. CI/CD pipeline has been created using Jenkins Freestyle Job.
<br><br/>
There are four required plugins for Jenkins to achieved this as listed below.
```
1.	Environment Injector
2.	SonarQube Scanner
3.	Nexus Artifact Upload
4.	AWS CodeDeploy
```
After installation of these four plugin configure SonarQube from Manage Jenkins > Systems as show in the screenshot below.
<br><br/>
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/165b2f22-fc62-4b0d-9ab3-99555ff9a0b7)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/05857b55-630d-4869-bf37-303a5e552130)
<br><br/>
Webhook has been created for SonarQube as shown in the screenshot below.
<br><br/>
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/d7de5981-b6be-4dca-90d4-fe061d1b6a0b)
<br><br/>
Create Application, Deployment Group and an IAM Policy which is required by Jenkins for AWS CodeDeploy.
<br><br/>
**IAM POlicy**
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/768ec6d5-04fd-4ac2-bc1d-1074e70a1daa)
**Application for AWS CodeDeploy**
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/e1d9779f-f03c-4eeb-a56d-3ae0d9b9fb08)
**Deployment Group for AWS CodeDeploy**
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/18c2d823-9f28-43a6-9e09-f3ee52865674)
<br><br/>
**Creation of FreeStyle Jenkins Job**
<br><br/>
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/9ceb8cf0-14b2-49ae-8e8f-407893915d0a)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/5a3da942-78c4-4f97-ae70-704935e4b52c)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/803e8057-855e-4df5-833d-5c78189c6ee8)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/a23646bb-2bcb-4525-b6a7-a3b409936996)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/2c013a92-e9b8-40ca-9211-5ca820e00fb1)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/710b6269-7c09-4094-b8a6-e36b22303583)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/ce9d6130-7cd6-4f24-bf3f-5c590d1fd95b)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/65d03478-ab78-4aed-accf-be4d2e56b2fb)
