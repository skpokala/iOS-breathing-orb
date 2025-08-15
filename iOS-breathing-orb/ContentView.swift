import SwiftUI
import Combine
import CoreHaptics

// MARK: - Constants
struct BreathingConstants {
    static let inhaleTime: Double = 4.0
    static let holdTime: Double = 4.0
    static let exhaleTime: Double = 4.0
    static let minScale: CGFloat = 0.5
    static let maxScale: CGFloat = 1.5
    static let animationEasing = Animation.easeInOut(duration: inhaleTime)
}

// MARK: - Breathing Phase
enum BreathingPhase: String, CaseIterable {
    case inhale = "Inhale"
    case holdInhale = "Hold Breath"
    case exhale = "Exhale"
    case holdExhale = "Rest"
    
    var duration: Double {
        switch self {
        case .inhale: return BreathingConstants.inhaleTime
        case .holdInhale: return BreathingConstants.holdTime
        case .exhale: return BreathingConstants.exhaleTime
        case .holdExhale: return BreathingConstants.holdTime
        }
    }
}

// MARK: - View Model
class BreathingViewModel: ObservableObject {
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var isActive = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var scale: CGFloat = BreathingConstants.minScale
    
    private var timer: AnyCancellable?
    private var phaseTimer: AnyCancellable?
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    func startBreathing() {
        isActive = true
        elapsedTime = 0
        currentPhase = .inhale
        scale = BreathingConstants.minScale
        
        // Start the session timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime += 1
            }
        
        startPhaseTimer()
    }
    
    func stopBreathing() {
        isActive = false
        timer?.cancel()
        phaseTimer?.cancel()
        scale = BreathingConstants.minScale
        elapsedTime = 0
    }
    
    private func startPhaseTimer() {
        moveToNextPhase()
        
        phaseTimer = Timer.publish(every: currentPhase.duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveToNextPhase()
            }
    }
    
    private func moveToNextPhase() {
        let phases = BreathingPhase.allCases
        guard let currentIndex = phases.firstIndex(of: currentPhase) else { return }
        
        let nextIndex = (currentIndex + 1) % phases.count
        currentPhase = phases[nextIndex]
        
        withAnimation(BreathingConstants.animationEasing) {
            switch currentPhase {
            case .inhale:
                scale = BreathingConstants.maxScale
            case .exhale:
                scale = BreathingConstants.minScale
            default:
                break
            }
        }
        
        // Trigger haptic feedback
        triggerHapticFeedback()
        
        // Reset phase timer for the new phase
        phaseTimer?.cancel()
        phaseTimer = Timer.publish(every: currentPhase.duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveToNextPhase()
            }
    }
    
    // MARK: - Haptics
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }
    
    private func triggerHapticFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @StateObject private var viewModel = BreathingViewModel()
    
    private let gradientColors = [
        Color(red: 0.5, green: 0, blue: 1), // Purple
        Color(red: 0, green: 0, blue: 1)    // Blue
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack {
                // Timer display
                Text(String(format: "Session Time: %02d:%02d",
                          Int(viewModel.elapsedTime) / 60,
                          Int(viewModel.elapsedTime) % 60))
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Phase text
                Text(viewModel.currentPhase.rawValue)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                // Breathing orb
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: gradientColors),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
                    .frame(width: 200, height: 200)
                    .scaleEffect(viewModel.scale)
                    .animation(BreathingConstants.animationEasing, value: viewModel.scale)
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 40) {
                    Button(action: {
                        if viewModel.isActive {
                            viewModel.stopBreathing()
                        } else {
                            viewModel.startBreathing()
                        }
                    }) {
                        Text(viewModel.isActive ? "Stop" : "Start")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(viewModel.isActive ? Color.red : Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}