use dep::std;

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
    let mut multiplier = 1;
    let mut result = [0; M];
    for i in 0..input.len() {
        if ((i as u8) % chunk_size == 0) {
            chunk_position = 0;
            chunk += 1;
            multiplier = 1;
        } else {
            chunk_position += 1;
            multiplier *= 256;
        }
        let ii = input.len() - 1 - i;
        result[3 - chunk] += input[ii] * multiplier;
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