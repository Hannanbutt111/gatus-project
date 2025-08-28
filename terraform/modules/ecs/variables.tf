variable "vpc_id" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "alb_target_arn" {
  type = string
}
