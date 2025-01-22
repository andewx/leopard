package test



type MyObject struct{
    v0 float32
    v1 float32
    v2 float32
}


func main(){
    v := new(MyObject)
    p := v.v0 + v.v1 + v.v2
}