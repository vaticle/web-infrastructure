load("@graknlabs_bazel_distribution//packer:rules.bzl", "deploy_packer")
load("@graknlabs_bazel_distribution//gcp:rules.bzl", "assemble_gcp")

assemble_gcp(
    name = "assemble-gcp-consul",
    install = "//consul/images:install-consul.sh",
    project_id = "vaticle-web-prod",
    disable_default_service_account = True,
    image_name = "consul-{{user `version`}}",
    source_image_family = "ubuntu-2004-lts",
    image_family = "web",
    zone = "europe-west2-b"
)

deploy_packer(
    name = "deploy-gcp-consul",
    target = ":assemble-gcp-consul",
)
