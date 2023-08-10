terraform {
  backend "remote" {
    organization = "Relaycorp"

    workspaces {
      name = "cloud-pong"
    }
  }
}
