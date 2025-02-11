# aws-fargate-apps-tf
AWS Fargate-based solution for running batch, web and L4 applications.

To run containerized applications in AWS Fargate, many resources need to be created. Depending on the requirements, different types of applications (batch, web and L4 applications, as well as services) might need to be run in ECS clusters, which further complicates the solution. In addition to that, you might want to reuse load balancers and other resources in your staging AWS account to give every development team it’s own ECS cluster. Adapting the solution from this repository will allow you to get the benefits of using AWS Fargate faster and easier.

You can read about the design of these Terraform modules [here](https://workingwiththecloud.com/blog/fargate-apps/).
