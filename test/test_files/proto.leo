package test


type Automobile interface{
    Drive()int
    Park()string
    Identity()string
}


func main(){
    proto my_car Automobile

    my_car.Drive() = func()int{
        return 1
    }
}

