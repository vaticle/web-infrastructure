workspace(name = "graknlabs_web_infrastructure")

################################
# Load @vaticle_dependencies #
################################

load("//dependencies/graknlabs:repositories.bzl", "vaticle_dependencies")
vaticle_dependencies()

# Load //builder/java
load("@vaticle_dependencies//builder/java:deps.bzl", java_deps = "deps")
java_deps()

#####################################################################
# Load @vaticle_bazel_distribution from (@vaticle_dependencies) #
#####################################################################

load("@vaticle_dependencies//distribution:deps.bzl", "vaticle_bazel_distribution")
vaticle_bazel_distribution()

load("@vaticle_bazel_distribution//packer:deps.bzl", deploy_packer_dependencies="deps")
deploy_packer_dependencies()

load("@vaticle_bazel_distribution//common:deps.bzl", "rules_pkg")
rules_pkg()

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

