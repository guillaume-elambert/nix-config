{pkgs, ...}: {
  # Collection of useful OPS tools
  home.packages = with pkgs; [
    jq
    yq
    kubectl
    kubectx
    kustomize
    k9s
    kubernetes-helm
    helmfile
    ansible
    terraform
  ];
}
