variable "config" {}

variable "arm_client_id" {
  description = "Azure client id"
  type        = string
  default     = null
}

variable "arm_client_secret" {
  description = "Azure secret id"
  type        = string
  default     = null
}

variable "arm_subscription_id" {
  description = "Azure subscription id"
  type        = string
  default     = null
}

variable "arm_tenant_id" {
  description = "Azure tenant id"
  type        = string
  default     = null
}
