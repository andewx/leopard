package test

import "github.com/andewx/leo/test/packages/math"
import "fmt"


func main(){
    x := math.Add(1,2)
    fmt.printf("Equals %d", x)
}