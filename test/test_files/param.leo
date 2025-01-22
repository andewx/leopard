package test

type User struct{
    name string
    age int
}


func (u *User)(==)(other *User)bool{

    if u.name != other.name{
        return false
    }

    if u.age != other.age{
        return false
    }

    return true
}


func (u *User)(<=)(other *User)bool{
    if u.age <= other.age{
        return true
    }
    return false
}

func (u *User)(>=)(other *User)bool{
    if u.age >= other.age{
        return true
    }
    return false
}

func (u *User)(>)(other *User)bool{
    if u.age > other.age{
        return true
    }
    return false
}

func (u *User)(<)(other *User)bool{
    if u.age < other.age{
        return true
    }
    return false
}


type OrderedInsertionList<T Comparable> struct{
    list []*T
}

func (o *OrderedInsertionList)Insert(T *item){

    for i := 0; i < len(o.list)-1; i++{
        if o.list[i] < item &&  o.list[i+1] >= item{
            for j < len(o.list)-1; j++{
                o.list[j+1] = o.list[j]
            }
            o.list[i] = item
        }
    }
}