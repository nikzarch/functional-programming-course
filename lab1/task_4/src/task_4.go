package main

import (
	"fmt"
	"strconv"
)

func main() {
	maxProduct := 0
	for i := 100; i < 1000; i++ {
		for j := 100; j < 1000; j++ {
			product := i * j
			if isPalindrome(product) && product > maxProduct {
				maxProduct = product
			}
		}
	}
	fmt.Println(maxProduct)
}

func isPalindrome(x int) bool {
	s := strconv.Itoa(x)
	for i := 0; i < len(s)/2; i++ {
		if s[i] != s[len(s)-1-i] {
			return false
		}
	}
	return true
}
