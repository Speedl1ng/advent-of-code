fn main() {
    let input = include_str!("../input1.txt");
    let output = process(input);
    dbg!(output);
}

fn process(input: &str) -> String {
    todo!();
    "todo!()".to_string()
}

#[cfg(test)]
mod test {
    use crate::part1::process;

    #[test]
    fn test() {
        let input ="todo!()";
        let result = process(input);
        assert_eq!(result, todo!("test input"))
    }
}