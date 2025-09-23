package main

import (
	"fmt"
)

func cycleLength(d int) int {
	seen := make(map[int]int) // remainder, step
	remainder := 1
	step := 0

	for remainder != 0 {
		if firstStep, ok := seen[remainder]; ok {
			return step - firstStep
		}
		seen[remainder] = step
		remainder = (remainder * 10) % d
		step++
	}

	return 0
}

func findLongestRecurring(limit int) int {
	maxLen := 0
	bestD := 0

	for d := 2; d < limit; d++ {
		length := cycleLength(d)
		if length > maxLen {
			maxLen = length
			bestD = d
		}
	}

	return bestD
}

func main() {
	d := findLongestRecurring(1000)
	fmt.Println(d)
}
