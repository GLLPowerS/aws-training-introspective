#resource "kubernetes_storage_class_v1" "gp3_csi_default" {
#  metadata {
#    name = "gp3-csi"
#    annotations = {
#      "storageclass.kubernetes.io/is-default-class" = "true"
#    }
#  }
#
#  storage_provisioner = "ebs.csi.aws.com"
#  volume_binding_mode = "WaitForFirstConsumer"
#
#  parameters = {
#    type = "gp3"
#  }
#
#  depends_on = [module.eks]
#}
