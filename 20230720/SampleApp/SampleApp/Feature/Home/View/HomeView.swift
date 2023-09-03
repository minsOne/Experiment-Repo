//
//  HomeView.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/18.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    typealias State = HomeViewState
    typealias Action = HomeViewAction

    weak var listener: HomePresentableListener?

    @Published var state: State

    init(listener: HomePresentableListener? = nil,
         state: State)
    {
        self.listener = listener
        self.state = state
    }

    func update(state: State) {
        self.state = state
    }

    func request(action: Action) {
        listener?.request(action: action)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()

                Button("Tap1 Action Button") {
                    viewModel.request(action: .tap1)
                }

                Button("Tap2 Action Button") {
                    viewModel.request(action: .tap2)
                }

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.title)
                    .valueChanged(value: viewModel.state.title) { _ in
                        print("title changed to \(viewModel.state.desc)!")
                    }
                    .font(.title)
                    .border(.gray)

                Spacer()
                    .frame(height: 10)

                Text(viewModel.state.desc)
                    .valueChanged(value: viewModel.state.desc) { _ in
                        print("desc changed to \(viewModel.state.desc)!")
                    }
                    .font(.title)
                    .border(.gray)

                Spacer()
            }
            Spacer()
        }
        .border(Color.blue)
        .padding(.horizontal)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    typealias State = HomeViewState
    typealias Action = HomeViewAction
    typealias ViewModel = HomeViewModel

    class Listener: HomePresentableListener {
        var viewModel: ViewModel?

        @MainActor func request(action: Action) {
            let state: State
            switch action {
            case .viewDidLoad:
                state = .init(title: "Preview ViewDidLoad Action",
                              desc: "Number \(Int.random(in: 0 ... 5))")
            case .tap1:
                state = .init(title: "Preview Tap1 Action",
                              desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
            case .tap2:
                state = .init(title: "Preview Tap2 Action",
                              desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
            }
            viewModel?.update(state: state)
        }
    }

    static let listener = Listener()

    static var previews: some View {
        let state = State(title: "Hello", desc: "World")
        let vm = HomeViewModel(listener: listener, state: state)
        let view = HomeView(viewModel: vm)
        listener.viewModel = vm

        var count = 0
        return VStack {
            Button("Mock Action") {
                let actions: [Action] = [
                    .viewDidLoad,
                    .tap1,
                    .tap2,
                    .viewDidLoad,
                    .tap1,
                    .tap2,
                    .viewDidLoad,
                    .tap1,
                    .tap2,
                ]
                actions[safe: count]
                    .map { listener.request(action: $0) }
                count += 1
                print(count)
            }
            view
        }
    }
}
#endif
