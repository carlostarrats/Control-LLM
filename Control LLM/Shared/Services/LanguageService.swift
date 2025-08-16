import Foundation
import SwiftUI

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

class LanguageService: ObservableObject {
    static let shared = LanguageService()
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selectedLanguage"
    
    @Published var selectedLanguage: String {
        didSet {
            userDefaults.set(selectedLanguage, forKey: languageKey)
            NotificationCenter.default.post(name: .languageDidChange, object: selectedLanguage)

            // Donate the change to Shortcuts
            let newPrompt = getSystemPrompt()
            ShortcutsIntegrationHelper.shared.donateSystemBehaviorModified(prompt: newPrompt, behaviorType: "Language Change")
        }
    }
    
    private init() {
        // Always default to English for any model
        self.selectedLanguage = userDefaults.string(forKey: languageKey) ?? "English"
        
        // Ensure English is always the default language
        ensureEnglishDefault()
    }
    
    /// Ensure English is always the default language
    private func ensureEnglishDefault() {
        // If no language is set or if it's not English, set it to English
        if selectedLanguage != "English" {
            self.selectedLanguage = "English"
        }
    }
    
    /// Reset language to English when switching models
    func resetToEnglish() {
        self.selectedLanguage = "English"
        // Note: userDefaults.set is automatically called in the didSet of selectedLanguage
    }
    
    /// Get the system prompt for the selected language
    func getSystemPrompt() -> String {
        switch selectedLanguage {
                        case "English":
                    return "You are a helpful assistant. Answer questions directly and concisely. For real-time information you don't have access to, say 'I don't have access to current [time/weather/etc]' then offer what general information you can. Do not repeat yourself."
            
        case "Spanish":
            return "Eres un asistente útil y amigable que habla de manera natural y conversacional. Mantén las respuestas cortas cuando sea posible, y claras y casuales—como si estuvieras hablando con una persona real. No preguntes al usuario cómo está, cómo va su día, o charlas similares. Solo haz preguntas de seguimiento si son necesarias para completar la solicitud del usuario o aclarar su intención. Nunca agregues relleno. Suena bien en voz alta, y sé honesto si no estás seguro de algo."
            
        case "French":
            return "Tu es un assistant utile et amical qui parle sur un ton naturel et conversationnel. Garde les réponses courtes quand c'est possible, et claires et décontractées—comme si tu parlais à une vraie personne. Ne demande pas à l'utilisateur comment il va, comment se passe sa journée, ou des banalités similaires. Ne pose des questions de suivi que si elles sont nécessaires pour compléter la demande de l'utilisateur ou clarifier son intention. N'ajoute jamais de remplissage. Sonne bien à voix haute, et sois honnête si tu n'es pas sûr de quelque chose."
            
        case "German":
            return "Du bist ein hilfreicher, freundlicher Assistent, der in einem natürlichen, gesprächigen Ton spricht. Halte Antworten kurz, wenn möglich, und klar und lässig—als würdest du mit einer echten Person sprechen. Frage den Benutzer nicht, wie es ihm geht, wie sein Tag läuft oder ähnlichen Small Talk. Stelle nur Nachfragen, wenn sie nötig sind, um die Anfrage des Benutzers zu vervollständigen oder seine Absicht zu klären. Füge niemals Füllmaterial hinzu. Klinge gut laut und sei ehrlich, wenn du dir bei etwas nicht sicher bist."
            
        case "Italian":
            return "Sei un assistente utile e amichevole che parla con un tono naturale e conversazionale. Mantieni le risposte brevi quando possibile, e chiare e informali—come se stessi parlando con una persona reale. Non chiedere all'utente come sta, come va la sua giornata, o chiacchiere simili. Fai domande di follow-up solo se sono necessarie per completare la richiesta dell'utente o chiarire la sua intenzione. Non aggiungere mai riempitivo. Suona bene ad alta voce, e sii onesto se non sei sicuro di qualcosa."
            
        case "Portuguese":
            return "Você é um assistente útil e amigável que fala em um tom natural e conversacional. Mantenha as respostas curtas quando possível, e claras e casuais—como se estivesse falando com uma pessoa real. Não pergunte ao usuário como ele está, como está seu dia, ou conversas similares. Faça perguntas de acompanhamento apenas se forem necessárias para completar a solicitação do usuário ou esclarecer sua intenção. Nunca adicione preenchimento. Soe bem em voz alta, e seja honesto se não tiver certeza de algo."
            
        case "Korean":
            return "당신은 자연스럽고 대화적인 톤으로 말하는 도움이 되는 친근한 어시스턴트입니다. 가능할 때는 답변을 짧게, 명확하고 편안하게 유지하세요—마치 실제 사람과 대화하는 것처럼. 사용자에게 어떻게 지내는지, 하루가 어떻게 지나가는지, 또는 유사한 잡담을 묻지 마세요. 사용자의 요청을 완성하거나 의도를 명확히 하는 데 필요한 경우에만 후속 질문을 하세요. 절대 채우기 재료를 추가하지 마세요. 소리 내어 말할 때 좋게 들리며, 확실하지 않은 것이 있으면 솔직하게 말하세요."
            
        case "Japanese":
            return "あなたは自然で会話的なトーンで話す、役立つ親しみやすいアシスタントです。可能な限り回答を短く、明確でカジュアルに保ってください—実際の人と話しているかのように。ユーザーに調子はどうか、一日がどう過ぎているか、または同様の世間話を尋ねないでください。ユーザーのリクエストを完了したり意図を明確にするために必要な場合のみ、フォローアップの質問をしてください。決して埋め物を追加しないでください。声に出して話すときに良く聞こえ、何か確信がない場合は正直に言ってください。"
            
        case "Dutch":
            return "Je bent een behulpzame, vriendelijke assistent die spreekt in een natuurlijke, conversatiele toon. Houd antwoorden kort wanneer mogelijk, en duidelijk en casual—alsof je praat met een echt persoon. Vraag de gebruiker niet hoe het met hem gaat, hoe zijn dag verloopt, of vergelijkbare small talk. Stel alleen vervolgvragen als ze nodig zijn om het verzoek van de gebruiker te voltooien of zijn intentie te verduidelijken. Voeg nooit vulmateriaal toe. Klink goed hardop, en wees eerlijk als je ergens niet zeker van bent."
            
        case "Russian":
            return "Ты полезный и дружелюбный помощник, который говорит естественным, разговорным тоном. Держи ответы короткими, когда это возможно, и ясными и непринужденными—как будто ты разговариваешь с настоящим человеком. Не спрашивай пользователя, как его дела, как проходит его день, или подобные светские разговоры. Задавай уточняющие вопросы только если они необходимы для выполнения запроса пользователя или прояснения его намерений. Никогда не добавляй лишнего. Звучи хорошо вслух, и будь честен, если ты в чем-то не уверен."
            
                        default:
                    return "You are a helpful assistant. Answer questions directly and concisely. Do not repeat yourself."
        }
    }
    
    /// Get the language code for the selected language (useful for future features)
    func getLanguageCode() -> String {
        switch selectedLanguage {
        case "English": return "en"
        case "Spanish": return "es"
        case "French": return "fr"
        case "German": return "de"
        case "Italian": return "it"
        case "Portuguese": return "pt"
        case "Korean": return "ko"
        case "Japanese": return "ja"
        case "Dutch": return "nl"
        case "Russian": return "ru"
        default: return "en"
        }
    }
    
    /// Get localized UI text
    func getLocalizedText(_ key: String) -> String {
        switch selectedLanguage {
        case "Spanish":
            return getSpanishText(key)
        case "French":
            return getFrenchText(key)
        case "German":
            return getGermanText(key)
        case "Italian":
            return getItalianText(key)
        case "Portuguese":
            return getPortugueseText(key)
        case "Korean":
            return getKoreanText(key)
        case "Japanese":
            return getJapaneseText(key)
        case "Dutch":
            return getDutchText(key)
        case "Russian":
            return getRussianText(key)
        default:
            return getEnglishText(key)
        }
    }
    
    // MARK: - Language-specific text methods
    
    private func getEnglishText(_ key: String) -> String {
        switch key {
        case "settings": return "Settings"
        case "language": return "Language"
        case "chat_history": return "Chat History"
        case "models": return "Models"
        case "appearance": return "Appearance"
        case "voice": return "Voice"
        case "agents": return "Agents"
        case "credits": return "Credits"
        default: return key
        }
    }
    
    private func getSpanishText(_ key: String) -> String {
        switch key {
        case "settings": return "Configuración"
        case "language": return "Idioma"
        case "chat_history": return "Historial de Chat"
        case "models": return "Modelos"
        case "appearance": return "Apariencia"
        case "voice": return "Voz"
        case "agents": return "Agentes"
        case "credits": return "Créditos"
        default: return getEnglishText(key)
        }
    }
    
    private func getFrenchText(_ key: String) -> String {
        switch key {
        case "settings": return "Paramètres"
        case "language": return "Langue"
        case "chat_history": return "Historique de Chat"
        case "models": return "Modèles"
        case "appearance": return "Apparence"
        case "voice": return "Voix"
        case "agents": return "Agents"
        case "credits": return "Crédits"
        default: return getEnglishText(key)
        }
    }
    
    private func getGermanText(_ key: String) -> String {
        switch key {
        case "settings": return "Einstellungen"
        case "language": return "Sprache"
        case "chat_history": return "Chat-Verlauf"
        case "models": return "Modelle"
        case "appearance": return "Erscheinungsbild"
        case "voice": return "Stimme"
        case "agents": return "Agenten"
        case "credits": return "Credits"
        default: return getEnglishText(key)
        }
    }
    
    private func getItalianText(_ key: String) -> String {
        switch key {
        case "settings": return "Impostazioni"
        case "language": return "Lingua"
        case "chat_history": return "Cronologia Chat"
        case "models": return "Modelli"
        case "appearance": return "Aspetto"
        case "voice": return "Voce"
        case "agents": return "Agenti"
        case "credits": return "Crediti"
        default: return getEnglishText(key)
        }
    }
    
    private func getPortugueseText(_ key: String) -> String {
        switch key {
        case "settings": return "Configurações"
        case "language": return "Idioma"
        case "chat_history": return "Histórico de Chat"
        case "models": return "Modelos"
        case "appearance": return "Aparência"
        case "voice": return "Voz"
        case "agents": return "Agentes"
        case "credits": return "Créditos"
        default: return getEnglishText(key)
        }
    }
    
    private func getKoreanText(_ key: String) -> String {
        switch key {
        case "settings": return "설정"
        case "language": return "언어"
        case "chat_history": return "채팅 기록"
        case "models": return "모델"
        case "appearance": return "외관"
        case "voice": return "음성"
        case "agents": return "에이전트"
        case "credits": return "크레딧"
        default: return getEnglishText(key)
        }
    }
    
    private func getJapaneseText(_ key: String) -> String {
        switch key {
        case "settings": return "設定"
        case "language": return "言語"
        case "chat_history": return "チャット履歴"
        case "models": return "モデル"
        case "appearance": return "外観"
        case "voice": return "音声"
        case "agents": return "エージェント"
        case "credits": return "クレジット"
        default: return getEnglishText(key)
        }
    }
    
    private func getDutchText(_ key: String) -> String {
        switch key {
        case "settings": return "Instellingen"
        case "language": return "Taal"
        case "chat_history": return "Chat Geschiedenis"
        case "models": return "Modellen"
        case "appearance": return "Uiterlijk"
        case "voice": return "Stem"
        case "agents": return "Agenten"
        case "credits": return "Credits"
        default: return getEnglishText(key)
        }
    }
    
    private func getRussianText(_ key: String) -> String {
        switch key {
        case "settings": return "Настройки"
        case "language": return "Язык"
        case "chat_history": return "История чата"
        case "models": return "Модели"
        case "appearance": return "Внешний вид"
        case "voice": return "Голос"
        case "agents": return "Агенты"
        case "credits": return "Кредиты"
        default: return getEnglishText(key)
        }
    }
}
