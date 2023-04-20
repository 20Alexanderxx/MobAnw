//
//  ContentView.swift
//  Blank Template
//
//  Created by Joseph Hinkle on 9/8/20.
//


import SwiftUI
struct ContentView: View {
    @State private var term = "0"
    @State private var term_list:[String] = []
    @State private var output = "0"
    @State private var operation = ""
    @State private var memory = "0"
    
    let buttons = [
            ["MC", "MP", "C", "/"],
            ["7", "8", "9", "+"],
            ["4", "5", "6", "-"],
            ["1", "2", "3", "*"],
            ["0", "+/-", "=",]
        ]
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Text(output)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding()
                
                HStack {
                    Spacer()
                    Text(term)
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
                
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                self.buttonPressed(button)
                            }) {
                                Text(button)
                                    .font(.largeTitle)
                                    .frame(width: button == "=" ? 140 : 64, height: 64)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(32)
                            }
                        }
                    }
                    .padding(.bottom, 3)
                }
            }
        }
        
        func buttonPressed(_ button: String) {
            switch button {
            case "=":
                submitNumber()
            case "C":
                clearInput()
            case "MC":
                self.memory = term_list[term_list.count - 1]
            case "MP":
                self.term.append(String(memory))
            case "+/-":
                term = String(Int(term)! * -1)
            case "/", "*", "-", "+":
                if term_list.count == 0 {
                    output = "0"
                    operation = button
                }
            default:
                if term_list.count == 2 {
                    clearInput()
                }
                appendInput(button)
                
            }
        }
        
        func appendInput(_ input: String) {
            if operation == ""{
                output = "erst Operation"
                return
            }
            if self.term.starts(with: "0") {
                self.term = ""
            }
            self.term.append(input)
        }
        
        func clearInput() {
            self.term_list = []
            self.output = "0"
            self.operation = ""
            self.term = "0"
        }
        
        func submitNumber() {
            if term_list.count <= 2{
                self.term_list.append(term)
                term = "0"
                output = term_list[0]
                if term_list.count == 2 {
                    let calc: String = term_list[0] + operation + term_list[1]
                    output = String(NSExpression(format: calc).expressionValue(with: nil, context: nil) as? Int ?? 0)
                }
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

