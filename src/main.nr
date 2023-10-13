use dep::std::hash::poseidon;

fn main(x : Field, y : pub Field) {
    assert(x != y);
}

fn calculate_addr_seed(
    jwt_key_claim_name: [Field; 2], // key claim name from jwt: "sub"
    jwt_key_claim_value: [Field; 4], // subject key value - represent user id
    aud: [Field; 5], // audience key value - represent wallet id
    salt: Field
    ) -> Field {
        poseidon::bn254::hash_4([
            poseidon::bn254::hash_2(jwt_key_claim_name),
            poseidon::bn254::hash_4(jwt_key_claim_value),
            poseidon::bn254::hash_5(aud),
            poseidon::bn254::hash_1([salt]),
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
