import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/features/authentication/view_models/login_view_models.dart';
import 'package:mood_tracker/features/authentication/widgets/form_button.dart';
import 'package:mood_tracker/utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String routeName = "login";
  static String routeURL = "/login";

  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool _obscureText = true;

  void _toogleObscureText() {
    _obscureText = !_obscureText;
    setState(() {});
  }

  void _onSignUpTap(BuildContext context) {}

  void _onLoginTap(BuildContext context) {
    context.pop();
  }

  void _onSubmitTap() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        ref
            .read(loginProvider.notifier)
            .login(formData["email"]!, formData["password"]!, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size40,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Gaps.v80,
                LottieBuilder.asset(
                  "assets/animations/emotion-lottie.json",
                  repeat: true,
                  width: 240,
                  height: 240,
                ),
                // Gaps.v80,
                Text(
                  "오늘의 기분을 기록하고, \n더 행복한 내일을 만들어보세요.",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(height: 2),
                  textAlign: TextAlign.center,
                ),
                Gaps.v20,
                TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail),
                    label: const Text("Email"),
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Please write your email";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      formData['email'] = newValue;
                    }
                  },
                ),
                Gaps.v16,
                TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key),
                    label: const Text("Password"),
                    hintText: 'Minimum 8 characters',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toogleObscureText,
                          child: FaIcon(
                            _obscureText
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            color: Colors.grey.shade500,
                            size: Sizes.size20,
                          ),
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Please write your password";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    if (newValue != null) {
                      formData['password'] = newValue;
                    }
                  },
                ),

                Gaps.v16,
                GestureDetector(
                  onTap: _onSubmitTap,
                  child: FormButton(
                    disabled: ref.watch(loginProvider).isLoading,
                    text: "로 그 인",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size32,
          horizontal: Sizes.size40,
        ),
        height: 160,
        // shadowColor: Colors.black,
        // surfaceTintColor: Colors.grey.shade100,
        color: isDarkMode(context) ? Colors.black : const Color(0xffffffff),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () => _onLoginTap(context),
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "회 원 가 입",
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                )),
            // const Text("Don't have an account?"),
            Gaps.v20,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gaps.h5,
                Opacity(
                  opacity: 0.7,
                  child: Text(
                    "아직 계정이 없으신가요?",
                    style: Theme.of(context).textTheme.titleSmall!,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
