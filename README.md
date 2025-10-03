# 📱 Flutter Gemini Smart Assistant

A Flutter-based intelligent assistant application that combines static JSON knowledge base with Google Gemini AI for a comprehensive support experience. Choose between three different assistant modes based on your needs.

---

<img src="assets/screenshots/demo_app.png" alt="Home Screen"/>

## 🚀 Features

### 🤖 Three Assistant Modes
1. **App Assistant (Static JSON-based)**
  - Local knowledge base with pre-defined solutions for common app issues
  - Category-based navigation with intuitive UI
  - Keyword matching for quick problem resolution
  - Fallback options (FAQ, Contact Us, Raise Request) after 3 unrecognized queries

2. **AI Assistant (Gemini AI-powered)**
  - Advanced AI conversations using Google Gemini API
  - Natural language processing for complex queries
  - Image support - upload images for AI analysis
  - Chat history with persistent storage

3. **Hybrid Assistant (Best of Both Worlds)**
  - Smart routing - first checks local knowledge base, then falls back to AI
  - Visual indicators showing source of response (Local 📚 vs AI 🤖)
  - Seamless integration between static content and AI capabilities
  - Optimized performance with fast local responses for common issues

---

## 🎯 Core Features

### 📚 Local Knowledge Base
- Static JSON-based responses loaded from assets folder
- Structured categories: Notifications, UI/UX, Payments, Network, Account, Performance, Downloads, Miscellaneous
- Keyword matching with fuzzy search capabilities
- Quick solutions for common app issues

### 🧠 AI-Powered Intelligence
- Google Gemini AI integration for complex queries
- Natural language understanding
- Image analysis and description
- Context-aware responses

### 🔄 Smart Hybrid System
- Intelligent routing - local first, AI fallback
- Visual source indicators (Green for local, Purple for AI)
- Typing indicators during AI processing
- Seamless user experience

### 🎨 Enhanced UI/UX
- Beautiful gradient backgrounds and modern design
- Distinct message bubbles for user, local assistant, and AI
- Smooth animations and transitions
- Responsive design for all screen sizes

---

## 📸 Screenshots

🏠 **Home Screen - Assistant Selection**  
<img src="assets/screenshots/one.png" alt="Home Screen" width="300"/>

📱 **App Assistant - Local Knowledge**  
<img src="assets/screenshots/two.png" alt="App Assistant" width="300"/> 

🤖 **AI Assistant - Gemini AI**  
<img src="assets/screenshots/gem_three.png" alt="AI Assistant" width="300"/>

🔄 **Hybrid Assistant - Smart Routing**  
<img src="assets/screenshots/hybrid_three.png" alt="Hybrid Local Response" width="300"/> <img src="assets/screenshots/hybrid_ai.png" alt="Hybrid AI Response" width="300"/>

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                 # App entry point with provider setup
├── gen_ai/                  # Gemini AI integration
│   ├── providers/
│   │   ├── chat_provider.dart
│   │   └── settings_provider.dart
│   ├── models/
│   │   └── message.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/             # Reusable UI components
├── assistant/               # Static chat assistant
│   ├── models/
│   │   └── issue.dart
│   ├── ui/
│   │   ├── app_assistant.dart
│   │   ├── profile_page.dart
│   │   └── view/           # UI components
│   └── utils/              # Helper utilities
├── hybrid/                 # Hybrid assistant
│   └── hybrid_chat_screen.dart
assets/
├── app_full_issues.json    # Local knowledge base
└── screenshots/           # App demonstration images
```

---

## 🛠️ Tech Stack
- **Flutter (Dart)** - Cross-platform framework
- **Google Gemini AI** - Advanced AI capabilities
- **Provider** - State management
- **Hive** - Local database for chat history
- **Static JSON** - Local knowledge base
- **Image Picker** - Image upload functionality

---

## 🚀 Future Enhancements
- Voice input/output support
- Multi-language support
- Advanced analytics
- Push notifications for ticket updates
- Integration with external ticketing systems

---

Built with ❤️ using Flutter & Google Gemini AI
