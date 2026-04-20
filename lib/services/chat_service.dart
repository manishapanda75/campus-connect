import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/book_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatService {
  // Replace this with your actual Gemini API key from https://aistudio.google.com/apikey
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;
  late ChatSession _chat;

  ChatService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 800,
      ),
    );
    _initChat();
  }

  void _initChat() {
    _chat = _model.startChat(
      history: [
        Content.model([
          TextPart(
            'You are CampusBot, a helpful library assistant for college students. '
            'You have access to the college library database. '
            'You help students find books, check availability, and provide free online reading links. '
            'You also help with information about GATE exams for different engineering branches. '
            'Be friendly, concise, and always helpful. '
            'Use relevant emojis to make responses engaging. '
            'If a student asks about a book you don\'t have data on, suggest checking Google Scholar, NPTEL, or OpenLibrary.org. '
            'Keep responses under 150 words unless the student asks for detailed information.',
          )
        ]),
      ],
    );
  }

  void updateContext(List<Book> books) {
    // Injects live book data into a new chat session for accurate responses
    final bookSummary = books.take(20).map((b) =>
        '• ${b.title} by ${b.author} | Status: ${b.isAvailable ? "✅ Available" : b.isCheckedOut ? "📤 Checked Out" : "📖 Reference Only"} | ${b.isAvailable ? "Location: ${b.location}" : ""} | Online: ${b.onlineLink}'
    ).join('\n');

    _chat = _model.startChat(
      history: [
        Content.model([
          TextPart(
            'You are CampusBot, a helpful library assistant for college students. '
            'Here is our library catalog:\n$bookSummary\n\n'
            'You help students find books, check availability, and provide free online reading links. '
            'You also help with information about GATE exams for different engineering branches. '
            'Be friendly, concise, and use emojis. Keep responses under 150 words. '
            'If a book\'s status is "Checked Out", tell them they can still access it online. '
            'For any book not in the library, suggest: archive.org, Google Scholar, NPTEL, or Open Library.',
          )
        ]),
      ],
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'I\'m having trouble responding right now. Please try again!';
    } catch (e) {
      return '⚠️ I\'m having connectivity issues. Please check your internet and try again.';
    }
  }

  /// Quick suggestions for the chat UI
  List<String> get suggestedQuestions => [
    '📚 Is Engineering Mathematics available?',
    '🔗 Where can I read algorithms online?',
    '🎓 Tell me about GATE CSE exam',
    '📖 What books do you have on thermodynamics?',
    '🔍 Which books are currently available?',
    '📅 When is the GATE registration deadline?',
  ];
}
