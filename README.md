#DevOps-Challenge

DevOps Challenge

Your objective for this is to deploy this project to a cloud provider..
Prerequisites:

- NodeJs
- Ansible
- Terraform
- Github



Step #1

- Prepare the networking. With Terraform, you will do this.
Create a VPC with 2 public subnets in two different availability zones. If this is new to you, take
some time to search for this, as you will need to understand this to continue with the challenge.
Below steps will help to achieve Step#1


Step #2

- You will need to create 2 EC2 instances and assign them in the VPC created in Step 1.
For doing this you will need to use terraform
-----
#### Challenge
- In case you want to show you rock with Terraform, instead of using EC2, create an autoscaling
group. So we can have dynamic instances.

Step #3

- You will need to create an application load balancer for this. The idea is that for accessing the
application it has to be using the load balancer. For doing this you will need to use terraform


Step #4

- When you have the infrastructure, you will need to install the application. You will need to install
node in the EC2 you created in step 2 and configure the application. Remember the application
will need to be up always. For doing this, you will need to run ansible for configuring everything.


Step #5

- Create a README file and place all the steps. The way we’re going to evaluate this, is following
the instructions from this file. So be clear as possible. Explain which are the variables, etc


#Proposed Solution(Covering Step 1, 2 & 3)
- A. Create project directory and Git repo and do first commit
- B. Provider and terraform initialisation
- C. Create VPC and internet gateway
- D. Create Public subnets
- E. Create Security groups for EC2 and Load balancer
- F. Create IAM profile
- G. Create Route table and associate with subnets
- H. Create Internet Gateway , public route table and association
- I. Create EC2 instances profile
- J. Create Application load balancer and map with Subents
- K. Create AutoScaling group


###Deploy application (Step 4)

A Install Ansible and its dependencies
B. Configure Ansible and git
C. Prepare playbook to deploy NodeJS and its dependencies
D. Prepare playbook to deploy Application from GitHub


##Part 1 # Basic Networking components
```
A. Create project directory and Git repo and do first commit
B. Provider and terraform initialisation
C. Create VPC and internet gateway
D. Create Public subnets
E. Create Security groups for EC2 and Load balancer
F. Create Route table and associate with subnets
G. Create Internet Gateway , public route table and association
H. Create EC2 Launch configuration & Auto Scaling group
I. Create Application load balancer and map with Subents
```


###A. Create project directory

step to create directory structure

>mkdir DevOps-Challenge


initialise the git and commit initial setup

>git init

####create .gitignore file

>Login into gitignore.io and generate the code for terraform and add the same to .gitignore

###run below command for initial commit
```
git status
git add .
git commit -m "initial commit"
git remote add origin https://github.com/rupeshpanwar/DevOps-Challenge.git
git push
```
###B. Provider and terraform initialisation

create 3 files
```
touch provider.tf
touch variables.tf
touch production.tfvars
touch output.tf
```
add  provider.tf to .gitignore as it contains secret and access keys

code of provider.tf
```
provider "aws" {
region = var.region
secret_key  = “your aws secret key”
access_key = “your aws access key”
}
```

code of variables.tf
```
variable "region" {
default = "us-east-1"
}
```

 Initialize the terraform to download the provider and plugins
```
terraform init
```

###C. Create VPC and Internet gateway

Create VPC.tf file

>touch vpc.tf


code of VPC.tf
```
resource "aws_vpc" "AAvenue-MainVPC" {
cidr_block            = var.vpc_cidr
instance_tenancy      = "default"
enable_dns_hostnames  = true

tags = {
Name = "VPC_TF"
}

}
resource "aws_internet_gateway" "IGW_AAvenue" {
vpc_id = aws_vpc.AAvenue-MainVPC.id

tags = {
Name = "IGW_AAvenue"
}
depends_on = [aws_vpc.AAvenue-MainVPC]
}


#variables.tf

variable "region" {
default = "us-east-1"
}

variable "vpc_cidr" {
description = "CIDR of VPC"
}

#production.tf

vpc_cidr = "10.0.0.0/16"

#output.tf

output "vpc_id" {
value = aws_vpc.AAvenue-MainVPC.id
}
```
let us run terraform cmd
```
terraform init
Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve
```
push the provider information to GitHub
```
git status
git add  .
git status
git commit -m “Create VPC and Internet gateway”
git push
```
###D. Create Public subnets

create subnets.tf file

>touch subnets.tf

code of subnets.tf
```
resource "aws_subnet" "public_subnets" {
count = length(var.public_subnet_cidr)
vpc_id     = aws_vpc.AAvenue-MainVPC.id
cidr_block = element(var.public_subnet_cidr, count.index)
availability_zone = element(var.availability_zone, count.index)
map_public_ip_on_launch = true

tags = {
Name = element(var.public_subnet_names, count.index)
}
depends_on = [aws_vpc.AAvenue-MainVPC]
}

#here are the variables for subnets.tf
variable "public_subnet_cidr" {
type = list(string)
description = "Subnet CIDR"
}

variable "public_subnet_names" {
type = list(string)
description = "Subnet names"
}

variable "availability_zone" {
type = list(string)
description = "Availability zones"
}
```
here is the production.tf for run time
```
availability_zone=["us-east-1a","us-east-1b"]
public_subnet_names=["public_subnet_1a_1","public_subnet_1b_1","public_subnet_1a_2","public_subnet_1b_2"]
public_subnet_cidr=["10.0.1.0/24","10.0.3.0/24","10.0.2.0/24","10.0.4.0/24"]
```


here is the output.tf
```
output "public_subnet_ids" {
value = aws_subnet.public_subnets.*.id
}

output "public_subnet_id_1" {
value = aws_subnet.public_subnets[0].id
}
output "public_subnet_id_4" {
value = aws_subnet.public_subnets[3].id
}

#let us run terraform cmd

terraform init
Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve

#push the provider information to GitHub

Git status
git add  .
git status
git commit -m “Create subnets”
git push
```

###E. Create Security groups for EC2 and Load balancer
create secgrps.tf

>touch secgrps.tf

code of  secgrps.tf
```
resource "aws_security_group" "elb_security_group" {
name = "ELB-SG"
description = "ELB Security Group"
vpc_id = aws_vpc.AAvenue-MainVPC.id

ingress {
from_port = 80
protocol = "tcp"
to_port = 80
cidr_blocks = ["0.0.0.0/0"]
description = "Allow web traffic to load balancer"
}

egress {
from_port = 0
protocol = "-1"
to_port = 0
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name ="elb_security_group"
}
}
resource "aws_security_group" "ec2_public_security_group" {
name        = "EC2-public-scg"
description = "Internet reaching access for public EC2 instances"
vpc_id      = aws_vpc.AAvenue-MainVPC.id

ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
security_groups = [
aws_security_group.elb_security_group.id]
}

egress {
from_port       = 0
to_port         = 0
protocol        = "-1"
cidr_blocks     = ["0.0.0.0/0"]
}

tags = {
Name = "ec2_public_security_group"
}

depends_on = [aws_vpc.AAvenue-MainVPC,
aws_security_group.elb_security_group]
}

```
let us run terraform cmd
```
terraform init
terraform plan —var-file=“production.tfvars”
terraform apply —var-file=“production.tfvars” —auto-approve
```
push the provider information to GitHub
```
git status
git add  .
git status
git commit -m "Create EC2 & ELB SGs"
git push
```

###F. Create IAM role/policy/profile
create iam.tf file
>touch iam.tf
```
#code for Iam
resource "aws_iam_role" "ec2_iam_role" {
name               = "EC2-IAM-Role"
assume_role_policy = <<EOF
{
"Version" : "2012-10-17",
"Statement" :
[
{
"Effect" : "Allow",
"Principal" : {
"Service" : ["ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
},
"Action" : "sts:AssumeRole"
}
]
}
EOF
}

resource "aws_iam_role_policy" "ec2_iam_role_policy" {
name    = "EC2-IAM-Policy"
role    = aws_iam_role.ec2_iam_role.id
policy  = <<EOF
{
"Version" : "2012-10-17",
"Statement" : [
{
"Effect": "Allow",
"Action": [
"ec2:*",
"elasticloadbalancing:*",
"cloudwatch:*",
"logs:*"
],
"Resource": "*"
}
]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
name = "EC2-IAM-Instance-Profile"
role = aws_iam_role.ec2_iam_role.name
}
```

let us run terraform cmd
```
terraform init
Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve
```

push the provider information to GitHub
```
git status
git add  .
git status
git commit -m “Create IAM Role”
git push
```

###F. Create Route table and associate with subnets

create routable.tf

>touch routable.tf

code of routable.tf
```
resource "aws_route_table" "PublicRouteTable" {
vpc_id = aws_vpc.AAvenue-MainVPC.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW_AAvenue.id
}
tags = {
Name = "PublicRouteTable"
}
depends_on = [aws_vpc.AAvenue-MainVPC,
aws_internet_gateway.IGW_AAvenue]
}


resource "aws_route_table_association" "publicroutetableassociation" {
count = length(var.public_subnet_cidr)
subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
route_table_id = aws_route_table.PublicRouteTable.id
depends_on     = [aws_subnet.public_subnets,
aws_route_table.PublicRouteTable]
}

#let us run terraform cmd

terraform init
Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve

#push the provider information to GitHub

git status
git add  .
git status
git commit -m "Create Route table and associate with subnets”
git push
```

###H. Create EC2 Launch configuration & Auto Scaling group

create file asg.tf

>touch asg.tf

code asg.tf
```
resource "aws_launch_configuration" "ec2_public_launch_configuration" {
image_id                    = var.ami
instance_type               = var.instance_type
key_name                    = var.key_pair_name
associate_public_ip_address = true
iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
security_groups             = [
aws_security_group.ec2_public_security_group.id]

}
resource "aws_autoscaling_group" "ec2_public_autoscaling_group" {
name                  = "Production-WebApp-AutoScalingGroup"
vpc_zone_identifier   = aws_subnet.public_subnets.*.id
max_size              = var.max_instance_size
min_size              = var.min_instance_size
launch_configuration  = aws_launch_configuration.ec2_public_launch_configuration.name
health_check_type     = "ELB"
load_balancers        = [
aws_elb.webapp_load_balancer.name]

tag {
key                 = "Name"
propagate_at_launch = false
value               = "WebApp-EC2-Instance"
}

tag {
key                 = "Type"
propagate_at_launch = false
value               = "WebApp"
}
}

resource "aws_autoscaling_policy" "webapp_production_scaling_policy" {
autoscaling_group_name    = aws_autoscaling_group.ec2_public_autoscaling_group.name
name                      = "Production-WebApp-AutoScaling-Policy"
policy_type               = "TargetTrackingScaling"
min_adjustment_magnitude  = 1

target_tracking_configuration {
predefined_metric_specification {
predefined_metric_type = "ASGAverageCPUUtilization"
}
target_value = 80.0
}
}

#variables.tf
variable "ami" {
default = "ami-047a51fa27710816e"
}
variable "instance_type" {
description = "instance type of EC2"
}

variable "key_pair_name" {
default = "connective"
description = "To connect to EC2 instance"
}

variable "max_instance_size" {
description = "maximum number of EC2 instances"
}

variable "min_instance_size" {
description = "minimum number of EC2 instances"
}



#product.tfvars
instance_type  = "t2.micro"
max_instance_size = "6"
min_instance_size = "4"


#let us run terraform cmd

Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve

#push the provider information to GitHub

git status
git add  .
git status
git commit -m "create EC2 launch  profile &  ASG”
git push
```

###I. Create Application load balancer and map with Subents
create elb.tf file
>touch elb.tf

code of elb.tf
```
resource "aws_elb" "webapp_load_balancer" {
name            = "Production-WebApp-LoadBalancer"
internal        = false
security_groups = ["${aws_security_group.elb_security_group.id}"]
subnets = [aws_subnet.public_subnets[0].id,
aws_subnet.public_subnets[3].id]

listener {
instance_port = 80
instance_protocol = "HTTP"
lb_port = 80
lb_protocol = "HTTP"
}

health_check {
healthy_threshold   = 5
interval            = 30
target              = "HTTP:80/index.html"
timeout             = 10
unhealthy_threshold = 5
}
}



#output.tf
output "alb_dns" {
value = aws_elb.webapp_load_balancer.dns_name
}


#let us run terraform cmd

Terraform plan —var-file=“production.tfvars”
Terraform apply —var-file=“production.tfvars” —auto-approve

#push the provider information to GitHub

git status
git add  .
git status
git commit -m "Create ALB and allow sshing"  
git push
```

#Deploy Application

###A Install Ansible and its dependencies


SSH into one of the EC2 machine

1. Generate ssh pub key
   Ssh-genkey
2. Copy the public key to other machine
   ssh-copy-id -i ~/.ssh/id_rsa.pub ec2-user@private-ip-of-EC2-machine
3. Then test
   ssh ec2-user@10.0.1.75


####Run below cmd to install Ansible
```
sudo su
yum update -y
amazon-linux-extras enable epel
yum install python3 -y
set python /usr/bin/python3
#echo “ec2-user ALL=(ALL) NOPASSWD: ALL” >> /etc/sudoers
amazon-linux-extras install ansible2 -y
sudo yum install git-all -y
```

###B. Configure Ansible and git
Configuring Inventory
Config  Host file with machine details (private ips) in below path

>/etc/ansible/hosts

Mention all EC2 instances private ip
```
10.0.2.209 ansible_user=ec2-user
10.0.3.126 ansible_user=ec2-user
10.0.4.207 ansible_user=ec2-user
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python2
```


###group_vars Directory
The group_vars directory should contain your Ansible Playbook variables.
>vi  /usr/local/etc/ansible/group_vars/app.yml
```
---
ansible_ssh_user: ec2-user
```

On Git, ***create token*** to be used in the Ansible playbook to pull the git repo
Ansible-vault create secrets.yml

mention gituser and gitpass to create the authentication for git repo

###C. Prepare playbook to deploy NodeJS and its dependencies

Create a shell script to install Node , dependencies and express js
```
###Setup.sh
`code()`
#!/bin/bash
sudo yum update -y
sudo yum dist-upgrade -y
sudo yum install git -y
# Create our file to check for in future
#echo "installed git!" >> /home/ec2-user/installed-git.txt
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
mkdir server && cd server
npm install express
```
###Playbook setupnode.yml to deploy the setup.sh to other EC2 machines
```
---
- hosts: all
  name: test installing git
  become: yes
  remote_user: ec2-user

  tasks:
    - name: nvm
      shell: >
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
      args:
      creates: "{{ ansible_env.HOME }}/.nvm/nvm.sh"


    - script: /home/ec2-user/script/setup.sh --creates /home/ec2-user/installed-git.txt
      register: output
   
    - debug: var=output.stdout_lines
```
run the playbook
> ansible-playbook setupnode.yml

###D. Prepare playbook to deploy Application from GitHub

insall-nodeapp.yml
```
---
- name: Install and Launch the Application
  hosts: all
  vars_files:
    - /etc/ec2-user/secrets.yml
      vars:
    - destdir: /apps/NodeApp
      tasks:

    - name: Download from the GitRepo
      become: yes
      git:
      repo: 'https://{{gituser}}:{{gitpass}}@github.com/rupeshpanwar/Chat-App-using-Socket.io.git'
      dest: "{{ destdir }}"

    - name: Change the ownership of the directory
      become: yes
      file:
      path: /var/www/nodejs
      state: directory
      mode: "u=rw,g=wx,o=rwx"


       - name: Install Dependencies with NPM install command
         shell:
            "npm install"
         args:
            chdir: "{{ destdir }}"
         register: npminstlout

       - name: Debug npm install command
         debug: msg='{{npminstlout.stdout_lines}}'


       - name: Start the App
         async: 10
         poll: 0
         shell:
            "(node app.js > nodesrv.log 2>&1 &)"
         args:
           chdir: "{{ destdir }}"
         register: appstart

       - name: Validating the port is open
         tags: nodevalidate
         wait_for:
           host: "localhost"
           port: 5000
           delay: 10
           timeout: 30
           state: started
           msg: "NodeJS server is not running"
```
run the ansible-playbook

> ansible-playbook insall-nodeapp.yml --ask-vault-pass

test
> http://machineip:5000/index.html

            #Thanks for reading the complete document

