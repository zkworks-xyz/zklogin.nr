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

