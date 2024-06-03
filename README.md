# DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/a1499207-326a-45e6-8ca5-fa1fceeded34)
<br><br/>
End-to-end Architecture diagram is as shown in the screenshot attached above. For this demonstration source code is present in GitHub Repository and Jenkins uses this source code. CI/CD pipeline has been created using Jenkins Freestyle Job.
<br><br/>
There are four required plugins for Jenkins to achieve this as listed below.
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
Using this policy you can create a user or IAM Role and using this user/IAM Role you can authorize Jenkins to run the Deployment in AWS CodeDeploy.
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
<br><br/>
The environment variable can be set using Environment Injector plugin during the Build Steps as shown in the screenshot below.
<br><br/>
During Build steps at Execute Shell I have used below shell script using which code will be Build using the Maven and it will check S3 bucket with the name of mederma2024 in the region us-east-2. If it exists then it will use that S3 bucket otherwise create it with the bucket policy as mentioned below. This S3 bucket will keep the revision for CodeDeploy which will be finally deployed to EC2 Instances created as a part of AutoScaling Group. 
```
mvn clean install sonar:sonar -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300
BUCKET_EXISTANCE=`aws s3 ls s3://mederma2024 --region=us-east-2 2>&1`
if [ "$BUCKET_EXISTANCE | grep -o NoSuchBucket" == "NoSuchBucket" ]
then
  {
    aws s3 mb s3://mederma2024 --region=us-east-2
    cat > codedeploy-bucket-policy.json <<END_FOR_SCRIPT
{
	"Version": "2012-10-17",
	"Id": "S3PolicyId1",
	"Statement": [
		{
			"Sid": "IPAllow",
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::mederma2024/*",
			"Condition": {
				"IpAddress": {"aws:SourceIp": "18.224.157.99/32"}
			} 
		} 
	]
}
END_FOR_SCRIPT
    aws s3api put-bucket-policy --bucket mederma2024 --policy file://codedeploy-bucket-policy.json
  }
else
  echo "Considering the existed bucket"
fi
```
<br><br/>
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/2c013a92-e9b8-40ca-9211-5ca820e00fb1)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/710b6269-7c09-4094-b8a6-e36b22303583)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/ce9d6130-7cd6-4f24-bf3f-5c590d1fd95b)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/cafc1dd1-485d-4984-be8e-2bfcbf53201c)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/bff81593-66af-463d-a1b2-f5323415bc0f)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/65d03478-ab78-4aed-accf-be4d2e56b2fb)
<br><br/>
Endpoint of MySQL RDS has been updated in the file login.jsp and userRegistration.jsp present at the path src/main/webapp/ of the GitHub repository as shown in the screenshot below
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/109fd841-e54d-465f-bc92-cda8ede7b7de)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/54848216-3254-453c-85c0-398506a28b4c)
<br><br/>
After Successful execution of Jenkins Job Deployment will be started in AWS Code Deploy and which will be completed successfuly.
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/f652f25c-41f4-44aa-bf0f-1594907fe80b)
<br><br/>
Finally using the URL you can access the application as shown in the screenshot below.
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/691cb76f-439c-4545-9c2f-166ad30e9c9d)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/dcef5a0d-2063-4df0-badc-18cc4b482630)
![image](https://github.com/kamalmohan217/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/128888356/4b0d9974-2e3c-4912-8c04-fcffb6acc0f7)
