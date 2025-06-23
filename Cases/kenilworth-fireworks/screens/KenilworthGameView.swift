import SwiftUI
import SDWebImageSwiftUI

struct KenilworthGameView: View {
    @State private var currentStep = 0
    @State private var showBurgerMenu = false
    @State private var showPauseOverlay = false
    @ObservedObject var timerManager = GameTimerManager()
    @State private var showTimer = false
    @State private var isStatusBarHidden = true
    @State private var showExitConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                currentView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .opacity))
                    .id(currentStep)
            }
            .animation(.easeInOut(duration: 0.6), value: currentStep)
            .edgesIgnoringSafeArea(.all)

            HStack {
                if showTimer {
                    TimerOverlayView(timerManager: timerManager, isPaused: timerManager.isPaused)
                }

                Spacer()

                Button(action: { showBurgerMenu.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding()
            }

            if showBurgerMenu {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showBurgerMenu = false
                        }

                    VStack {
                        HStack {
                            Spacer()
                            BurgerMenuView(
                                onPause: {
                                    timerManager.pause()
                                    showPauseOverlay = true
                                    showBurgerMenu = false
                                },
                                onExit: {
                                    showExitConfirmation = true
                                },
                                onHelp: {
                                    // TODO: show FAQ
                                },
                                onViewMap: {
                                    currentStep = 7
                                    showBurgerMenu = false
                                }
                            )
                            .frame(width: 200, alignment: .trailing)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding(.trailing, 16)
                        }
                        .padding(.top, 80)

                        Spacer()
                    }
                }
                .zIndex(2)
            }

            if showPauseOverlay {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPauseOverlay = false
                        timerManager.resume()
                    }
                Text("Paused – tap anywhere to continue")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .alert("Are you sure you want to exit?", isPresented: $showExitConfirmation) {
            Button("Exit", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be lost.")
        }
        .statusBar(hidden: isStatusBarHidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showBurgerMenu.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }

    @ViewBuilder
    func currentView() -> some View {
        switch currentStep {
        case 0:
            TimedFullScreenImage(name: "Kenilworth_Lightening.gif", seconds: 1.5) {
                currentStep += 1
            }

        case 1:
            TappableFullScreenImage(name: "Kenilworth_Speech") {
                currentStep += 1
            }

        case 2:
            TappableFullScreenImage(name: "Kenilworth_Stop_Guard") {
                currentStep += 1
            }

        case 3:
            WelcomeScreen(title: "Enter your team name") {
                currentStep += 1
            }

        case 4:
            TappableFullScreenImage(name: "Kenilworth_Funny_Welcome") {
                currentStep += 1
            }

        case 5:
            KenilworthPictureScreen {
                timerManager.start()
                showTimer = true
                currentStep += 1
            }

        case 6:
            TappableFullScreenImage(name: "Kenilworth_Crime") {
                currentStep += 1
            }

        case 7:
            TappableFullScreenImage(name: "Kenilworth_Map_Clue") {
                currentStep += 1
            }

        case 8:
            KenilworthFirstPuzzleScreen {
                currentStep += 1
            }

        case 9:
            TappableFullScreenImage(name: "Kenilworth_First_Solved") {
                currentStep += 1
            }

        case 10:
            TappableFullScreenImage(name: "Kenilworth_First_FF") {
                timerManager.resume()
                currentStep += 1
            }
            .onAppear {
                timerManager.pause()
            }

        default:
            FinalPlaceholderScreen()
        }
    }
}

// MARK: - Helper Views

struct FullScreenImage: View {
    let name: String
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
    }
}

struct TappableFullScreenImage: View {
    let name: String
    let onTap: () -> Void

    var body: some View {
        ZStack {
            FullScreenImage(name: name)
            TapToContinueOverlay(text: "Tap to continue", onTap: onTap)
        }
    }
}

struct TimedFullScreenImage: View {
    let name: String
    let seconds: Double
    let onComplete: () -> Void

    var body: some View {
        Group {
            if name.lowercased().hasSuffix(".gif") {
                AnimatedImage(name: name)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                onComplete()
            }
        }
    }
}


struct TimerOverlayView: View {
    @ObservedObject var timerManager: GameTimerManager
    var isPaused: Bool = false

    var body: some View {
        Text(timerManager.formattedTime)
            .font(.caption)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .foregroundColor(isPaused ? .red : .white)
            .cornerRadius(8)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TapToContinueOverlay: View {
    let text: String
    let onTap: () -> Void
    @State private var animate = false

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 6) {
                Text(text)
                Image(systemName: "arrow.right")
            }
            .font(.callout)
            .bold()
            .foregroundColor(.white)
            .opacity(animate ? 1 : 0.3)
            .offset(x: animate ? 6 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            .padding(.bottom, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct FinalPlaceholderScreen: View {
    var body: some View {
        VStack {
            Text("You tested the first puzzle for Kenilworth, well done!")
                .font(.title)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundColor(.white)
    }
}
