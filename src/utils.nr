use dep::std;
use dep::std::hash::poseidon;

fn str_to_field<N>(input: str<N>) -> Field {
    let input_as_field: [Field; N] = input.as_bytes().map(|x:u8| x as Field);
    std::hash::hash_to_field(input_as_field)
}

fn str_padded<N, M>(input: str<N>) -> [Field; M] {
    assert(N as u8 < M as u8);
    let x: [Field; N] = input.as_bytes().map(|i:u8| i as Field);

    let mut result = [0; M];
    for i in 0..x.len() {
        result[i] = x[i];
    }

    result
}

fn chunk_and_covert_array<N, M>(input: [Field; N], chunk_size: u8) -> [Field; M] {
    let mut chunk_position = 0;
    let mut chunk = 0;
    let mut result = [0; M];
    for i in 0..input.len() {
        if ((i as u8) % chunk_size == 0) {
            chunk_position = 0;
            chunk += 1;
        } else {
            chunk_position += 1;
        }
        let ii = input.len() - 1 - i;
        result[M - chunk] += input[ii] * 2.pow_32(chunk_position * 8);
    }
    result
}

fn poseidon<N>(input: [Field; N]) -> Field {
    let mut result: Field = 0 ;
    if input.len() == 1 {
        result = poseidon::bn254::hash_1([input[0]]);
    } else if input.len() == 2 {
        result = poseidon::bn254::hash_2([input[0], input[1]]);
    } else if input.len() == 3 {
        result = poseidon::bn254::hash_3([input[0], input[1], input[2]]);
    } else if input.len() == 4 {
        result = poseidon::bn254::hash_4([input[0], input[1], input[2], input[3]]);
    } else if input.len() == 5 {
        result = poseidon::bn254::hash_5([input[0], input[1], input[2], input[3], input[4]]);
    } else {
    }
    result
}

// Unit tests

#[test]
fn test_str_to_field() {
    let expected_field_element: Field = 0x19213bacc58dee6dbde3ceb9a47cbb330b3d86f8cca8997eb00be456f140ca25;
    assert(str_to_field("hello") == expected_field_element);
}

#[test(should_fail)]
fn test_str_to_field_invalid_hash() {
    assert(str_to_field("hello") == 0x00);
}

#[test]
fn test_str_padded() {
    let sub_padded = str_padded("sub");
    assert([0x73, 0x75, 0x62, 0, 0, 0, 0, 0, 0, 0] == sub_padded);
}

#[test]
fn test_chunk_and_covert_array() {
    assert([0x01, 0x0203, 0x0405] == chunk_and_covert_array([1, 2, 3, 4, 5], 2));
    assert([0x0a0b0c, 0x0d0e0f1011, 0x1213141516] == chunk_and_covert_array([10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22], 5));
}

#[test]
fn test_poseidon() {
    assert(0x29176100eaa962bdc1fe6c654d6a3c130e96a4d1168b33848b897dc502820133 == poseidon([1]));
    assert(0x115cc0f5e7d690413df64c6b9662e9cf2a3617f2743245519e19607a4417189a == poseidon([1, 2]));
    assert(0x0e7732d89e6939c0ff03d5e58dab6302f3230e269dc5b968f725df34ab36d732 == poseidon([1, 2, 3]));
    assert(0x299c867db6c1fdd79dcefa40e4510b9837e60ebb1ce0663dbaa525df65250465 == poseidon([1, 2, 3, 4]));
    assert(0x0dab9449e4a1398a15224c0b15a49d598b2174d305a316c918125f8feeb123c0 == poseidon([1, 2, 3, 4, 5]));
}
