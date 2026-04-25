variable "VERSION" {
  default = "4.15.0-next"
}

variable "COMMIT" {
  default = "0000000"
}

group "default" {
  targets = ["cloudreve-amd64"]
}

target "cloudreve-amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  tags       = ["zot.tron.haus/cloudreve:${VERSION}"]
  output     = ["type=registry"]
  args = {
    VERSION = VERSION
    COMMIT  = COMMIT
  }
}
