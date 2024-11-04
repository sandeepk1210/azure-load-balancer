# Azure Load Balancer with Virtual Machines

This Terraform configuration sets up an Azure Load Balancer to distribute traffic across multiple Windows Virtual Machines (VMs). The configuration includes public IP assignment, backend address pool setup, health probes, and load balancing rules to ensure high availability for a web application hosted on the VMs.

## Resources Included

- **Public IP Address**: A static public IP for the Load Balancer.
- **Load Balancer**: A standard Azure Load Balancer configured for TCP traffic.
- **Backend Address Pool**: Associates VMs with the Load Balancer for traffic distribution.
- **Network Interfaces**: Configures NICs for each VM and associates them with the Load Balancer.
- **Health Probe**: Monitors the health of VMs by checking connectivity on port 80.
- **Load Balancer Rule**: Forwards traffic from the Load Balancer to the backend VMs.
- **Windows VMs**: Creates a specified number of Windows VMs with IIS installed.
- **Network Security Group**: Allows inbound traffic on ports 80 (HTTP) and 3389 (RDP).

## Usage

1. **Install Terraform**: Ensure you have Terraform installed on your machine. If not, download it from [terraform.io](https://www.terraform.io/downloads.html).

2. **Set Up Azure Provider**: Ensure that your Azure credentials are set up in your environment.

3. **Initialize Terraform**: Run the following command to initialize your Terraform workspace:

   ```bash
   terraform init
   ```

4. **Plan the Deployment**: To see the changes that will be made, run:

   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

5. **Apply the Configuration**: Deploy the resources with:

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

6. **Access the Application**: Once deployed, access the Default.html page via the Load Balancer's public IP.

## Outputs

The configuration provides the following outputs:

- Load Balancer Public IP: The public IP address of the Load Balancer.
- VM Private IPs: The private IP addresses of the created VMs.
- Load Balancer ID: The resource ID of the Load Balancer.
- Backend Pool ID: The ID of the backend address pool.
- Network Interface IDs: IDs of the associated NICs.
