package main
import "core:fmt"

Foo :: struct {
	name: bool,
	age: int,
}

main :: proc() {
	f: Foo
	
	fmt.println(f)
}