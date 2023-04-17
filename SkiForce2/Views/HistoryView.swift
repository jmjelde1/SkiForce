//
//  HistoryView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//
// List view of all recorded runs
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        
                        SavedRunView(item: item)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { // <2>
                                ToolbarItem(placement: .principal) { // <3>
                                    VStack {
                                        HStack{
                                            Text(item.name!).font(.headline)
                                            Image(systemName: "figure.skiing.downhill")
                                        }
                                        Text(item.timestamp!, formatter: itemFormatter).font(.subheadline)
                                    }
                                }
                            }
                    } label: {
                        HStack{
                            Text("\(item.name ?? "No name")")
                                .bold()
                            Text("\(dateToString(date:item.timestamp!))")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                            
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Select Run")
            Text("Select an item")
        }.accentColor(.black)
    }
//    Adds item to database
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

//    Deletes specified item from database
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
//    Converts date to string
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Formats date
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
