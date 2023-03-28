//
//  ContentView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/2/23.
//

import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    var body: some View {
        TabView() {
            SeasonStatsView()
                .tabItem{
                    Image(systemName: "figure.skiing.downhill")
                    Text("Stats")
                }
            RecordView()
                .tabItem{
                    Image(systemName: "record.circle")
                    Text("Record")
                }
            HistoryView()
                .tabItem{
                    Image(systemName: "books.vertical")
                    Text("History")
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
