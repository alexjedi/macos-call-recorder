import SwiftUI

struct QAFormView: View {
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var answer3: String = ""
    @State private var answer4: String = ""
    @State private var answer5: String = ""

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Demo Playbook")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("To change key points, save calls and update your CRM")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button("Set Up Playbook") {
                    openWebsite(urlString: "https://app.hintsflow.ai")
                }
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Divider()

            Group {
                QuestionAnswerRow(question: "Tell me about your company.", answer: $answer1)
                QuestionAnswerRow(question: "What do you sell?", answer: $answer2)
                QuestionAnswerRow(question: "Who is your target audience?", answer: $answer3)
                QuestionAnswerRow(question: "What does your average day look like?", answer: $answer4)
                QuestionAnswerRow(question: "Could you tell me about your current", answer: $answer5)
            }
            .padding(.horizontal)

            Text("Start using extension on zoom.us web or google meet")
                .font(.footnote)
                .padding(.bottom)

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, maxWidth: .infinity)
        .background(Color.white)
    }
}

func openWebsite(urlString: String) {
    guard let url = URL(string: urlString) else { return }
    NSWorkspace.shared.open(url)
}

// Input component
struct QuestionAnswerRow: View {
    var question: String
    @Binding var answer: String

    var body: some View {
        HStack {
            Text(question)
                .foregroundColor(.gray)
            Spacer()
            TextField("Your value", text: $answer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
            Text("AI guesses will be here")
                .foregroundColor(.gray)
        }
    }
}

struct QAFormView_Previews: PreviewProvider {
    static var previews: some View {
        QAFormView()
    }
}
