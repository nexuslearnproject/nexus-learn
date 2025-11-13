variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_origin_id" {
  description = "Origin ID for ALB (for API proxy)"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate (leave empty for CloudFront default)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe
}

