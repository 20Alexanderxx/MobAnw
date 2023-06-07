import UIKit

let myArray = [1, 2, 3, 4]
let newArray = myArray.map{ $0 * $0 } // mit $0 wird auf den ersten parameter impliziet zugegriffen
print(newArray)

indirect enum arithmeticexpression{
    case number(Int)
    case addition(arithmeticexpression, arithmeticexpression)
}

var eins = arithmeticexpression.number(1)
var zwei = arithmeticexpression.number(2)

var addition = arithmeticexpression.addition(eins, zwei)


func evaluate(_ expression: arithmeticexpression) -> Int {
    switch expression {
    case let .number(value):
        return value
    case let .addition(left, right):
        return evaluate(left) + evaluate(right)
    }
}

let result = evaluate(addition)
print(result)
