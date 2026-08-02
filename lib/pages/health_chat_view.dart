import 'package:app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HealthChatView extends StatefulWidget {
  const HealthChatView({Key? key}) : super(key: key);

  @override
  State<HealthChatView> createState() => _HealthChatViewState();
}

class _HealthChatViewState extends State<HealthChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool _isLoading = false;

  // Usa la MISMA API Key de la vista anterior (HeroPage). REVOCA en OpenAI si expuesta.
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  final String apiToken = openAiApiKey; 

  Future<void> _saveMessage(String role, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    List<String> saved = prefs.getStringList('health_chat_history') ?? []; // Prefijo único para este chat
    saved.add("$now|$role|$message");
    await prefs.setStringList('health_chat_history', saved);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "message": text});
      _isLoading = true;
    });

    _controller.clear();
    _saveMessage("user", text);

    String reply = "Lo siento, no puedo responder en este momento.";

    try {
      // Construye historial de mensajes para contexto (mejora respuestas)
      List<Map<String, String>> apiMessages = [
        {
          "role": "system",
          "content": "Eres un asistente experto SOLO en temas de salud, bienestar, estoicismo, mindfulness, comida saludable, ejercicio, meditación y respiración. Responde SIEMPRE en español neutro, positivo y motivador. Si la pregunta está fuera de estos temas, responde cortésmente: 'Lo siento, solo puedo ayudarte con temas de salud y bienestar. ¿Qué pregunta tienes sobre eso?' Usa acentos correctos en UTF-8. Mantén respuestas cortas (máx 100 palabras)."
        },
      ];

      // Agrega historial reciente (últimos 10 mensajes para contexto, sin sobrecargar tokens)
      int startIndex = messages.length > 10 ? messages.length - 10 : 0;
      for (int i = startIndex; i < messages.length; i++) {
        String msgContent = messages[i]["message"] ?? ""; // Null safety: si null, string vacío
        apiMessages.add({"role": messages[i]["role"] == "user" ? "user" : "assistant", "content": msgContent});
      }
      apiMessages.add({"role": "user", "content": text}); // El nuevo mensaje

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiToken",
          "Content-Type": "application/json; charset=utf-8", // Fuerza UTF-8
          "Accept-Charset": "utf-8",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": apiMessages,
          "max_tokens": 200,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        // Decodificación UTF-8 forzada para acentos correctos
        final bodyString = utf8.decode(response.bodyBytes);
        final data = jsonDecode(bodyString);
        reply = data["choices"][0]["message"]["content"].trim();
      } else {
        print("Error HTTP ${response.statusCode}: ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e, stack) {
      print("Excepción: $e");
      print(stack);
      reply = "Error al conectarse al servicio de chat.";
    }

    setState(() {
      messages.add({"role": "bot", "message": reply});
      _isLoading = false;
    });
    _saveMessage("bot", reply);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration( // Corregido: era "navegación:" por error de copia
          color: isUser ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg["message"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('health_chat_history') ?? [];
    setState(() {
      messages = saved.map((s) {
        final parts = s.split("|");
        if (parts.length == 3) {
          return {"role": parts[1], "message": parts[2]};
        } else {
          return {"role": "bot", "message": s};
        }
      }).toList();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Salud & Bienestar"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (_, index) => _buildMessage(messages[index]),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Pregunta sobre salud, ejercicio, meditación, estoicismo o mindfulness...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) => _sendMessage(value), // Envía con Enter
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.teal),
                    onPressed: () => _sendMessage(_controller.text),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}