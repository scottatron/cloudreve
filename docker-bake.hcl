group "default" {
  targets = ["cloudreve-amd64"]
}

target "cloudreve-amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  tags       = ["zot.tron.haus/cloudreve:4.15.0-next"]
  output     = ["type=registry"]

  contexts = {
    cloudreve-binary = "dist/cloudreve_linux_amd64_v1"
  }
}
