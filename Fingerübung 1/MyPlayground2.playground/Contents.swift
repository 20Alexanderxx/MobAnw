import UIKit

//Aufgabe 1
var tupel: (String, Int, String, Int, String, Int, String, Int, String, Int) = ("Hallo", 1, "Welt", 2, "Swift", 3, "Tupel", 4, "Alex", 5)

//Aufgabe 2
tupel.0 = "Hello"
tupel.1 = 0
print(tupel)

//Aufgabe 3
var Arr1: [Int] = []
var Arr2: [String] = []

//Aufgabe 4
for i in 1...5{
    Arr1.append(i)
    Arr2.append("\(i)")
}

//Aufgabe 5
var myDict: [String: Int] = [:]


//Aufgabe 6
for i in 0...Arr1.count-1{
    var key = Arr2[i]
    var value = 0
    if i == 0 {
        value = Arr1[2]
    }
    else{
        value = Arr1[i-1]
    }
    myDict[key] = value
}
print(myDict)
