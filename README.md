# Slike - Social Sports Platform

Slike is a comprehensive social media platform designed specifically for sports enthusiasts. It combines the best features of modern social media apps with sports-focused functionality, allowing users to share, discover, and engage with sports-related content through short-form videos, live streaming, and interactive features.

## 🏆 Features

### Core Social Features
- **Video Feed**: TikTok-style vertical video scrolling with sports content
- **User Profiles**: Complete user profiles with sports preferences and achievements
- **Follow System**: Follow other sports enthusiasts and athletes
- **Like & Comment**: Interactive engagement with videos and posts
- **Search & Discovery**: Advanced search with hashtags and user discovery

### Video & Content Creation
- **Video Recording**: Built-in video recorder with filters and effects
- **Video Editor**: Advanced editing tools with transitions and effects
- **Stories Editor**: Create engaging sports stories and highlights
- **Sound Library**: Extensive collection of sports-related audio tracks
- **Hashtag System**: Sports-specific hashtags for better content organization

### Live Streaming & Broadcasting
- **Live Streaming**: Real-time sports broadcasting using Agora RTC
- **Live Chat**: Interactive chat during live streams
- **Live Users Discovery**: Find and join live sports events
- **Background Streaming**: Continue streaming while using other apps

### Communication & Social
- **Chat System**: Direct messaging with other users
- **Group Conversations**: Create group chats for teams or communities
- **Push Notifications**: Real-time notifications for engagement
- **QR Code Sharing**: Easy profile sharing via QR codes

### Advanced Features
- **AI Description Writer**: AI-powered content descriptions using Google Generative AI
- **Gift System**: Virtual gifts and rewards for content creators
- **Wallet System**: In-app currency and transaction management
- **Multi-language Support**: Internationalization for global users
- **Dark/Light Theme**: Customizable app appearance

## 🛠 Tech Stack

### Frontend Framework
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter development

### State Management & Architecture
- **GetX**: State management, dependency injection, and routing
- **MVC Architecture**: Model-View-Controller pattern for clean code organization

### Backend & APIs
- **Dio**: HTTP client for API communication
- **Firebase**: Backend services (Core, Messaging, Authentication)
- **Pusher**: Real-time chat and notifications

### Media & Streaming
- **Agora RTC Engine**: Live streaming and video calling
- **Video Player**: Custom video playback with controls
- **FFmpeg Kit**: Video processing and editing
- **Camera & Image Picker**: Media capture and selection

### Authentication & Security
- **Firebase Authentication**: User authentication system
- **Social Login**: Facebook, Google, and Apple Sign-In
- **OTP Verification**: Phone number verification
- **Permission Handler**: Device permissions management

### UI/UX Libraries
- **Google Fonts**: Typography system
- **Lottie**: Animated graphics and icons
- **Shimmer**: Loading animations
- **Cached Network Image**: Image caching and optimization
- **Convex Bottom Bar**: Custom navigation bar

### Additional Libraries
- **Get Storage**: Local data persistence
- **Connectivity Plus**: Network connectivity monitoring
- **Device Info Plus**: Device information
- **Sentry**: Error tracking and monitoring
- **Google Mobile Ads**: Advertisement integration

## 📱 Demo Video

Watch the Slike app in action:

https://github.com/your-username/flutter_app/assets/slike-demo.mp4

*Note: The demo video showcases the app's key features including video feed, user interactions, live streaming, and content creation tools.*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=2.17.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── controllers/         # Business logic controllers
│   ├── models/             # Data models
│   ├── views/              # UI screens and pages
│   ├── widgets/            # Reusable UI components
│   ├── services/           # API and external services
│   ├── repositories/       # Data access layer
│   ├── bindings/          # Dependency injection
│   ├── middlewares/       # Route and request middlewares
│   ├── helpers/           # Utility functions
│   ├── utils/             # Constants and configurations
│   └── router/            # Navigation and routing
├── assets/
│   ├── images/            # App images and icons
│   ├── animations/        # Lottie animations
│   └── fonts/             # Custom fonts
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Slike** - Connecting sports enthusiasts worldwide through the power of social media and technology.
