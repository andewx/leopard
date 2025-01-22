package test


type vector3 struct{
    data [3]float32[xyz]
}

func (v *vector3)Dot(b *vector3)float32{
    return v.data.x * b.data.x + v.data.y * b.data.y + v.data.z * b.data.z
}


func BenchDot(arr1 *vector3, arr2 *vector3){

    for i := 0; i < 10000; i++{
         x := arr1.Dot(arr2)
    }
}