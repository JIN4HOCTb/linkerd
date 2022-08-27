provider "tls" {}

# CA ========
resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  validity_period_hours = 12 * 30 * 24 // 1 year
  is_ca_certificate     = true

  allowed_uses = []
}

# Issuer ====
resource "tls_private_key" "issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "name" {
  private_key_pem = tls_private_key.issuer.private_key_pem

  subject {
    common_name  = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "issuer" {
  cert_request_pem   = tls_cert_request.name.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 11 * 30 * 24 // 11 months
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing"
  ]
}