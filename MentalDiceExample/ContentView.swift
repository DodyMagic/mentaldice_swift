//
//  ContentView.swift
//  MentalDice
//
//  Created by Guillaume Bellut on 19/07/2020.
//  Copyright © 2020 Tulleb's Corp. All rights reserved.
//

import SwiftUI
import MentalDiceFramework

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button(action: {
                self.connectDice()
            }) { Text("Connect") }
        }
    }

    private func connectDice() {
        MentalDice.shared.connect()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
