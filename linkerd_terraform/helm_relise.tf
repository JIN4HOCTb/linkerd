# data "helm_template" "linkerd" {
#   name             = "linkerd"
#   namespace        = "linkerd"
#   repository       = "https://helm.linkerd.io/stable"
#   chart            = "linkerd2"
#   create_namespace = true
#}

resource "helm_release" "linkerd" {
  name             = "linkerd"
  repository       = "https://helm.linkerd.io/stable" #data.helm_template.linkerd.repository
  chart            = "linkerd2"                       #data.helm_template.linkerd.chart
  //`namespace        = "linkerd"
  timeout          = 10000
  max_history      = 10
  create_namespace = true
  cleanup_on_fail  = true
  recreate_pods    = true
  wait_for_jobs    = true

  set {
    name  = "global.identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trustanchor_cert.cert_pem
  }

  set {
    name  = "identity.issuer.crtExpiry"
    value = tls_locally_signed_cert.issuer_cert.validity_end_time
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer_cert.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer_key.private_key_pem
  }
}
