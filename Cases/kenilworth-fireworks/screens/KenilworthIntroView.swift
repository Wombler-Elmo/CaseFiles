import SwiftUI
import SDWebImageSwiftUI



struct KenilworthIntroView: View {
    var onTap: () -> Void

    var body: some View {
        WebImage(
            url: Bundle.main.url(forResource: "Kenilworth_Lightening", withExtension: "gif")
        )
        .resizable()
        .scaledToFill()
        .ignoresSafeArea()
        .onTapGesture {
            onTap()
        }

    }
}
