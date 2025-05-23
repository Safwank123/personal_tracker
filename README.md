# personal_tracker

A new Flutter project for tracking personal activities and data.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Supabase Setup

This project uses [Supabase](https://supabase.com/) as its backend for data storage and management. To set up Supabase for this project, follow these steps:

1.  **Create a Supabase Project:**
    -   Go to [https://supabase.com/](https://supabase.com/) and create a new project.
    -   Note down your https://ztqqupflharvxrllpbbg.supabase.co and eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0cXF1cGZsaGFydnhybGxwYmJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNzg5MzIsImV4cCI6MjA2MDY1NDkzMn0.Sh-hVI8MlShdLp6rCCKLYzxBBE38dpeuaoXLu4VNwX0 from the project settings (API tab).

2.  **Set Up the Database Schema:**
    -   In your Supabase project dashboard, navigate to the "SQL Editor."
    -   Create the necessary tables for your personal tracker. For example, if you're tracking expenses, you might need a table like `expenses`:

    ```sql
    CREATE TABLE expenses (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES auth.users(id) NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        date TIMESTAMPTZ DEFAULT NOW()
    );

    ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

   
    CREATE POLICY "Allow users to insert their own expenses" ON expenses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

    
    CREATE POLICY "Allow users to select their own expenses" ON expenses
    FOR SELECT WITH CHECK (auth.uid() = user_id);

   
    CREATE POLICY "Allow users to update their own expenses" ON expenses
    FOR UPDATE WITH CHECK (auth.uid() = user_id);

    
    CREATE POLICY "Allow users to delete their own expenses" ON expenses
    FOR DELETE WITH CHECK (auth.uid() = user_id);
    ```

    -   You might need other tables depending on what you're tracking (e.g., goals, habits, etc.).

3.  **Update Flutter Code:**
    -   Open your Flutter project's `main.dart` file.
    -   Ensure you have the `supabase_flutter` package added to your `pubspec.yaml`.
    -   Initialize Supabase with your Project URL and Anon Key:

    ```dart
    import 'package:flutter/material.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';

    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();
        url: 'https://ztqqupflharvxrllpbbg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0cXF1cGZsaGFydnhybGxwYmJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNzg5MzIsImV4cCI6MjA2MDY1NDkzMn0.Sh-hVI8MlShdLp6rCCKLYzxBBE38dpeuaoXLu4VNwX0'
  
      await Supabase.initialize(
        
      );

      runApp(const MyApp());
    }

   

-   **Hot Reload**: Quickly injects code changes into the running app, preserving the app's state. Use it for UI tweaks and minor logic changes. Trigger with `r` in the terminal or your IDE's button.
-   **Hot Restart**: Restarts the entire app with the new code, discarding the current state. Use it for structural changes, adding/removing packages, or when hot reload doesn't apply changes. Trigger with `R` in the terminal or your IDE's button.

## Further Development

This is just the initial setup. As you continue developing your personal tracker, you'll likely:

-   Implement user authentication using Supabase Auth.
-   Build UI to display and interact with your tracked data.
-   Write more complex database queries and logic.
-   Consider using state management Provider
#   p e r s o n a l _ t r a c k e r  
 