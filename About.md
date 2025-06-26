# About This Project – QueenOge’s VPC Multi-Tier Architecture Journey

## Why I Built This Project
I built this project as a way to push myself beyond just learning cloud theory — I wanted to get my hands dirty by building something real, something I could explain and automate. As someone passionate about cloud and DevOps, I needed a project that allowed me to apply skills like scripting, infrastructure deployment, and access control.

Creating a secure, multi-tier architecture on AWS was the perfect challenge. It tested my understanding of VPCs, subnets, routing, security groups, and EC2 provisioning all while building the discipline of automation and documentation.

## What I Learned
- How to provision cloud infrastructure using the AWS CLI instead of the AWS Console  
- How to write reusable Bash scripts for deploying VPCs, subnets, and EC2 instances  
- How to manage access using key pairs, SSH, and security group rules  
- How to debug SSH and network issues with subnet communication  
- How to test connectivity between tiers (Web → App → DB)  
- How to organize a GitHub-ready project with scripts, keys (excluded), and docs  

## Challenges I Faced
- SSH errors and key permission issues (solved with `chmod 400`)  
- EC2 instance access failures (solved by configuring public IPs and security rules)  
- Subnet communication issues (solved through ping tests and security group isolation)  
- GitHub push issues with HTTPS (solved using a personal access token and `.gitignore`)  

Each obstacle made me more confident, and I documented everything to ensure I could explain and replicate it.

## What You Can Learn from This Project
If you’re new to DevOps, cloud, or AWS, this project is a practical walkthrough of deploying infrastructure the way professionals do:
- Using the command line, not just the console  
- Structuring a project for GitHub visibility  
- Writing infrastructure as code (IaC) in Bash  
- Verifying communication between cloud resources securely  
- Practicing real-world deployment with public/private tiers  

## My Message
This project represents more than technical skill, it’s my confidence builder. It proves that women in cloud can automate infrastructure, write scripts, troubleshoot SSH, and build secure systems from scratch.

I hope it encourages someone else to try even if it seems intimidating at first.
