//
//  ContentView.swift
//  Corona App
//
//  Created by SUMBUL on 22.03.2020.
//  Copyright © 2020 Akead. All rights reserved.
//

import SwiftUI

struct TimeSeries: Decodable {
    let Turkey: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}

class ChartViewModel: ObservableObject  {
    
    @Published var dataSet = [DayData]()
    
    var confirmedMax = 0
    var deathMax = 0
    
    init() {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else { return}
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            
            guard let data = data else { return }
            
            do {
                let timeSeries =  try JSONDecoder().decode(TimeSeries.self, from: data)
                
                DispatchQueue.main.async {
                    
                    self.dataSet = timeSeries.Turkey.filter {$0.confirmed > 0 }
                    
                    self.confirmedMax = self.dataSet.max(by: { (day1, day2) -> Bool in
                        return day2.confirmed > day1.confirmed
                    })?.confirmed ?? 0
                    
                    self.deathMax = self.dataSet.max(by: { (day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                    })?.deaths ?? 0
                }
            } catch {
                print("Json Decode Failed:",error)
            }
            
            
        }.resume()
    }
    
}

struct ContentView: View {
    @ObservedObject var vm = ChartViewModel()
    
    var body: some View {
        VStack {
            Text("Corona Virüs")
                .font(.system(size: 34, weight: .bold))
            Text("Ülkemeizde Toplam Vaka Sayısı: \(vm.confirmedMax)")
            
            if !vm.dataSet.isEmpty {
                ScrollView(.horizontal) {
                    HStack (alignment: .bottom, spacing: 4) {
                        ForEach(vm.dataSet, id: \.self) { day in
                            HStack(alignment: .center) {
                                Spacer()
                            }.frame(width: 8, height:
                                (CGFloat(day.confirmed) / CGFloat(self.vm.confirmedMax)) * 200)
                                .background(Color.red)
                        }
                    }
                    
                }
                
                Text("Ülkemizde Toplam Ölüm Sayısı: \(vm.deathMax)")
                ScrollView(.horizontal) {
                    HStack (alignment: .bottom, spacing: 4) {
                        ForEach(vm.dataSet, id: \.self) { day in
                            HStack(alignment: .center) {
                                Spacer()
                            }.frame(width: 8, height:
                                (CGFloat(day.deaths) / CGFloat(self.vm.deathMax)) * 200)
                                .background(Color.red)
                        }
                    }
                    
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
