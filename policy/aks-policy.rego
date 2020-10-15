package main

has_field(obj, field) {
    obj[field]
}

deny[msg] {
    private := input.resource.azurerm_kubernetes_cluster[privateaks].private_cluster_enabled
    private != "false"
    msg = sprintf("Cluster `%v` is using Public API rather than Private API Cluster", [privateaks])
}

deny[msg] {
    network_model = input.resource.azurerm_kubernetes_cluster[name]
    has_field(network_model, "network_profile")
    network_model.network_profile.network_plugin != "kubenet"
    msg = sprintf("AKS Cluster `%v` is using Network Plugin Kubenet, which is not allowed. Please use azure CNI", [name])
}

#deny[msg] {
#    rule := input.resource.aws_security_group_rule[name]
#    rule.type == "ingress"
#    contains(rule.cidr_blocks[_], "0.0.0.0/0") 
#    msg = sprintf("ASG `%v` defines a fully open ingress", [name])
#}

#deny[msg] {
#    count(resource_changes) > 0
#    msg := sprintf("resource type %v is not pre-approved", [resource_changes[]])
#}