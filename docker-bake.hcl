variable "VERSION" {
  default = "4.15.0-next"
}

variable "COMMIT" {
  default = "0000000"
}

group "default" {
  targets = ["cloudreve-amd64"]
}

target "cloudreve-binary-amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "cloudreve-binary-export"
  platforms  = ["linux/amd64"]
  output     = ["type=local,dest=dist/cloudreve_linux_amd64_v1"]

  args = {
    VERSION = VERSION
    COMMIT  = COMMIT
  }
}

target "cloudreve-amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  tags       = ["zot.tron.haus/cloudreve:${VERSION}"]
  output     = ["type=registry"]

  contexts = {
    cloudreve-binary = "dist/cloudreve_linux_amd64_v1"
  }
}
