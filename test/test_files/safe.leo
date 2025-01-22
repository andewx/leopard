package test


type vector struct{
    x float
    y float
    z float 
}

func Create()*vector{
    safe a *vector
    a := vector{1.0, 1.0, 1.0}
    return a
}

func Destroy(a *vector){
    b <:= a
}


func main(){
    b <:= Create()
    Destroy(b)
}


