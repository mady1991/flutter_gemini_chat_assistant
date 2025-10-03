import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:static_chat_assitant/gen_ai/screens/home_screen.dart';
import 'gen_ai/providers/chat_provider.dart';
import 'gen_ai/providers/settings_provider.dart';
import 'assistant/ui/app_assistant.dart'; // Your static assistant
import 'gen_ai/themes/my_theme.dart';
import 'hybrid/hybrid_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ChatProvider.initHive();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _setTheme();
    super.initState();
  }

  void _setTheme() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Assistant Pro',
      theme: context.watch<SettingsProvider>().isDarkMode
          ? darkTheme
          : lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HybridChatHome(),
    );
  }
}


class HybridChatHome extends StatelessWidget {
  const HybridChatHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Assistant Pro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Assistant (Static JSON)
              _buildAssistantCard(
                context,
                'Local App Assistant',
                'Pre-defined solutions for common app issues',
                Icons.support_agent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppAssistant()),
                ),
              ),

              const SizedBox(height: 20),

              // AI Assistant (Gemini)
              _buildAssistantCard(
                context,
                'Gemini AI Assistant',
                'Gemini assistant for your normal question',
                Icons.star,
                () {
                  final chatProvider = context.read<ChatProvider>();
                  chatProvider.prepareChatRoom(isNewChat: true, chatID: '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildAssistantCard(
                context,
                'Hybrid Assistant',
                'Advanced AI help for complex questions',
                Icons.smart_toy,
                () {
                  final chatProvider = context.read<ChatProvider>();
                  chatProvider.prepareChatRoom(isNewChat: true, chatID: '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HybridChatScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
