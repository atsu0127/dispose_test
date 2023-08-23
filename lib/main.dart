import 'package:dispose_test/logic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: RootPage(),
    );
  }
}

class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider);
    return Container(
      child: appUser.when(
        data: (data) => data != null ? const HomePage() : const SignInPage(),
        error: (e, s) => const SignInPage(),
        loading: () => const SignInPage(),
      ),
    );
  }
}

/// SignInPage関係
final emailTextEditingController =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

final passwordTextEditingController =
    Provider.autoDispose<TextEditingController>((_) => TextEditingController());

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: const [
            _EmailTextField(),
            SizedBox(height: 16),
            _PasswordTextField(),
            SizedBox(height: 16),
            _SignInButton(),
            SizedBox(height: 16),
            _GoToNavigationOpePage(),
          ],
        ),
      ),
    );
  }
}

class _EmailTextField extends ConsumerWidget {
  const _EmailTextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: ref.watch(emailTextEditingController),
      decoration: const InputDecoration(
        icon: Icon(Icons.mail),
        hintText: 'example@prelude.com',
        labelText: 'メールアドレス *',
      ),
    );
  }
}

class _PasswordTextField extends ConsumerWidget {
  const _PasswordTextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: ref.watch(passwordTextEditingController),
      decoration: const InputDecoration(
        icon: Icon(Icons.lock),
        labelText: 'パスワード *',
      ),
    );
  }
}

class _SignInButton extends ConsumerWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailTextEditingController);
    final passwordController = ref.watch(passwordTextEditingController);

    return FilledButton(
      onPressed: () {
        ref.read(authRepositoryProvider).signIn(
              email: emailController.text,
              password: passwordController.text,
            );
      },
      child: const Text('ログイン'),
    );
  }
}

class _GoToNavigationOpePage extends StatelessWidget {
  const _GoToNavigationOpePage();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NavigatorOpePage(),
          ),
        );
      },
      child: const Text('Navigator操作へ'),
    );
  }
}

/// SignInからの遷移先
class NavigatorOpePage extends StatelessWidget {
  const NavigatorOpePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('pop'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInPage(),
                ),
                (_) => false);
          },
          child: const Text('pushAndRemoveUntil'),
        ),
      ],
    ));
  }
}

/// サインイン後のページ関連
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: const [
              _UserInfo(),
              SizedBox(height: 16),
              _SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserInfo extends ConsumerWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider);
    return Text(user.asData?.value ?? 'ログインしていません');
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () {
        ref.read(authRepositoryProvider).signOut();
      },
      child: const Text('ログアウト'),
    );
  }
}
