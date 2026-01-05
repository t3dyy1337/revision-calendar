## 📅 Revision Calendar

A simple iOS app built in **Swift + SwiftUI** that helps you schedule and track revision sessions.  
You can create reminders for any day — and the app automatically generates follow-up reminders to help with spaced repetition.

It was originally built as a small personal project (and my first Swift app) — and later grew into a fully working calendar tool.

---

## ✨ Features

- 📆 Monthly calendar view
- 🔔 Create reminders for specific days
- ♻️ Automatic follow-up reminders (1, 3, 7 days by default — editable)
- ✏️ PencilKit drawing support (attach handwritten notes to a day)
- 📂 Persistent storage using CoreData
- 👆 Tap any day to view / add reminders
- 👈 Swipe left / right to move between months
- 🗑 Delete individual reminders or future repeated reminders
- 🌓 iOS-native look and feel (adaptive layout for iPhone & iPad)

---

## 🛠 Tech Stack

- **Swift**
- **SwiftUI**
- **CoreData** (persistent reminders)
- **PencilKit** (drawing canvas + thumbnails)
- UIKit integration where needed

---

## 🎮 How It Works

### Adding reminders
Tap a day → enter a title → choose follow-up intervals → reminders are created automatically.

### Drawing notes
Tap the small drawing preview → open full-screen canvas → draw → save.  
Thumbnails are generated automatically and shown in the calendar.

### Spaced-repetition scheduling
Default follow-ups are:
1 day
3 days
7 days

…but you can modify them — and the app stores your preferences using `UserDefaults`.

---

## 📸 Screenshots (optional)

> You can add screenshots later by placing images in `/Screenshots` and linking them here.

---

## 🚀 Running the App

1. Clone the repository:

```bash
git clone https://github.com/T3Dyy1337/Revision-Calendar
cd Revision-Calendar
```
2. Open the project in Xcode

3. Select a simulator device andpress
Run ▶
Requires Xcode 15+ and iOS 17+ (PencilKit + SwiftUI features).
