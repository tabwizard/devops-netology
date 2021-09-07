package main
import "fmt"

func main() {
	fmt.Print("Enter a meters count to feet conversion: ")
	var input float64
	fmt.Scanf("%f", &input)

	fmt.Println(input, "meters = ", MtoF(input), "feet") 
	
	fmt.Println("Minimum is ", Min([]int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}))

	fmt.Println("From 1 to 100:  ", DelThree(1, 100))
}

func MtoF(m float64) (f float64) {
	f = m / 0.3048
	return
}

func Min(x []int) (min int) {
	min = x[0]
	for i := 1; i < len(x); i++ {
		if min > x[i] {
			min = x[i]
		}
	}
	return
}

func DelThree (x int, y int) (out []int) {
	for i := x; i <= y; i++ {
		if i%3 == 0 {
			out = append(out, i)
		}
	}
	return
}
