package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:math"

my_allocator_proc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode,
                           size, alignment: int,
                           old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, mem.Allocator_Error) {

	allocator := cast(^My_Allocator)allocator_data;

	switch mode {
	case .Alloc: {
		if allocator.offset + size > allocator.capactiy {
			fmt.println("no more mem")
			return []byte{}, .Out_Of_Memory
		}

		start := math.next_power_of_two(allocator.offset)
		end := start + size

		allocator.offset = end 

		return allocator.memory[start:end], nil
	}

	case .Resize:
		return mem.default_resize_bytes_align(mem.byte_slice(old_memory, old_size), size, alignment, my_allocator(allocator))

	case .Free:
		return nil, .Mode_Not_Implemented

	case .Free_All: {
		allocator.offset = 0 
		return nil, nil
	}

	case .Query_Features:
		fallthrough

	case .Query_Info:
		return nil, .Mode_Not_Implemented
	}	

	return nil, nil
}

My_Allocator :: struct {
   offset: int,
   capactiy: int,
   memory: []byte,
}

my_allocator :: proc(allocator: ^My_Allocator) -> mem.Allocator {
	return mem.Allocator {
			procedure = my_allocator_proc,
			data      = allocator,
	}
}

main :: proc() {
	TOTAL_MEMORY := mem.kilobytes(1)

	ma: My_Allocator
	ma.capactiy = TOTAL_MEMORY

	err: mem.Allocator_Error
	ma.memory, err = mem.alloc_bytes(TOTAL_MEMORY)

	assert(err == .None, "Unable to allocate memory")

	context.allocator = my_allocator(&ma)

	x: [dynamic]int

	append(&x, 10)
	append(&x, 20)
	append(&x, 30)
	append(&x, 40)

	fmt.println(x)
}