//
//  ContentView.swift
//  memoStudies
//
//  Created by Dragan Macos on 25.04.23.
//

import SwiftUI

let dimension = 4

struct ContentView: View {
    @State var pictureTable = ["hare",
                        "tortoise",
                        "lizard",
                        "bird",
                        "ant",
                        "fish",
                        "pawprint",
                        "leaf",
                        "hare",
                        "tortoise",
                        "lizard",
                        "bird",
                        "ant",
                        "fish",
                        "pawprint",
                        "leaf"].shuffled()
    
    @State var chosenLabel = ("", -1)
    @State var pairs = 0
    @State var moves = 0
    
    @State var pictureTableStates = Array(repeating: false,
                                          count: dimension * dimension)
    // wenn repeating: false, dann sind alle Karten mit "dem Gesicht zum Tisch" gedreht.
    // wenn repeating: true, dann sind alle Karten mit sichtbar.
    var body: some View {
        VStack {
            Text("Your Pairs: \(pairs)")
            Text("Your Moves: \(moves)")
            Button(action: {self.retry()}) {
                Text("Retry")
                    .padding()
                    .foregroundColor(pictureTableStates.allSatisfy({ $0 }) ? Color.blue : Color.white)
            }
        
            ForEach(0..<4) { row in
                HStack {
                    ForEach(0..<dimension, id: \.self) { column in
                        Button(action: {self.function(n: row*dimension + column) }) {
                            if pictureTableStates[row*dimension + column] {
                                Image(systemName: pictureTable[row*dimension + column])
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            } else {
                                Image(systemName: "slowmo")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .padding()
                            }
                        }.frame(width: 80, height: 100)
                    }
                }
            }
        }
    }
    func retry(){
        pictureTable.shuffle()
        for i in 0..<dimension*dimension {
            pictureTableStates[i] = false
        }
        moves = 0
        pairs = 0
    }
    
    func function(n: Int) {
        if chosenLabel.0 == "" && !pictureTableStates[n] {
            chosenLabel = (pictureTable[n], n)
            pictureTableStates[n] = true
        }
        else if chosenLabel.1 != n && !pictureTableStates[n] {
            if chosenLabel.0 == pictureTable[n]  {
                pictureTableStates[n] = true
                pairs += 1
            }
            else {
                pictureTableStates[chosenLabel.1] = false
            }
            chosenLabel = ("", -1)
            moves += 1
        }
    }
}
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
