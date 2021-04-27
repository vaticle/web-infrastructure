workspace(name = "graknlabs_web_infrastructure")

################################
# Load @graknlabs_dependencies #
################################

load("//dependencies/graknlabs:repositories.bzl", "graknlabs_dependencies")
graknlabs_dependencies()

# Load //builder/java
load("@graknlabs_dependencies//builder/java:deps.bzl", java_deps = "deps")
java_deps()

#####################################################################
# Load @graknlabs_bazel_distribution from (@graknlabs_dependencies) #
#####################################################################

load("@graknlabs_dependencies//distribution:deps.bzl", "graknlabs_bazel_distribution")
graknlabs_bazel_distribution()

load("@graknlabs_bazel_distribution//packer:deps.bzl", deploy_packer_dependencies="deps")
deploy_packer_dependencies()

load("@graknlabs_bazel_distribution//common:deps.bzl", "rules_pkg")
rules_pkg()

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

