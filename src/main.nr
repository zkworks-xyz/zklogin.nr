mod utils;
mod const;

use dep::std;
use dep::std::hash::poseidon;
use const::{MAX_KEY_CLAIM_NAME_LENGTH, MAX_KEY_CLAIM_VALUE_LENGTH, MAX_AUD_VALUE_LENGTH, CHUNK_SIZE, PACK_WIDTH};
use utils::poseidon;
use utils::str_padded;
use utils::chunk_and_covert_array;

struct JwtTokenPacked<N, K, M> {
    sub_name_packed: [Field; N],
    sub_value_packed: [Field; K],
    aud_value_packed: [Field; M]
}

struct JwtToken<N, K, M> {
    sub_name: str<N>,
    sub_value: str<K>,
    aud_value: str<M>
}

fn main(jwt: JwtToken<3, 3, 9>, salt: Field, addr_seed: pub Field) {
    let jwt_packed = convert_jw_token(jwt);

    let calculated_addr_seed = calculate_addr_seed(
        jwt_packed.sub_name_packed,
        jwt_packed.sub_value_packed,
        jwt_packed.aud_value_packed,
        salt
    );
    assert(addr_seed == calculated_addr_seed);
}

fn calculate_addr_seed<N, K, M>(
    jwt_key_claim_name: [Field; N], // key claim name from jwt: "sub"
    jwt_key_claim_value: [Field; K], // subject key value - represent user id
    aud: [Field; M], // audience key value - represent wallet id
    salt: Field
    ) -> Field {
        poseidon([
            poseidon(jwt_key_claim_name),
            poseidon(jwt_key_claim_value),
            poseidon(aud),
            poseidon([salt]),
        ])
    }

fn convert_jw_token<N, K, M>(raw: JwtToken<N, K, M>) -> JwtTokenPacked<
    (MAX_KEY_CLAIM_NAME_LENGTH / CHUNK_SIZE) + 1,
    (MAX_KEY_CLAIM_VALUE_LENGTH / CHUNK_SIZE) + 1,
    (MAX_AUD_VALUE_LENGTH / CHUNK_SIZE) + 1
> {
    let sub_name_padded: [Field; MAX_KEY_CLAIM_NAME_LENGTH] = str_padded(raw.sub_name);
    let sub_name_packed: [Field; (MAX_KEY_CLAIM_NAME_LENGTH / CHUNK_SIZE) + 1] = chunk_and_covert_array(sub_name_padded, CHUNK_SIZE);

    let sub_value_padded: [Field; MAX_KEY_CLAIM_VALUE_LENGTH] = str_padded(raw.sub_value);
    let sub_value_packed: [Field; (MAX_KEY_CLAIM_VALUE_LENGTH / CHUNK_SIZE) + 1] = chunk_and_covert_array(sub_value_padded, CHUNK_SIZE);

    let aud_value_padded: [Field; MAX_AUD_VALUE_LENGTH] = str_padded(raw.aud_value);
    let aud_value_packed: [Field; (MAX_AUD_VALUE_LENGTH / CHUNK_SIZE) + 1] = chunk_and_covert_array(aud_value_padded, CHUNK_SIZE);

    JwtTokenPacked {
        sub_name_packed,
        sub_value_packed,
        aud_value_packed
    }
}

#[test]
fn test_calculate_addr_seed() {
    let addr_seed = calculate_addr_seed(
        [115, 207397477721056441812414413661424614846155824613720115982633852925168844800], // "sub"
        [18406442779074703367672942673566636046554636526551040, 0, 0, 0], // "123"
        [174474884870278626934955327495491464864294338822144, 0, 0, 0, 0], // "wallet-id"
        0
    );
    let expected_addr_seed = 0x0d758800064ac1b906a80b2840eb3c31cb5b7e4cbdb2a87a0d2b805179243fe0;

    assert(expected_addr_seed == addr_seed);
}

#[test]
fn test_pack_jwt() {
    let jwt_raw = JwtToken {
        sub_name: "sub",
        sub_value: "123",
        aud_value: "wallet-id"
    };

    let result = convert_jw_token(jwt_raw);

    assert([115, 207397477721056441812414413661424614846155824613720115982633852925168844800] == result.sub_name_packed);
    assert([18406442779074703367672942673566636046554636526551040, 0, 0, 0] == result.sub_value_packed);
    assert([174474884870278626934955327495491464864294338822144, 0, 0, 0, 0]  == result.aud_value_packed);
}
