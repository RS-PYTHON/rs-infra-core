output "registry-url" {
  value = ovh_cloud_project_containerregistry.myregistry.url
}

output "user" {
  value = ovh_cloud_project_containerregistry_user.myuser.user
}

output "password" {
  value = ovh_cloud_project_containerregistry_user.myuser.password
  sensitive = true
}