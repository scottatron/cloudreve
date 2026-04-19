group "default" {
  targets = ["cloudreve-amd64"]
}

target "cloudreve-amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  tags       = ["registry.snowy-vibe.ts.net/cloudreve:4.15.0-next"]
  output     = ["type=registry,name=registry.snowy-vibe.ts.net/cloudreve"]

  contexts = {
    cloudreve-binary = "dist/cloudreve_linux_amd64_v1"
  }
}
