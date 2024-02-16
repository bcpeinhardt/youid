import youid/uuid
import youid/id.{type Id, type IdGenerator}
import gleeunit/should
import gleeunit
import gleam/string

pub fn main() {
  gleeunit.main()
}

pub fn v1_from_string_test() {
  let assert Ok(uuid) = uuid.from_string("49cac37c-310b-11eb-adc1-0242ac120002")
  uuid
  |> uuid.version
  |> should.equal(uuid.V1)
}

pub fn v4_from_string_test() {
  let assert Ok(uuid) = uuid.from_string("16b53fc5-f9a7-4f6b-8180-399ab0986250")
  uuid
  |> uuid.version
  |> should.equal(uuid.V4)
}

pub fn unknown_version_test() {
  let assert Ok(uuid) = uuid.from_string("16b53fc5-f9a7-0f6b-8180-399ab0986250")
  uuid
  |> uuid.version
  |> should.equal(uuid.VUnknown)
}

pub fn too_short_test() {
  "16b53fc5-f9a7-4f6b-8180-399ab098625"
  |> uuid.from_string()
  |> should.equal(Error(Nil))
}

pub fn too_long_test() {
  "16b53fc5-f9a7-4f6b-8180-399ab09862500"
  |> uuid.from_string()
  |> should.equal(Error(Nil))
}

pub fn non_hex_char_test() {
  "16z53fc5-f9a7-4f6b-8180-399ab0986250"
  |> uuid.from_string()
  |> should.equal(Error(Nil))
}

//
// V1 Tests
//
pub fn v1_roundtrip_test() {
  let uuid = uuid.v1()
  uuid
  |> uuid.to_string()
  |> uuid.from_string()
  |> should.equal(Ok(uuid))
}

pub fn v1_own_version_test() {
  uuid.v1()
  |> uuid.version
  |> should.equal(uuid.V1)
}

pub fn v1_own_variant_test() {
  uuid.v1()
  |> uuid.variant
  |> should.equal(uuid.Rfc4122)
}

pub fn v1_custom_node_and_clock_seq() {
  let node = "B6:00:CD:CA:75:C7"
  let node_no_colons = "B600CDCA75C7"
  let clock_seq = 15_000
  let assert Ok(uuid) =
    uuid.v1_custom(uuid.CustomNode(node), uuid.CustomClockSeq(<<clock_seq:14>>))

  uuid
  |> uuid.node
  |> should.equal(node_no_colons)

  uuid
  |> uuid.clock_sequence
  |> should.equal(clock_seq)
}

//
// V3 Tests
//
pub fn v3_dns_namespace_test() {
  let assert Ok(uuid) = uuid.v3(uuid.dns_uuid(), <<"my.domain.com":utf8>>)
  uuid.to_string(uuid)
  |> should.equal("03BF0706-B7E9-33B8-AEE5-C6142A816478")
}

pub fn v3_dont_crash_on_bad_name_test() {
  uuid.v5(uuid.dns_uuid(), <<1:1>>)
  |> should.equal(Error(Nil))
}

//
// V4 Tests
//
pub fn v4_can_validate_self_test() {
  let assert Ok(uuid) =
    uuid.v4()
    |> uuid.to_string()
    |> uuid.from_string()

  uuid
  |> uuid.version
  |> should.equal(uuid.V4)

  uuid
  |> uuid.variant
  |> should.equal(uuid.Rfc4122)
}

//
// V5 Tests
//
pub fn v5_dns_namespace_test() {
  let assert Ok(uuid) = uuid.v5(uuid.dns_uuid(), <<"my.domain.com":utf8>>)
  uuid
  |> uuid.to_string
  |> should.equal("016C25FD-70E0-56FE-9D1A-56E80FA20B82")
}

pub fn v5_dont_crash_on_bad_name_test() {
  uuid.v5(uuid.dns_uuid(), <<1:1>>)
  |> should.equal(Error(Nil))
}

//
// Id tests
//

pub type User

pub fn new_user_id() -> Id(User) {
  id.format(prefixed_with: "orgname-user")()
}

pub fn id_usage_test() {
  let user_1 = new_user_id()

  user_1
  |> id.to_string
  |> string.starts_with("orgname-user-")
  |> should.equal(True)

  let backing_id =
    user_1
    |> id.to_string
    |> string.drop_left(13)
  uuid.from_string(backing_id)
  |> should.be_ok
}
