variable "securiti_token" {
  description = "Token to update pod IP."
}

variable "securiti_endpoint" {
  default     = "https://app.securiti.ai"
  description = "Securiti URL Endpoint."
}

variable "callback_id" {
  description = "Securiti URL Endpoint Callback ID."
}
