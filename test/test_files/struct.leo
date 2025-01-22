package test


type User struct{
    name string
    age int
}

func User()*User{
    u := User{name:"default", age:0}
}

func User(name string)*User{
    u := User{name: name, age:0}
    return u
}


func (u *User)GetAge()int{
    return u.age
}

func (u User)GetName()string{
    return u.name
}


