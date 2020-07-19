//
//  ContentView.swift
//  MentalDice
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var diceCollector: DiceCollector

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                if self.diceCollector.connected {
                    self.diceCollector.disconnect()
                } else {
                    self.diceCollector.connect()
                }
            }) {
                if diceCollector.connected {
                    Text("Disconnect")
                } else {
                    Text("Connect")
                }
            }
            Spacer()
            ForEach(diceCollector.dice) { die in
                Text("\(die.color.rawValue) - \(die.value.rawValue)")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(diceCollector: DiceCollector())
    }
}
