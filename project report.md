# QueenOge’s AWS VPC Multi-Tier Architecture Deployment Project Report

## Project Overview
This project demonstrates the deployment and automation of a secure multi-tier architecture on AWS using AWS CLI and Bash scripting. The architecture consists of three layers: Web, App, and DB, each isolated in its own subnet with strict security controls. The entire setup was tested through SSH access and internal connectivity verification.

---

## AWS CLI Configuration

To set up AWS CLI for this project, I used a named profile called `queenoge`.

```bash
aws configure --profile queenoge
````

* Access Key and Secret: 
* Region: `us-east-1`
* Output Format: `json`

All subsequent commands were executed using this named profile.

---

## GitHub Folder Structure

```
vpc-multi-tier-architecture-queenoge/
├── scripts/           # All Bash automation scripts
├── keys/              # SSH key pair (excluded using .gitignore)
├── screenshots/       # SSH and ping test confirmations
├── README.md          # Project summary
├── ABOUT.md           # Story behind the project
├── Project_Report.md  # This documentation file
```

---

## VPC and Subnets Creation

* VPC CIDR Block: `10.0.0.0/16`
* Subnets Created:

  * Web Subnet: `10.0.1.0/24` (Public)
  * App Subnet: `10.0.2.0/24` (Private)
  * DB Subnet: `10.0.3.0/24` (Private)
* An Internet Gateway was attached to the VPC.
* A route table was created and associated with the Web Subnet.
* Public IP auto-assignment was enabled on the Web Subnet.

---

## Key Pair Creation

```bash
aws ec2 create-key-pair \
  --key-name QueenOge-KeyPair \
  --query 'KeyMaterial' \
  --output text \
  --profile queenoge > keys/QueenOge-KeyPair.pem

chmod 400 keys/QueenOge-KeyPair.pem
```

This key pair was used to SSH into the EC2 instances.

---

## Security Group Configuration

Three security groups were created for each tier:

* Web Security Group

  * Inbound: TCP 22 (SSH), TCP 80 (HTTP) from anywhere

* App Security Group

  * Inbound: TCP 80 and TCP 22 from the Web subnet

* DB Security Group

  * Inbound: TCP 3306 and TCP 22 from the App subnet

Outbound traffic was allowed by default for all groups.

---

## EC2 Instance Launch

Instances were launched using the Amazon Linux 2 AMI (`ami-0c101f26f147fa7fd`) with instance type `t2.micro`.

* Web Instance

  * Public IP: `100.27.229.251`
  * Private IP: `10.0.1.x`

* App Instance

  * Private IP: `10.0.2.179`

* DB Instance

  * Private IP: `10.0.3.226`

Each instance was placed in its respective subnet and attached to the corresponding security group.

---

## Connectivity and SSH Tests

SSH into Web Server:

```bash
ssh -i keys/QueenOge-KeyPair.pem ec2-user@100.27.229.251
```

Successfully connected.

Ping from Web to App:

```bash
ping 10.0.2.179
```

Ping passed.

Ping from App to DB:

```bash
ping 10.0.3.226
```

Ping passed.

---

## Full Automation Script

All resources above were fully automated with a single Bash script:
`scripts/full-deploy.sh`

This script automates:

* VPC
* Subnets
* Internet Gateway
* Route Table
* Security Groups
* Key Pair
* EC2 Instances

One script to deploy the entire architecture from scratch.

---

## Design Decisions

* Followed a three-tier design for clean separation and best practice.
* Used individual security groups for each tier to enforce least privilege.
* Used the Web instance as a jump host to access private instances.
* Applied AWS CLI scripting to enforce Infrastructure as Code principles.

---

## Challenges and Resolutions

| Challenge                 | Solution                            |
| ------------------------- | ----------------------------------- |
| App/DB had no public IPs  | Used Web instance as SSH jump host  |
| SSH key permission denied | Resolved with `chmod 400` on `.pem` |
| Connection timeouts       | Adjusted inbound rules in SGs       |
| Git push authentication   | Used GitHub personal access token   |

---

## Final Outcome

| Component          | Status    |
| ------------------ | --------- |
| VPC and Subnets    | Completed |
| Security Groups    | Completed |
| EC2 Instances      | Running   |
| SSH and Ping Tests | Passed    |
| Full Automation    | Achieved  |

---

## Deliverables

* Bash scripts for infrastructure provisioning
* SSH and ping test screenshots
* Markdown documentation:

  * `README.md`
  * `Project_Report.md`
  * `ABOUT.md`
* Organized GitHub folder structure

---

## Conclusion

This project helped me bring together my foundational cloud skills into one practical, testable solution. From scripting infrastructure to securing connections and verifying access, I demonstrated full control of AWS CLI-based deployment. It proves my growth and readiness for real-world cloud engineering tasks.

---

Submitted by: **Anyalewechi Esther**

Project: Deploy a VPC Multi-Tier Architecture and Enforce Access Control
