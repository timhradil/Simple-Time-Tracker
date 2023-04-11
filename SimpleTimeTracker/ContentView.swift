import SwiftUI
import Charts


struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    
    @AppStorage("selectedFocus") private var selectedFocus = 0
    
    @State private var newFocus = ""
    @State private var removeFocus = 0
    @State private var manageFocusesExpanded = false
    @State private var statsWindow: NSWindow? = nil
    @State private var running = false
    @State private var start = 0.0

    var body: some View {
        VStack {
            Form {
                Picker("Current Focus", selection: $selectedFocus) {
                    ForEach(dataStore.focuses.indices, id: \.self) { index in
                        Text(dataStore.focuses[index].name).tag(index)
                    }
                }
            }
            Divider()
            Spacer().frame(height:25)
            HStack{
                if (running) {
                    Button() {
                        let end = NSDate().timeIntervalSince1970
                        dataStore.focuses[selectedFocus].times.append(Time(start: start, length: end - start))
                        running = false
                    } label: {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 50.0, height: 50.0)
                    .buttonStyle(.plain)
                } else {
                    Button() {
                        start = NSDate().timeIntervalSince1970
                        running = true
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 50.0, height: 50.0)
                    .buttonStyle(.plain)
                }
            }
            Spacer().frame(height:25)
            List {
                Button() {
                    manageFocusesExpanded.toggle()
                } label: {
                    Text("\(Image(systemName: manageFocusesExpanded ? "chevron.up" : "chevron.down" )) Add and Remove Focuses")
                }
                .buttonStyle(.plain)
                List {
                    Form {
                        Picker("Remove Focus", selection: $removeFocus) {
                            ForEach(dataStore.focuses.indices, id: \.self) { index in
                                Text(dataStore.focuses[index].name).tag(index)
                            }
                        }
                    }
                    Button("Remove Focus") {
                        dataStore.focuses.remove(at: removeFocus)
                        removeFocus = 0
                    }
                    Form {
                        TextField("Add New Focus", text: $newFocus)
                            .onSubmit {
                                dataStore.focuses.append(Focus(name: newFocus))
                                newFocus = ""
                            }
                    }
                    Button("Add Focus") {
                        dataStore.focuses.append(Focus(name: newFocus))
                        newFocus = ""
                    }
                }
                .frame(height: manageFocusesExpanded ? nil : 0, alignment: .top)
                .clipped()
            }
            .border(.separator, width: 1)
            .cornerRadius(5)
            .frame(height: manageFocusesExpanded ? nil : 45, alignment: .top)
            Button() {
                if (statsWindow != nil) {
                    StatsView().focusWindow(window: statsWindow!, sender: self)
                } else {
                    statsWindow = StatsView().environmentObject(dataStore).openInWindow(title: "Stats", sender: self)
                }
            } label: {
                Text("Open Statistics").foregroundColor(.primary)
            }
        }
        .padding()
        .frame(width: 300)
        .cornerRadius(40)
        .border(.separator, width: 1)
    }
}

extension View {
    
    @discardableResult
    func openInWindow(title: String, sender: Any?) -> NSWindow? {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
        win.contentViewController = controller
        win.title = title
        win.makeKeyAndOrderFront(sender)
        return win
    }
    
    @discardableResult
    func focusWindow(window: NSWindow, sender: Any?) -> NSWindow? {
        window.makeKeyAndOrderFront(sender)
        return window
    }
}
