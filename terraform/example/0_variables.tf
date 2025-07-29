variable "region" {
  description = "The region to deploy to"
  default     = "ap-northeast-2"
  type        = string
}

variable "cluster" {
  description = "The name of the cluster to create"
  default     = "tutorial-eks"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy to"
  type        = string
}

variable "label" {
  description = "The label to apply to all resources in this example"
  default     = "nginx"
  type        = string
}

variable "content" {
  description = "The content to display on the nginx page"
  type        = string
}