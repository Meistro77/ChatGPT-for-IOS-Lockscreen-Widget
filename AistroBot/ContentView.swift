//  ContentView.swift
//  AistroBot
//
//  Created by Kishan Kr Sharma on 12/18/22.
//
import OpenAISwift
import SwiftUI

final class ChatViewModel : ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    // setting up the client req
    func setup(apiKey: String){
        // store API key in local storage
        UserDefaults.standard.set(apiKey, forKey: "OpenAIAPIKey")
        client  = OpenAISwift(authToken: apiKey)
    }
    // sending api rext to server
    func send(text: String, completion: @escaping (String)->Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            
            switch result {
                // on request success
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
                
                // on request fail
            case .failure: break
            }
            
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ChatViewModel()
    @State var apiKey = ""
    @State var text = ""
    @State var models  = [String]()
    @State private var showAPIKeyInput = false

    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                HStack {
                    Spacer()
                    Text("         AistroBot")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {
                        // Show the API Key input card
                        showAPIKeyInput = true
                    }) {
                        Image(systemName: "key")
                            .font(.system(size: 25))
                            .foregroundColor(Color(.blue))
                    }
                    .padding(5)
                    .cornerRadius(100)
                    .padding(.trailing, 10)
                }

                if showAPIKeyInput {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showAPIKeyInput = false
                            }

                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    showAPIKeyInput = false
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 25))
                                        .foregroundColor(.white)
                                }
                                .padding(5)
                            }
                            .padding(.top, 20)

                            Spacer()

                            Link(destination: URL(string: "https://platform.openai.com/account/api-keys")!) {
                                Text("Get API Key")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 18))
                                    .padding(.bottom, 10)
                            }

                            TextField("Enter API Key", text: $apiKey)
                                .padding(10)
                                .background(Color("textBox"))
                                .cornerRadius(100)
                                .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                                    .stroke(.gray.opacity(0.6), lineWidth: 1.5))
                                .padding(.horizontal, 20)

                            Button(action: {
                                viewModel.setup(apiKey: apiKey)
                                showAPIKeyInput = false
                            }) {
                                Text("Submit")
                                    .font(.system(.caption))
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(width: 300, height: 200)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                }
            }


                .frame(width: UIScreen.main.bounds.width)
                .background(Color(.white))
                
                ScrollView (.vertical, showsIndicators: true) {
                    ForEach(models, id: \.self.hashValue) { string in
                        if string.contains("You"){
                            VStack{
                                Text("You")
                                    .font(.system(size: 12.0))
                                    .foregroundColor(.gray.opacity(0.6))
                                    .frame(width: UIScreen.main.bounds.width-20, alignment: .trailing)
                                    .padding(.bottom, -10)
                                
                                Text(string.replacing("You:", with: ""))
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .background(Color("me"))
                                    .cornerRadius(10)
                                    .frame(width: UIScreen.main.bounds.width-20, alignment: .trailing)
                                    .padding(.bottom, 3)
                                    }
                                    .padding(.bottom, 3)
                                                                    
                                                                }else{
                                                                    VStack{
                                                                        Text("AistroBot")
                                                                            .font(.system(size: 12.0))
                                                                            .foregroundColor(.red.opacity(0.6))
                                                                            .frame(width: UIScreen.main.bounds.width-20, alignment: .leading)
                                                                            .padding(.bottom, -10)
                                                                        
                                                                        Text(string.replacing("ChatGPT:", with: ""))
                                                                            .foregroundColor(Color(.gray))
                                                                            .padding(10)
                                                                            .background(Color("bot"))
                                                                            .cornerRadius(10)
                                                                            .frame(width: UIScreen.main.bounds.width-20, alignment: .leading)
                                                                        
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                        HStack(alignment: .center, spacing: 2){
                                                            TextField("Type here ...", text: $text)
                                                                .padding(.horizontal, 10)
                                                                .padding(.vertical, 10)
                                                                .background(Color("textBox"))
                                                                .cornerRadius(100)
                                                                .background(RoundedRectangle(cornerRadius: 100, style: .continuous)
                                                                    .stroke(.gray.opacity(0.6), lineWidth: 1.5))
                                                            
                                                            Button{
                                                                viewModel.setup(apiKey: apiKey)
                                                                sendApiRequest()
                                                            }label: {
                                                                Image(systemName: "paperplane")
                                                                    .font(.system(size: 25))
                                                                    .foregroundColor(Color(.blue))
                                                            }
                                                            .padding(5)
                                                            .cornerRadius(100)
                                                        }
                                                    }
                                                    .padding(10)
                                                    .onAppear{
                                                        // get API key from local storage
                                                        if let key = UserDefaults.standard.string(forKey: "OpenAIAPIKey"){
                                                            apiKey = key
                                                            viewModel.setup(apiKey: apiKey)
                                                        }
                                                    }.background(Color(.white))
                                                }
                                                
        func sendApiRequest(){
                // return nothing if user types noting
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return
                }
                let text2  = self.text
                self.text = ""
                models.append("You:\(text2)")
                
                viewModel.send(text: text2) { response in
                    DispatchQueue.main.async {
                        self.models.append("ChatGPT:" + response.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
        }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
