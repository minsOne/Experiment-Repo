//
//  AccountView.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/29.
//

import SwiftUI

class AccountViewModel: ObservableObject {
    typealias Action = AccountViewAction
    typealias State = AccountViewState

    weak var listener: AccountPresentableListener?

    @Published var state: AccountViewState

    init(listener: AccountPresentableListener? = nil,
         state: AccountViewState)
    {
        self.listener = listener
        self.state = state
    }

    func request(action: Action) {
        listener?.request(action: .close)
    }

    func update(state: State) {}
}

struct AccountView: View {
    @Observable var viewModel: AccountViewModel
    @State private var text = ""
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ForEach(0 ..< 30) { _ in
                        Text("Hello")
                    }
                    TextField("Hello", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    ForEach(0 ..< 30) { _ in
                        Text("Hello")
                    }
                }
            }
            VStack {
                Spacer()
                ForEach(0 ..< 2) { _ in
                    Button("Close") {
                        viewModel.request(action: .close)
                    }
                }
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
private class ListenerMock: AccountPresentableListener {
    func request(action: AccountViewAction) {
        print(action)
    }

    var viewModel: AccountViewModel? {
        didSet { viewModel?.listener = self; print(#function) }
    }

    init() { print("init") }
    deinit { print("deinit") }
}

private let listenerMock = ListenerMock()

#Preview {
    let view = AccountView(viewModel: .init(state: .init()))
    listenerMock.viewModel = view.viewModel
    return view
}

#endif
