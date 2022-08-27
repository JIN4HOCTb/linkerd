locals {
  linkerd_control_plane_sets = {
    "identityTrustAnchorsPEM" : tls_self_signed_cert.ca.cert_pem,
    "identity.issuer.tls.crtPEM" : tls_locally_signed_cert.issuer.cert_pem,
    "identity.issuer.tls.keyPEM" : tls_private_key.issuer.private_key_pem
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "linkerd_crds" {
  name       = "linkerd-crds"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-crds"

  namespace        = "linkerd"
  create_namespace = true
}

resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-control-plane"

  namespace = "linkerd"

  dynamic "set" {
    for_each = local.linkerd_control_plane_sets

    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    helm_release.linkerd_crds
  ]
}

resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-viz"

  namespace = "linkerd"
}
