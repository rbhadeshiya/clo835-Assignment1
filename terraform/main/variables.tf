# ASG Instance Type
variable "type" {
  default = {
    "dev" = "t2.micro"
  }
  type        = map(string)
  description = "Dev Environment Instances Type"
}




# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "dev environment"
}