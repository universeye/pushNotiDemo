//
//  ContentView.swift
//  PushNotiDemo
//
//  Created by Terry Kuo on 2022/4/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View {
    
    @State var titleText = ""
    @State var bodyText = ""
    @State var deviceToken = "" //Fetch from Firestore in real time usage...
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("", text: $titleText)
                } header: {
                    Text("Message Title")
                }
                Section {
                    TextField("", text: $bodyText)
                } header: {
                    Text("Message Body")
                }
                Section {
                    TextField("", text: $deviceToken)
                } header: {
                    Text("Device Token")
                }
                
                Button {
                    sendMessage()
                } label: {
                    Text("Send Push Notification")
                }
                
                Button {
                    sendMessageToTopic()
                } label: {
                    Text("Send Push Notification to topic")
                }
                
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Push Notification")
        }
    }
    
    func sendMessage() {
        //Simple Logic
        //Using Firebase API to send push notifications to another device using Token
        //Without having server
        print("Sending Message.....")
        
        //Convert to URLrequest
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            print("URL Error")
            return
        }
        
        let json: [String: Any] = [
            
            "to": deviceToken,
            "notification": [
                "title": titleText,
                "body": bodyText
            ],
            
            "data": [
                //Data to be Sent...
                //Don't pass empty or remove the block
                "usr_name": "yoyoKuoo"
            ]
        ]
        
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //Converting json Dict to JSON...
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        //Setting Content Type and Authorization...
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(APIKeys.serverKeyForJoes)", forHTTPHeaderField: "Authorization")
        
        //Passing Request using URLSession
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { _, _, err in
            if let err = err {
                print("err = \(err.localizedDescription)")
            }
            
            //Else Success
            //clearing textfieds
            
            print("Success")
            DispatchQueue.main.async {
                titleText = ""
                bodyText = ""
                deviceToken = ""
            }
        }
        .resume()
    }
    
    func sendMessageToTopic() {
        print("Sending Message to Topic.....")
        
        //Convert to URLrequest
        //https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send") else {
            print("URL Error")
            return
        }
        
        let json: [String: Any] = [
            "topic": "GA2000",
            "notification": [
                "title": titleText,
                "body": bodyText
            ]
        ]
        
        
        
        //URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //Converting json Dict to JSON...
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        //Setting Content Type and Authorization...
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=(\(APIKeys.serverKeyForTopic))", forHTTPHeaderField: "Authorization")
        
        //Passing Request using URLSession
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { data, response, err in
            if let err = err {
                print("err = \(err.localizedDescription)")
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                //check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString ?? "")")
            
            
            //Else Success
            //clearing textfieds
            
            print("Success")
            DispatchQueue.main.async {
                titleText = ""
                bodyText = ""
                deviceToken = ""
            }
        }
        .resume()
    }
}
