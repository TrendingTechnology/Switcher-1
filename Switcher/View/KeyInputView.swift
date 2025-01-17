//
//  TestView.swift
//  KeyMapper
//
//  Created by 김수환 on 2022/03/04.
//

import SwiftUI

struct KeyInputListView: View {
    @State var KeyMapList:[String] = ["",""]
    @State var showingPopover:[Bool] = [false,false]
    @ObservedObject var Content = ObservedObjects
    @AppStorage("IsChecked") var isChecked:[Bool] = [false]
    @State var allItems:[UInt] = Array(FlagMaps.keys).sorted()
    var body: some View{
        HStack{
            ZStack{
               Text("Remove")
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                    )
                    .padding([.top, .bottom] , 2)
                } .onTapGesture(count: 1, perform: {
                    for (index, value) in isChecked.enumerated().reversed(){
                        if(value == true){
                            RemoveDataToEventDict(index: index)
                            
                        }
                    }
                }).frame(width: 100)
                
        Spacer()
        VStack {
            Form {
                Section {
                    Button(action: {
                        // The only job of the button is to toggle the showing
                        // popover boolean so it pops up and we can select our items
                        showingPopover[0].toggle()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "\($Content.PressedKeyList.count).circle")
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
                    }
                    .popover(isPresented: $showingPopover[0]) {
                        MultiSelectPickerView(allItems: allItems, selectedItems: $Content.PressedKeyList)
                        // If you have issues with it being too skinny you can hardcode the width
                         .frame(width: 300)
                    }
                }
            }
            }.frame(width: 50)
            VStack{
                Form {
                    Section {
                        Picker("", selection: ($KeyMapList[0])) {
                            ForEach(KeyMapsArr, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
        }.frame(width: 80)
            Text(":")
    VStack{
            Form {
                Section {
                    Button(action: {
                        // The only job of the button is to toggle the showing
                        // popover boolean so it pops up and we can select our items
                        showingPopover[1].toggle()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "\($Content.ReturnKeyList.count).circle")
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(Color(red: 0.4192, green: 0.2358, blue: 0.3450))
                    }
                    .popover(isPresented: $showingPopover[1]) {
                        MultiSelectPickerView(allItems: allItems, selectedItems: $Content.ReturnKeyList)
                        // If you have issues with it being too skinny you can hardcode the width
                         .frame(width: 300)
                    }
                }
            }
            }.frame(width:50)
    VStack{
        Form {
            Section {
                Picker("", selection: ($KeyMapList[1])) {
                    ForEach(KeyMapsArr, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
    }.frame(width: 80)
            Spacer()
            ZStack{
           Text("Add item")
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                    )
                    .padding(.trailing , 8.0)
            }.onTapGesture(count: 1, perform: {
                if KeyMaps.findKey(forValue: KeyMapList[0]) != nil && KeyMaps.findKey(forValue: KeyMapList[1]) != nil{
                    appendDataToEventDict()
                }
                
            }).frame(width: 100)
            
}
//        HStack() {
//            // Rather than a picker we're using Text for the label
//            // and a button for the picker itself
//            Text("Select Items:")
//                .foregroundColor(.white)
//            Text(ObservedObjects.PressedKeyList.rawValue)
//            Text(ObservedObjects.ReturnKeyList.rawValue)
//            
//        }
    }
    func appendDataToEventDict(){
        Content.PressedKeyEvent = PressedKeyEventStringMaker(keycode: KeyMaps.findKey(forValue: KeyMapList[0])!, Flag: ArrayToFlagVal(val: Content.PressedKeyList))
        Content.ReturnKeyEvent = EventStruct(keys: KeyMaps.findKey(forValue: KeyMapList[1]), FlagNum: ArrayToFlagVal(val: Content.ReturnKeyList))
        Content.EventDict[Content.PressedKeyEvent!] = Content.ReturnKeyEvent!
        Content.PressedKeyList = []
        Content.ReturnKeyList = []
        Content.PressedKeyEvent = nil
        Content.ReturnKeyEvent = nil
        UserDefaults.standard.set(try? JSONEncoder().encode(Content.EventDict), forKey:"EventDict")
        KeyMapList = ["",""]
    }
    func RemoveDataToEventDict(index:Int) {
        Content.EventDict.removeValue(forKey: Array(Content.EventDict.keys)[index])
        isChecked.remove(at: index)
        UserDefaults.standard.set(try? JSONEncoder().encode(Content.EventDict), forKey:"EventDict")
    }
}





struct KeyInputView: View {
    @ObservedObject var Content = ObservedObjects
    @AppStorage("IsChecked") var isChecked:[Bool] = [false]
    var body: some View {
    HStack{
        ZStack{
           Text("Remove")
                .padding(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 2)
                )
                .padding([.top, .bottom] , 2)
            } .onTapGesture(count: 1, perform: {
                for (index, value) in isChecked.enumerated().reversed(){
                    if(value == true){
                        RemoveDataToEventDict(index: index)
                        
                    }
                }
            }).frame(width: 100)
            
    Spacer()
VStack{
    Text(Content.PressedKey)
        .font(.system(size: 13, weight: .semibold))
        .onTapGesture{
            (Content.PressedKey != "Waiting") ? ((Content.PressedKey = "Waiting"), (nil)) : ((Content.PressedKey = "PressedKey"), (Content.PressedKeyEvent = nil))
        }
    }.frame(width: 180, alignment: .trailing)
Text(":")
VStack{
    Text(Content.ReturnKey)
        .font(.system(size: 13, weight: .semibold))
        .onTapGesture{
            (Content.ReturnKey != "Waiting") ? ((Content.ReturnKey = "Waiting"), (nil)) : ((Content.ReturnKey = "ReturnKey"), (Content.ReturnKeyEvent = nil))
        }
}.frame(width: 180, alignment: .leading)
        Spacer()
        ZStack{
       Text("Add item")
                .padding(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 2)
                )
                .padding(.trailing , 8.0)
        }.onTapGesture(count: 1, perform: {
            if Content.PressedKeyEvent != nil && Content.ReturnKeyEvent != nil{
                appendDataToEventDict()
            }
        }).frame(width: 100)
    }
    }
    func appendDataToEventDict(){
        Content.PressedKey = "PressedKey"
        Content.ReturnKey = "ReturnKey"
        Content.EventDict[Content.PressedKeyEvent!] = Content.ReturnKeyEvent!
        isChecked.append(false)
        Content.PressedKeyEvent = nil
        Content.ReturnKeyEvent = nil
        UserDefaults.standard.set(try? JSONEncoder().encode(Content.EventDict), forKey:"EventDict")
    }
    
    func RemoveDataToEventDict(index:Int) {
        Content.EventDict.removeValue(forKey: Array(Content.EventDict.keys)[index])
        isChecked.remove(at: index)
        UserDefaults.standard.set(try? JSONEncoder().encode(Content.EventDict), forKey:"EventDict")
    }
}


