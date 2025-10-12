import SwiftUI

// Localization Manager
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "English"
    
    init() {
        currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English"
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
        objectWillChange.send()
    }
    
    func localizedString(_ key: String) -> String {
        let translations: [String: [String: String]] = [
            "English": [
                "Languages": "Languages",
                "Current": "Current",
                "All Languages": "All Languages"
            ],
            "Spanish": [
                "Languages": "Idiomas",
                "Current": "Actual",
                "All Languages": "Todos los idiomas"
            ],
            "French": [
                "Languages": "Langues",
                "Current": "Actuel",
                "All Languages": "Toutes les langues"
            ],
            "German": [
                "Languages": "Sprachen",
                "Current": "Aktuell",
                "All Languages": "Alle Sprachen"
            ],
            "Italian": [
                "Languages": "Lingue",
                "Current": "Corrente",
                "All Languages": "Tutte le lingue"
            ],
            "Portuguese": [
                "Languages": "Idiomas",
                "Current": "Atual",
                "All Languages": "Todos os idiomas"
            ],
            "Chinese": [
                "Languages": "语言",
                "Current": "当前",
                "All Languages": "所有语言"
            ],
            "Japanese": [
                "Languages": "言語",
                "Current": "現在",
                "All Languages": "すべての言語"
            ],
            "Korean": [
                "Languages": "언어",
                "Current": "현재",
                "All Languages": "모든 언어"
            ],
            "Arabic": [
                "Languages": "اللغات",
                "Current": "الحالي",
                "All Languages": "جميع اللغات"
            ],
            "Russian": [
                "Languages": "Языки",
                "Current": "Текущий",
                "All Languages": "Все языки"
            ],
            "Hindi": [
                "Languages": "भाषाएँ",
                "Current": "वर्तमान",
                "All Languages": "सभी भाषाएँ"
            ],
            "Dutch": [
                "Languages": "Talen",
                "Current": "Huidig",
                "All Languages": "Alle talen"
            ],
            "Swedish": [
                "Languages": "Språk",
                "Current": "Aktuellt",
                "All Languages": "Alla språk"
            ],
            "Norwegian": [
                "Languages": "Språk",
                "Current": "Gjeldende",
                "All Languages": "Alle språk"
            ],
            "Finnish": [
                "Languages": "Kielet",
                "Current": "Nykyinen",
                "All Languages": "Kaikki kielet"
            ],
            "Danish": [
                "Languages": "Sprog",
                "Current": "Aktuel",
                "All Languages": "Alle sprog"
            ],
            "Polish": [
                "Languages": "Języki",
                "Current": "Bieżący",
                "All Languages": "Wszystkie języki"
            ],
            "Czech": [
                "Languages": "Jazyky",
                "Current": "Aktuální",
                "All Languages": "Všechny jazyky"
            ],
            "Hungarian": [
                "Languages": "Nyelvek",
                "Current": "Aktuális",
                "All Languages": "Minden nyelv"
            ],
            "Romanian": [
                "Languages": "Limbi",
                "Current": "Curent",
                "All Languages": "Toate limbile"
            ],
            "Bulgarian": [
                "Languages": "Езици",
                "Current": "Текущ",
                "All Languages": "Всички езици"
            ],
            "Croatian": [
                "Languages": "Jezici",
                "Current": "Trenutni",
                "All Languages": "Svi jezici"
            ],
            "Serbian": [
                "Languages": "Језици",
                "Current": "Тренутни",
                "All Languages": "Сви језици"
            ],
            "Slovak": [
                "Languages": "Jazyky",
                "Current": "Aktuálny",
                "All Languages": "Všetky jazyky"
            ]
        ]
        
        return translations[currentLanguage]?[key] ?? key
    }
    
    // NEW FUNCTION: Get localized language names
    func getLocalizedLanguageName(_ languageName: String) -> String {
        let languageTranslations: [String: [String: String]] = [
            "English": [
                "English": "English",
                "Spanish": "Spanish",
                "French": "French",
                "German": "German",
                "Italian": "Italian",
                "Portuguese": "Portuguese",
                "Chinese": "Chinese",
                "Japanese": "Japanese",
                "Korean": "Korean",
                "Arabic": "Arabic",
                "Russian": "Russian",
                "Hindi": "Hindi",
                "Dutch": "Dutch",
                "Swedish": "Swedish",
                "Norwegian": "Norwegian",
                "Finnish": "Finnish",
                "Danish": "Danish",
                "Polish": "Polish",
                "Czech": "Czech",
                "Hungarian": "Hungarian",
                "Romanian": "Romanian",
                "Bulgarian": "Bulgarian",
                "Croatian": "Croatian",
                "Serbian": "Serbian",
                "Slovak": "Slovak"
            ],
            "Spanish": [
                "English": "Inglés",
                "Spanish": "Español",
                "French": "Francés",
                "German": "Alemán",
                "Italian": "Italiano",
                "Portuguese": "Portugués",
                "Chinese": "Chino",
                "Japanese": "Japonés",
                "Korean": "Coreano",
                "Arabic": "Árabe",
                "Russian": "Ruso",
                "Hindi": "Hindi",
                "Dutch": "Holandés",
                "Swedish": "Sueco",
                "Norwegian": "Noruego",
                "Finnish": "Finlandés",
                "Danish": "Danés",
                "Polish": "Polaco",
                "Czech": "Checo",
                "Hungarian": "Húngaro",
                "Romanian": "Rumano",
                "Bulgarian": "Búlgaro",
                "Croatian": "Croata",
                "Serbian": "Serbio",
                "Slovak": "Eslovaco"
            ],
            "French": [
                "English": "Anglais",
                "Spanish": "Espagnol",
                "French": "Français",
                "German": "Allemand",
                "Italian": "Italien",
                "Portuguese": "Portugais",
                "Chinese": "Chinois",
                "Japanese": "Japonais",
                "Korean": "Coréen",
                "Arabic": "Arabe",
                "Russian": "Russe",
                "Hindi": "Hindi",
                "Dutch": "Néerlandais",
                "Swedish": "Suédois",
                "Norwegian": "Norvégien",
                "Finnish": "Finnois",
                "Danish": "Danois",
                "Polish": "Polonais",
                "Czech": "Tchèque",
                "Hungarian": "Hongrois",
                "Romanian": "Roumain",
                "Bulgarian": "Bulgare",
                "Croatian": "Croate",
                "Serbian": "Serbe",
                "Slovak": "Slovaque"
            ],
            "German": [
                "English": "Englisch",
                "Spanish": "Spanisch",
                "French": "Französisch",
                "German": "Deutsch",
                "Italian": "Italienisch",
                "Portuguese": "Portugiesisch",
                "Chinese": "Chinesisch",
                "Japanese": "Japanisch",
                "Korean": "Koreanisch",
                "Arabic": "Arabisch",
                "Russian": "Russisch",
                "Hindi": "Hindi",
                "Dutch": "Niederländisch",
                "Swedish": "Schwedisch",
                "Norwegian": "Norwegisch",
                "Finnish": "Finnisch",
                "Danish": "Dänisch",
                "Polish": "Polnisch",
                "Czech": "Tschechisch",
                "Hungarian": "Ungarisch",
                "Romanian": "Rumänisch",
                "Bulgarian": "Bulgarisch",
                "Croatian": "Kroatisch",
                "Serbian": "Serbisch",
                "Slovak": "Slowakisch"
            ],
            "Italian": [
                "English": "Inglese",
                "Spanish": "Spagnolo",
                "French": "Francese",
                "German": "Tedesco",
                "Italian": "Italiano",
                "Portuguese": "Portoghese",
                "Chinese": "Cinese",
                "Japanese": "Giapponese",
                "Korean": "Coreano",
                "Arabic": "Arabo",
                "Russian": "Russo",
                "Hindi": "Hindi",
                "Dutch": "Olandese",
                "Swedish": "Svedese",
                "Norwegian": "Norvegese",
                "Finnish": "Finlandese",
                "Danish": "Danese",
                "Polish": "Polacco",
                "Czech": "Ceco",
                "Hungarian": "Ungherese",
                "Romanian": "Rumeno",
                "Bulgarian": "Bulgaro",
                "Croatian": "Croato",
                "Serbian": "Serbo",
                "Slovak": "Slovacco"
            ],
            "Portuguese": [
                "English": "Inglês",
                "Spanish": "Espanhol",
                "French": "Francês",
                "German": "Alemão",
                "Italian": "Italiano",
                "Portuguese": "Português",
                "Chinese": "Chinês",
                "Japanese": "Japonês",
                "Korean": "Coreano",
                "Arabic": "Árabe",
                "Russian": "Russo",
                "Hindi": "Hindi",
                "Dutch": "Holandês",
                "Swedish": "Sueco",
                "Norwegian": "Norueguês",
                "Finnish": "Finlandês",
                "Danish": "Dinamarquês",
                "Polish": "Polonês",
                "Czech": "Tcheco",
                "Hungarian": "Húngaro",
                "Romanian": "Romeno",
                "Bulgarian": "Búlgaro",
                "Croatian": "Croata",
                "Serbian": "Sérvio",
                "Slovak": "Eslovaco"
            ],
            "Chinese": [
                "English": "英语",
                "Spanish": "西班牙语",
                "French": "法语",
                "German": "德语",
                "Italian": "意大利语",
                "Portuguese": "葡萄牙语",
                "Chinese": "中文",
                "Japanese": "日语",
                "Korean": "韩语",
                "Arabic": "阿拉伯语",
                "Russian": "俄语",
                "Hindi": "印地语",
                "Dutch": "荷兰语",
                "Swedish": "瑞典语",
                "Norwegian": "挪威语",
                "Finnish": "芬兰语",
                "Danish": "丹麦语",
                "Polish": "波兰语",
                "Czech": "捷克语",
                "Hungarian": "匈牙利语",
                "Romanian": "罗马尼亚语",
                "Bulgarian": "保加利亚语",
                "Croatian": "克罗地亚语",
                "Serbian": "塞尔维亚语",
                "Slovak": "斯洛伐克语"
            ],
            "Japanese": [
                "English": "英語",
                "Spanish": "スペイン語",
                "French": "フランス語",
                "German": "ドイツ語",
                "Italian": "イタリア語",
                "Portuguese": "ポルトガル語",
                "Chinese": "中国語",
                "Japanese": "日本語",
                "Korean": "韓国語",
                "Arabic": "アラビア語",
                "Russian": "ロシア語",
                "Hindi": "ヒンディー語",
                "Dutch": "オランダ語",
                "Swedish": "スウェーデン語",
                "Norwegian": "ノルウェー語",
                "Finnish": "フィンランド語",
                "Danish": "デンマーク語",
                "Polish": "ポーランド語",
                "Czech": "チェコ語",
                "Hungarian": "ハンガリー語",
                "Romanian": "ルーマニア語",
                "Bulgarian": "ブルガリア語",
                "Croatian": "クロアチア語",
                "Serbian": "セルビア語",
                "Slovak": "スロバキア語"
            ],
            "Korean": [
                "English": "영어",
                "Spanish": "스페인어",
                "French": "프랑스어",
                "German": "독일어",
                "Italian": "이탈리아어",
                "Portuguese": "포르투갈어",
                "Chinese": "중국어",
                "Japanese": "일본어",
                "Korean": "한국어",
                "Arabic": "아랍어",
                "Russian": "러시아어",
                "Hindi": "힌디어",
                "Dutch": "네덜란드어",
                "Swedish": "스웨덴어",
                "Norwegian": "노르웨이어",
                "Finnish": "핀란드어",
                "Danish": "덴마크어",
                "Polish": "폴란드어",
                "Czech": "체코어",
                "Hungarian": "헝가리어",
                "Romanian": "루마니아어",
                "Bulgarian": "불가리아어",
                "Croatian": "크로아티아어",
                "Serbian": "세르비아어",
                "Slovak": "슬로바키아어"
            ],
            "Arabic": [
                "English": "الإنجليزية",
                "Spanish": "الإسبانية",
                "French": "الفرنسية",
                "German": "الألمانية",
                "Italian": "الإيطالية",
                "Portuguese": "البرتغالية",
                "Chinese": "الصينية",
                "Japanese": "اليابانية",
                "Korean": "الكورية",
                "Arabic": "العربية",
                "Russian": "الروسية",
                "Hindi": "الهندية",
                "Dutch": "الهولندية",
                "Swedish": "السويدية",
                "Norwegian": "النرويجية",
                "Finnish": "الفنلندية",
                "Danish": "الدانمركية",
                "Polish": "البولندية",
                "Czech": "التشيكية",
                "Hungarian": "الهنغارية",
                "Romanian": "الرومانية",
                "Bulgarian": "البلغارية",
                "Croatian": "الكرواتية",
                "Serbian": "الصربية",
                "Slovak": "السلوفاكية"
            ],
            "Russian": [
                "English": "Английский",
                "Spanish": "Испанский",
                "French": "Французский",
                "German": "Немецкий",
                "Italian": "Итальянский",
                "Portuguese": "Португальский",
                "Chinese": "Китайский",
                "Japanese": "Японский",
                "Korean": "Корейский",
                "Arabic": "Арабский",
                "Russian": "Русский",
                "Hindi": "Хинди",
                "Dutch": "Голландский",
                "Swedish": "Шведский",
                "Norwegian": "Норвежский",
                "Finnish": "Финский",
                "Danish": "Датский",
                "Polish": "Польский",
                "Czech": "Чешский",
                "Hungarian": "Венгерский",
                "Romanian": "Румынский",
                "Bulgarian": "Болгарский",
                "Croatian": "Хорватский",
                "Serbian": "Сербский",
                "Slovak": "Словацкий"
            ],
            "Hindi": [
                "English": "अंग्रेज़ी",
                "Spanish": "स्पेनिश",
                "French": "फ़्रेंच",
                "German": "जर्मन",
                "Italian": "इतालवी",
                "Portuguese": "पुर्तगाली",
                "Chinese": "चीनी",
                "Japanese": "जापानी",
                "Korean": "कोरियाई",
                "Arabic": "अरबी",
                "Russian": "रूसी",
                "Hindi": "हिन्दी",
                "Dutch": "डच",
                "Swedish": "स्वीडिश",
                "Norwegian": "नॉर्वेजियन",
                "Finnish": "फ़िनिश",
                "Danish": "डेनिश",
                "Polish": "पोलिश",
                "Czech": "चेक",
                "Hungarian": "हंगेरियन",
                "Romanian": "रोमानियाई",
                "Bulgarian": "बुल्गारियाई",
                "Croatian": "क्रोएशियाई",
                "Serbian": "सर्बियाई",
                "Slovak": "स्लोवाकियाई"
            ],
            "Dutch": [
                "English": "Engels",
                "Spanish": "Spaans",
                "French": "Frans",
                "German": "Duits",
                "Italian": "Italiaans",
                "Portuguese": "Portugees",
                "Chinese": "Chinees",
                "Japanese": "Japans",
                "Korean": "Koreaans",
                "Arabic": "Arabisch",
                "Russian": "Russisch",
                "Hindi": "Hindi",
                "Dutch": "Nederlands",
                "Swedish": "Zweeds",
                "Norwegian": "Noors",
                "Finnish": "Fins",
                "Danish": "Deens",
                "Polish": "Pools",
                "Czech": "Tsjechisch",
                "Hungarian": "Hongaars",
                "Romanian": "Roemeens",
                "Bulgarian": "Bulgaars",
                "Croatian": "Kroatisch",
                "Serbian": "Servisch",
                "Slovak": "Slowaaks"
            ],
            "Swedish": [
                "English": "Engelska",
                "Spanish": "Spanska",
                "French": "Franska",
                "German": "Tyska",
                "Italian": "Italienska",
                "Portuguese": "Portugisiska",
                "Chinese": "Kinesiska",
                "Japanese": "Japanska",
                "Korean": "Koreanska",
                "Arabic": "Arabiska",
                "Russian": "Ryska",
                "Hindi": "Hindi",
                "Dutch": "Holländska",
                "Swedish": "Svenska",
                "Norwegian": "Norska",
                "Finnish": "Finska",
                "Danish": "Danska",
                "Polish": "Polska",
                "Czech": "Tjeckiska",
                "Hungarian": "Ungerska",
                "Romanian": "Rumänska",
                "Bulgarian": "Bulgariska",
                "Croatian": "Kroatiska",
                "Serbian": "Serbiska",
                "Slovak": "Slovakiska"
            ],
            "Norwegian": [
                "English": "Engelsk",
                "Spanish": "Spansk",
                "French": "Fransk",
                "German": "Tysk",
                "Italian": "Italiensk",
                "Portuguese": "Portugisisk",
                "Chinese": "Kinesisk",
                "Japanese": "Japansk",
                "Korean": "Koreansk",
                "Arabic": "Arabisk",
                "Russian": "Russisk",
                "Hindi": "Hindi",
                "Dutch": "Nederlandsk",
                "Swedish": "Svensk",
                "Norwegian": "Norsk",
                "Finnish": "Finsk",
                "Danish": "Dansk",
                "Polish": "Polsk",
                "Czech": "Tsjekkisk",
                "Hungarian": "Ungarsk",
                "Romanian": "Rumensk",
                "Bulgarian": "Bulgarsk",
                "Croatian": "Kroatisk",
                "Serbian": "Serbisk",
                "Slovak": "Slovakisk"
            ],
            "Finnish": [
                "English": "Englanti",
                "Spanish": "Espanja",
                "French": "Ranska",
                "German": "Saksa",
                "Italian": "Italia",
                "Portuguese": "Portugali",
                "Chinese": "Kiina",
                "Japanese": "Japani",
                "Korean": "Korea",
                "Arabic": "Arabia",
                "Russian": "Venäjä",
                "Hindi": "Hindi",
                "Dutch": "Hollanti",
                "Swedish": "Ruotsi",
                "Norwegian": "Norja",
                "Finnish": "Suomi",
                "Danish": "Tanska",
                "Polish": "Puola",
                "Czech": "Tšekki",
                "Hungarian": "Unkari",
                "Romanian": "Romania",
                "Bulgarian": "Bulgaria",
                "Croatian": "Kroatia",
                "Serbian": "Serbia",
                "Slovak": "Slovakia"
            ],
            "Danish": [
                "English": "Engelsk",
                "Spanish": "Spansk",
                "French": "Fransk",
                "German": "Tysk",
                "Italian": "Italiensk",
                "Portuguese": "Portugisisk",
                "Chinese": "Kinesisk",
                "Japanese": "Japansk",
                "Korean": "Koreansk",
                "Arabic": "Arabisk",
                "Russian": "Russisk",
                "Hindi": "Hindi",
                "Dutch": "Hollandsk",
                "Swedish": "Svensk",
                "Norwegian": "Norsk",
                "Finnish": "Finsk",
                "Danish": "Dansk",
                "Polish": "Polsk",
                "Czech": "Tjekkisk",
                "Hungarian": "Ungarsk",
                "Romanian": "Rumænsk",
                "Bulgarian": "Bulgarsk",
                "Croatian": "Kroatisk",
                "Serbian": "Serbisk",
                "Slovak": "Slovakisk"
            ],
            "Polish": [
                "English": "Angielski",
                "Spanish": "Hiszpański",
                "French": "Francuski",
                "German": "Niemiecki",
                "Italian": "Włoski",
                "Portuguese": "Portugalski",
                "Chinese": "Chiński",
                "Japanese": "Japoński",
                "Korean": "Koreański",
                "Arabic": "Arabski",
                "Russian": "Rosyjski",
                "Hindi": "Hinduski",
                "Dutch": "Holenderski",
                "Swedish": "Szwedzki",
                "Norwegian": "Norweski",
                "Finnish": "Fiński",
                "Danish": "Duński",
                "Polish": "Polski",
                "Czech": "Czeski",
                "Hungarian": "Węgierski",
                "Romanian": "Rumuński",
                "Bulgarian": "Bułgarski",
                "Croatian": "Chorwacki",
                "Serbian": "Serbski",
                "Slovak": "Słowacki"
            ],
            "Czech": [
                "English": "Angličtina",
                "Spanish": "Španělština",
                "French": "Francouzština",
                "German": "Němčina",
                "Italian": "Italština",
                "Portuguese": "Portugalština",
                "Chinese": "Čínština",
                "Japanese": "Japonština",
                "Korean": "Korejština",
                "Arabic": "Arabština",
                "Russian": "Ruština",
                "Hindi": "Hindština",
                "Dutch": "Nizozemština",
                "Swedish": "Švédština",
                "Norwegian": "Norština",
                "Finnish": "Finština",
                "Danish": "Dánština",
                "Polish": "Polština",
                "Czech": "Čeština",
                "Hungarian": "Maďarština",
                "Romanian": "Rumunština",
                "Bulgarian": "Bulharština",
                "Croatian": "Chorvatština",
                "Serbian": "Srbština",
                "Slovak": "Slovenština"
            ],
            "Hungarian": [
                "English": "Angol",
                "Spanish": "Spanyol",
                "French": "Francia",
                "German": "Német",
                "Italian": "Olasz",
                "Portuguese": "Portugál",
                "Chinese": "Kínai",
                "Japanese": "Japán",
                "Korean": "Koreai",
                "Arabic": "Arab",
                "Russian": "Orosz",
                "Hindi": "Hindi",
                "Dutch": "Holland",
                "Swedish": "Svéd",
                "Norwegian": "Norvég",
                "Finnish": "Finn",
                "Danish": "Dán",
                "Polish": "Lengyel",
                "Czech": "Cseh",
                "Hungarian": "Magyar",
                "Romanian": "Román",
                "Bulgarian": "Bolgár",
                "Croatian": "Horvát",
                "Serbian": "Szerb",
                "Slovak": "Szlovák"
            ],
            "Romanian": [
                "English": "Engleză",
                "Spanish": "Spaniolă",
                "French": "Franceză",
                "German": "Germană",
                "Italian": "Italiană",
                "Portuguese": "Portugheză",
                "Chinese": "Chineză",
                "Japanese": "Japoneză",
                "Korean": "Coreeană",
                "Arabic": "Arabă",
                "Russian": "Rusă",
                "Hindi": "Hindi",
                "Dutch": "Olandeză",
                "Swedish": "Suedeză",
                "Norwegian": "Norvegiană",
                "Finnish": "Finlandeză",
                "Danish": "Daneză",
                "Polish": "Poloneză",
                "Czech": "Cehă",
                "Hungarian": "Maghiară",
                "Romanian": "Română",
                "Bulgarian": "Bulgară",
                "Croatian": "Croată",
                "Serbian": "Sârbă",
                "Slovak": "Slovacă"
            ],
            "Bulgarian": [
                "English": "Английски",
                "Spanish": "Испански",
                "French": "Френски",
                "German": "Немски",
                "Italian": "Италиански",
                "Portuguese": "Португалски",
                "Chinese": "Китайски",
                "Japanese": "Японски",
                "Korean": "Корейски",
                "Arabic": "Арабски",
                "Russian": "Руски",
                "Hindi": "Хинди",
                "Dutch": "Холандски",
                "Swedish": "Шведски",
                "Norwegian": "Норвежки",
                "Finnish": "Финландски",
                "Danish": "Датски",
                "Polish": "Полски",
                "Czech": "Чешки",
                "Hungarian": "Унгарски",
                "Romanian": "Румънски",
                "Bulgarian": "Български",
                "Croatian": "Хърватски",
                "Serbian": "Сръбски",
                "Slovak": "Словашки"
            ],
            "Croatian": [
                "English": "Engleski",
                "Spanish": "Španjolski",
                "French": "Francuski",
                "German": "Njemački",
                "Italian": "Talijanski",
                "Portuguese": "Portugalski",
                "Chinese": "Kineski",
                "Japanese": "Japanski",
                "Korean": "Korejski",
                "Arabic": "Arapski",
                "Russian": "Ruski",
                "Hindi": "Hindi",
                "Dutch": "Nizozemski",
                "Swedish": "Švedski",
                "Norwegian": "Norveški",
                "Finnish": "Finski",
                "Danish": "Danski",
                "Polish": "Poljski",
                "Czech": "Češki",
                "Hungarian": "Mađarski",
                "Romanian": "Rumunjski",
                "Bulgarian": "Bulgarski",
                "Croatian": "Hrvatski",
                "Serbian": "Srpski",
                "Slovak": "Slovački"
            ],
            "Serbian": [
                "English": "Енглески",
                "Spanish": "Шпански",
                "French": "Француски",
                "German": "Немачки",
                "Italian": "Италијански",
                "Portuguese": "Португалски",
                "Chinese": "Кинески",
                "Japanese": "Јапански",
                "Korean": "Корејски",
                "Arabic": "Арапски",
                "Russian": "Руски",
                "Hindi": "Хинди",
                "Dutch": "Холандски",
                "Swedish": "Шведски",
                "Norwegian": "Норвешки",
                "Finnish": "Фински",
                "Danish": "Дански",
                "Polish": "Пољски",
                "Czech": "Чешки",
                "Hungarian": "Мађарски",
                "Romanian": "Румунски",
                "Bulgarian": "Бугарски",
                "Croatian": "Хрватски",
                "Serbian": "Српски",
                "Slovak": "Словачки"
            ]
        ]
        
        return languageTranslations[currentLanguage]?[languageName] ?? languageName
    }
}

struct LanguageView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var localizationManager = LocalizationManager()
    
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
        Language(name: "Slovak", code: "sk", flag: "🇸🇰")
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
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
                
                Text(localizationManager.localizedString("Languages"))
                    .font(.custom("Noto Sans", size: 28))
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                
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
            Text(localizationManager.localizedString("Current"))
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                if let currentLang = languages.first(where: { $0.name == localizationManager.currentLanguage }) {
                    LanguageRowView(
                        language: currentLang,
                        isSelected: true,
                        localizationManager: localizationManager
                    ) {
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
            Text(localizationManager.localizedString("All Languages"))
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ForEach(Array(languages.enumerated()), id: \.element.id) { index, language in
                    LanguageRowView(
                        language: language,
                        isSelected: language.name == localizationManager.currentLanguage,
                        localizationManager: localizationManager
                    ) {
                        localizationManager.setLanguage(language.name)
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
    let localizationManager: LocalizationManager
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 24))
                    .frame(width: 30, height: 30)
                
                // Language Name - NOW LOCALIZED!
                Text(localizationManager.getLocalizedLanguageName(language.name))
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
