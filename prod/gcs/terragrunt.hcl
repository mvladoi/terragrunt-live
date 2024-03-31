terraform {
  source ="git::git@github.com:mvladoi/gcp-modules.git//gcs?ref=v1.0.0"
}
inputs = {
  names = ["prod-terra"]
}