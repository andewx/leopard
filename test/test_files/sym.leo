package test

import "fmt"

const pi = 3.14152927

type Primitive struct{
    @a int
}


type PrimInterface interface{
    GetInt()int
}


func Primtive.GetInt()int{
    return self.a
}


func main(){

begin:
    var myVar *Primitive
    var is_true false
    proto myProto PrimInterface
    prim := new(Primitive)
    if (!is_true){
        is_true = true
        goto begin
    }
}