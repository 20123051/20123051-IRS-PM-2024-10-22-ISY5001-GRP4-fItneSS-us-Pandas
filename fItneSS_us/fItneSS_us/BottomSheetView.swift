//
//  BottomSheetView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 22/10/24.
//


import SwiftUI

struct BottomSheetView2<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position = BottomSheetPosition.half
    let content: Content  // Change to direct content rather than closure

    init(@ViewBuilder content: () -> Content) {  // Use ViewBuilder to properly construct views
        self.content = content()
    }

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 40, height: 6)
                .foregroundColor(.gray)
                .opacity(0.5)
                .padding(5)

            content
                .padding(10)
                .background(Color(.systemBackground).opacity(0.95))
                .frame(height: UIScreen.main.bounds.height)
                .offset(y: position.offset + self.dragState.translation.height)
                .animation(.interactiveSpring())
                .gesture(DragGesture()
                            .updating($dragState) { drag, state, _ in
                                state = .dragging(translation: drag.translation)
                            }
                            .onEnded(onDragEnded))
        }
    }

    private func onDragEnded(drag: DragGesture.Value) {
        // Drag handling logic here
        let verticalMovement = drag.translation.height / UIScreen.main.bounds.height
        let downwardMovement = verticalMovement > 0
        let upwardMovement = verticalMovement < 0
        let movementSpeed = abs(drag.predictedEndLocation.y - drag.location.y)

        switch position {
            case .full:
                if downwardMovement {
                    position = .half
                }
            case .half:
                if upwardMovement {
                    position = .full
                } else if downwardMovement {
                    position = .off
                }
            case .off:
                if upwardMovement {
                    position = .half
                }
        }
    }
    
    enum BottomSheetPosition {
        case full, half, off
        
        var offset: CGFloat {
            switch self {
            case .full: return 100
            case .half: return (UIScreen.main.bounds.height / 2 + 100)
            case .off: return (UIScreen.main.bounds.height-100)
            }
        }
    }
    
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
    }
}
