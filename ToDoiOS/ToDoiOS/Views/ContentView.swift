//
//  ContentView.swift
//  ToDoiOS
//
//  Created by Deniz Tutuncu on 10/29/21.
//

import SwiftUI
import Combine
struct ContentView: View {
    let controller: SignupController = SignupController()
    init() {
        controller.signup {  response in
            print("Response \(String(describing: response))")
        }
    }
    
    var body: some View {
        Text("Hello, world")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
