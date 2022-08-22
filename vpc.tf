provider "aws" {
  region     = "us-east-1"
}


##################vpc block###############

resource "aws_vpc" "myVpc" {
  cidr_block = "10.0.0.0/16"
}



###################internet g/w#################
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "myigw"
  }
}



#####################subnet ##################
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myVpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet"
  }
}

########################route table ##############

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myVpc.id

  route = []

  tags = {
    Name = "myrt"
  }
}



##########################route ######################
resource "aws_route" "route" {
  route_table_id            = aws_route_table.myrt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.myigw.id
  depends_on                = [aws_route_table.myrt]  ## is da matlab he ki jido tak route table na create hove udo tak eh create na hove  
}



###########################route table association #############
##is vich apa route table nu subnet nal attach krna he #####
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id     #subnat id or reference          
  route_table_id = aws_route_table.myrt.id    #route table id or reference
}



#################security group########################
resource "aws_security_group" "mysg" {
  name        = "allow all traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    description      = "All traffic"
    from_port        = 0 # allow all ports 
    to_port          = 0 # allow all ports 
    protocol         = "-1" # for allow all traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow traffic"
  }
}



############### create ec2 instance ##############
resource "aws_instance" "myec2" {
  ami           = "ami-090fa75af13c156b4" # us-east-1
  subnet_id   = aws_subnet.mysubnet.id
  instance_type = "t2.micro"
  key_name   = "linux-dell"
}


resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id      = aws_vpc.myVpc.id
  dhcp_options_id = "dopt-0d91982f51cd8ec11"
}
