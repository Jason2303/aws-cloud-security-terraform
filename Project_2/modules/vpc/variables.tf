variable "vpc_CIDR" {
  type        = string
  description = "CIDR range"
  default     = "10.0.0.0/16"
}

variable "private_CIDR" {
  type        = string
  description = "private CIDR range"
  default     = "10.0.1.0/24"
}

variable "public_CIDR" {
  type        = string
  description = "public CIDR range"
  default     = "10.0.2.0/24"
}

variable "public_2_CIDR" {
  type        = string
  description = "public CIDR range"
  default     = "10.0.3.0/24"
}

variable "route_CIDR" {
  type        = string
  description = "route CIDR range"
  default     = "0.0.0.0/0"
}