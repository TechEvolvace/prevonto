import SwiftUI

struct LanguageView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage = "English"
    
    private let languages = [
        Language(name: "English", code: "en", flag: "🇺🇸"),
        Language(name: "Spanish", code: "es", flag: "🇪🇸"),
        Language(name: "French", code: "fr", flag: "🇫🇷"),
        Language(name: "German", code: "de", flag: "🇩🇪"),
        Language(name: "Italian", code: "it", flag: "🇮🇹"),
        Language(name: "Portuguese", code: "pt", flag: "🇵🇹"),
        Language(name: "Chinese", code: "zh", flag: "🇨🇳"),
        Language(name: "Japanese", code: "ja", flag: "🇯🇵"),
        Language(name: "Korean", code: "ko", flag: "🇰🇷"),
        Language(name: "Arabic", code: "ar", flag: "🇸🇦"),
        Language(name: "Russian", code: "ru", flag: "🇷🇺"),
        Language(name: "Hindi", code: "hi", flag: "🇮🇳"),
        Language(name: "Dutch", code: "nl", flag: "🇳🇱"),
        Language(name: "Swedish", code: "sv", flag: "🇸🇪"),
        Language(name: "Norwegian", code: "no", flag: "🇳🇴"),
        Language(name: "Finnish", code: "fi", flag: "🇫🇮"),
        Language(name: "Danish", code: "da", flag: "🇩🇰"),
        Language(name: "Polish", code: "pl", flag: "🇵🇱"),
        Language(name: "Czech", code: "cs", flag: "🇨🇿"),
        Language(name: "Hungarian", code: "hu", flag: "🇭🇺"),
        Language(name: "Romanian", code: "ro", flag: "🇷🇴"),
        Language(name: "Bulgarian", code: "bg", flag: "🇧🇬"),
        Language(name: "Croatian", code: "hr", flag: "🇭🇷"),
        Language(name: "Serbian", code: "sr", flag: "🇷🇸"),
        Language(name: "Slovak", code: "sk", flag: "🇸🇰"),
        Language(name: "Slovenian", code: "sl", flag: "🇸🇮"),
        Language(name: "Estonian", code: "et", flag: "🇪🇪"),
        Language(name: "Latvian", code: "lv", flag: "🇱🇻"),
        Language(name: "Lithuanian", code: "lt", flag: "🇱🇹"),
        Language(name: "Greek", code: "el", flag: "🇬🇷"),
        Language(name: "Turkish", code: "tr", flag: "🇹🇷"),
        Language(name: "Hebrew", code: "he", flag: "🇮🇱"),
        Language(name: "Thai", code: "th", flag: "🇹🇭"),
        Language(name: "Vietnamese", code: "vi", flag: "🇻🇳"),
        Language(name: "Indonesian", code: "id", flag: "🇮🇩"),
        Language(name: "Malay", code: "ms", flag: "🇲🇾"),
        Language(name: "Filipino", code: "fil", flag: "🇵🇭"),
        Language(name: "Ukrainian", code: "uk", flag: "🇺🇦"),
        Language(name: "Afrikaans", code: "af", flag: "🇿🇦"),
        Language(name: "Amharic", code: "am", flag: "🇪🇹"),
        Language(name: "Azerbaijani", code: "az", flag: "🇦🇿"),
        Language(name: "Belarusian", code: "be", flag: "🇧🇾"),
        Language(name: "Bengali", code: "bn", flag: "🇧🇩"),
        Language(name: "Bosnian", code: "bs", flag: "🇧🇦"),
        Language(name: "Catalan", code: "ca", flag: "🇪🇸"),
        Language(name: "Esperanto", code: "eo", flag: "🏳️"),
        Language(name: "Albanian", code: "sq", flag: "🇦🇱"),
        Language(name: "Basque", code: "eu", flag: "🇪🇸"),
        Language(name: "Galician", code: "gl", flag: "🇪🇸"),
        Language(name: "Georgian", code: "ka", flag: "🇬🇪"),
        Language(name: "Gujarati", code: "gu", flag: "🇮🇳"),
        Language(name: "Hausa", code: "ha", flag: "🇳🇬"),
        Language(name: "Icelandic", code: "is", flag: "🇮🇸"),
        Language(name: "Igbo", code: "ig", flag: "🇳🇬"),
        Language(name: "Irish", code: "ga", flag: "🇮🇪"),
        Language(name: "Javanese", code: "jv", flag: "🇮🇩"),
        Language(name: "Kannada", code: "kn", flag: "🇮🇳"),
        Language(name: "Kazakh", code: "kk", flag: "🇰🇿"),
        Language(name: "Khmer", code: "km", flag: "🇰🇭"),
        Language(name: "Kurdish", code: "ku", flag: "🇮🇶"),
        Language(name: "Kyrgyz", code: "ky", flag: "🇰🇬"),
        Language(name: "Lao", code: "lo", flag: "🇱🇦"),
        Language(name: "Latin", code: "la", flag: "🏳️"),
        Language(name: "Luxembourgish", code: "lb", flag: "🇱🇺"),
        Language(name: "Macedonian", code: "mk", flag: "🇲🇰"),
        Language(name: "Malagasy", code: "mg", flag: "🇲🇬"),
        Language(name: "Malayalam", code: "ml", flag: "🇮🇳"),
        Language(name: "Maltese", code: "mt", flag: "🇲🇹"),
        Language(name: "Maori", code: "mi", flag: "🇳🇿"),
        Language(name: "Marathi", code: "mr", flag: "🇮🇳"),
        Language(name: "Mongolian", code: "mn", flag: "🇲🇳"),
        Language(name: "Myanmar", code: "my", flag: "🇲🇲"),
        Language(name: "Nepali", code: "ne", flag: "🇳🇵"),
        Language(name: "Pashto", code: "ps", flag: "🇦🇫"),
        Language(name: "Persian", code: "fa", flag: "🇮🇷"),
        Language(name: "Punjabi", code: "pa", flag: "🇮🇳"),
        Language(name: "Samoan", code: "sm", flag: "🇼🇸"),
        Language(name: "Scots Gaelic", code: "gd", flag: "🏴󠁧󠁢󠁳󠁣󠁴󠁿"),
        Language(name: "Sesotho", code: "st", flag: "🇱🇸"),
        Language(name: "Shona", code: "sn", flag: "🇿🇼"),
        Language(name: "Sindhi", code: "sd", flag: "🇵🇰"),
        Language(name: "Sinhala", code: "si", flag: "🇱🇰"),
        Language(name: "Somali", code: "so", flag: "🇸🇴"),
        Language(name: "Sundanese", code: "su", flag: "🇮🇩"),
        Language(name: "Swahili", code: "sw", flag: "🇰🇪"),
        Language(name: "Tajik", code: "tg", flag: "🇹🇯"),
        Language(name: "Tamil", code: "ta", flag: "🇮🇳"),
        Language(name: "Tatar", code: "tt", flag: "🇷🇺"),
        Language(name: "Telugu", code: "te", flag: "🇮🇳"),
        Language(name: "Turkmen", code: "tk", flag: "🇹🇲"),
        Language(name: "Urdu", code: "ur", flag: "🇵🇰"),
        Language(name: "Uyghur", code: "ug", flag: "🇨🇳"),
        Language(name: "Uzbek", code: "uz", flag: "🇺🇿"),
        Language(name: "Welsh", code: "cy", flag: "🏴󠁧󠁢󠁷󠁬󠁳󠁿"),
        Language(name: "Xhosa", code: "xh", flag: "🇿🇦"),
        Language(name: "Yiddish", code: "yi", flag: "🏳️"),
        Language(name: "Yoruba", code: "yo", flag: "🇳🇬"),
        Language(name: "Zulu", code: "zu", flag: "🇿🇦")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Language Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Current Language Section
                            currentLanguageSection
                            
                            // All Languages Section
                            allLanguagesSection
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                Text("Languages")
                    .font(.custom("Noto Sans", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                
                Spacer()
                
                // Invisible spacer to balance the back button
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color.white)
        }
    }
    
    // MARK: - Current Language Section
    var currentLanguageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                if let currentLang = languages.first(where: { $0.name == selectedLanguage }) {
                    LanguageRowView(language: currentLang, isSelected: true) {
                        // Already selected, no action needed
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - All Languages Section
    var allLanguagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Languages")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ForEach(Array(languages.enumerated()), id: \.element.id) { index, language in
                    LanguageRowView(
                        language: language,
                        isSelected: language.name == selectedLanguage
                    ) {
                        selectedLanguage = language.name
                    }
                    
                    if index < languages.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Language Row Component
struct LanguageRowView: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 24))
                    .frame(width: 30, height: 30)
                
                // Language Name
                Text(language.name)
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Language Model
struct Language: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}

// MARK: - Preview
struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageView()
    }
}
