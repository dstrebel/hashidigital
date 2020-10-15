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
    private := input.resource.azurerm_kubernetes_cluster[privateaks].location
    private != "euwest"
    msg = sprintf("Cluster `%v` is using EUWEST, whuch is disallowed by corp policy", [privateaks])
}

deny[msg] {
    network_model = input.resource.azurerm_kubernetes_cluster[name]
    has_field(network_model, "network_profile")
    network_model.network_profile.network_plugin == "kubenet"
    msg = sprintf("AKS Cluster `%v` is using Network Plugin Kubenet, which is not allowed. Please use azure CNI", [name])
}