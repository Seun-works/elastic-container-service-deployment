variable "subnets" {
  description = "A list of subnets"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    visibility        = string
  }))

  default = {
    "subnet_1" = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "us-east-1a"
      visibility        = "public"

    },
    "subnet_2" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1b"
      visibility        = "public"
    },
    "subnet_3" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1c"
      visibility        = "public"
    },
    "subnet_4" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1a"
      visibility        = "private"
    },
    "subnet_5" = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "us-east-1b"
      visibility        = "private"
    },
    "subnet_6" = {
      cidr_block        = "10.0.5.0/24"
      availability_zone = "us-east-1c"
      visibility        = "private"
    },

  }
}