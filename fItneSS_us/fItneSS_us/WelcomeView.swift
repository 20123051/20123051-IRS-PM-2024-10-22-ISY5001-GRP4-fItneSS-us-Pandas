//
//  WelcomePage.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 18/10/24.
//


import SwiftUI

class WelcomeViewModel: ObservableObject {
    @Published var isShowingLogin = true // 初始状态显示登录表单
}

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var maskOffset: CGSize = CGSize(width: 0, height: 0) // 初始化为0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                VStack {
                    SignUpView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    LoginView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .mask(
                    Rectangle()
                        .offset(maskOffset)
                        .animation(.easeInOut(duration: 0.5), value: maskOffset)
                )
                .animation(.spring(), value: maskOffset)


                // 切换按钮
                VStack {
                    Spacer()
                    Button(action: toggleView) {
                        Text(viewModel.isShowingLogin ? "Switch to Sign Up" : "Switch to Login")
                            .bold()
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // 初始遮罩位置设置为半屏幕高度
                maskOffset = CGSize(width: 0, height: geometry.size.height / 2)
            }
        }
    }

    private func toggleView() {
        viewModel.isShowingLogin.toggle()
        // 动态调整遮罩的位置
        //var tem = maskOffset.height
        maskOffset.height *= -1
    }
}

#Preview {
    WelcomeView()
}

