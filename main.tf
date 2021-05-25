resource "oci_identity_user" "user1" {
  name           = "tf-example-user"
  description    = "user created by terraform"
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_user_capabilities_management" "user1-capabilities-management" {
  user_id                      = oci_identity_user.user1.id
  can_use_auth_tokens          = "false"
  can_use_console_password     = "false"
  can_use_smtp_credentials     = "false"
}

data "oci_identity_users" "users1" {
  compartment_id = oci_identity_user.user1.compartment_id

  filter {
    name   = "name"
    values = ["tf-example-user"]
  }
}

output "users1" {
  value = data.oci_identity_users.users1.users
}

resource "oci_identity_api_key" "api-key1" {
  user_id = oci_identity_user.user1.id

  key_value = <<EOF
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz1heV5c4HcS03Pt3CGbp
AyKTecIj4QoJwCDXDe9QNxrphYTWQTXDUX8X62KjGltN9mbQLFB3/yEZmLlAZ71O
FxK/cWQcgXVw6U1/3KJMkIY1h5naGcmcesVMDDP9Up9A50N0MVkMxr8Nyez3QPUV
yd/GqT9OEXfMtp838Zqr2XI+vCnXxIy7yXqak4udnI6aGwjCWs8nzNtR7S4CzDgO
c8Rzf7Qj/LmvqRhNmpP0gh2UKN3Mj1WD1bgDAahWKZ4mML4ZzR7z7SASCXYFPNvF
MHg8g6gD/hQZBUKSKhnJUHUrzRdoZ+INkFVt3ApKQ6n+mreGLTv7gT21eldY99fr
5wIDAQAB
-----END PUBLIC KEY-----
EOF

}

output "user-api-key" {
  value = oci_identity_api_key.api-key1.key_value
}

resource "oci_identity_customer_secret_key" "customer-secret-key1" {
  user_id      = oci_identity_user.user1.id
  display_name = "tf-example-customer-secret-key"
}

data "oci_identity_customer_secret_keys" "customer-secret-keys1" {
  user_id = oci_identity_customer_secret_key.customer-secret-key1.user_id
}

output "customer-secret-key" {
  value = [
    oci_identity_customer_secret_key.customer-secret-key1.key,
    data.oci_identity_customer_secret_keys.customer-secret-keys1.customer_secret_keys,
  ]
}
