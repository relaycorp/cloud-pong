resource "random_id" "pong_key_id" {
  byte_length = 12
}

resource "random_id" "pong_session_key_id" {
  byte_length = 12
}
