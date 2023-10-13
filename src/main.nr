mod utils;

use dep::std::hash::poseidon;
use utils::poseidon;

struct JwtToken<N, K, M> {
    sub_name_packed: [Field; N],
    sub_value_packed: [Field; K],
    aud_value_packed: [Field; M]
}

fn main<N, K, M>(jwt: JwtToken<N, K, M>, salt: Field, addr_seed: pub Field) {
    let calculated_addr_seed = calculate_addr_seed(
        jwt.sub_name_packed,
        jwt.sub_value_packed,
        jwt.aud_value_packed,
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

#[test]
fn test_calculate_addr_seed() {
    let addr_seed = calculate_addr_seed(
        [115,207397477721056441812414413661424614846155824613720115982633852925168844800],
        [18406442779074703367672942673566636046554636526551040,0,0,0],
        [174474884870278626934955327495491464864294338822144,0,0,0,0],
        0
    );
    let expected_addr_seed = 0x0d758800064ac1b906a80b2840eb3c31cb5b7e4cbdb2a87a0d2b805179243fe0;

    assert(expected_addr_seed == addr_seed);
}
