import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/busy_button.dart';
import 'package:vaccineApp/ui/widgets/expansion_list.dart';
import 'package:vaccineApp/ui/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/ui/widgets/text_link.dart';
import 'package:vaccineApp/view_models/signup_view_model.dart';

class SignUpView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignUpViewModel>.reactive(
      viewModelBuilder: () => SignUpViewModel(),
      builder: (context, model, child) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Text('Register', style: TextStyle(fontSize: 38),)),
              verticalSpaceLarge,
              InputField(
                placeholder: 'Full Name',
                controller: fullNameController,
              ),
              verticalSpaceSmall,
              InputField(
                placeholder: 'Email',
                controller: emailController,
              ),
              verticalSpaceSmall,
              InputField(
                placeholder: 'Password',
                password: true,
                controller: passwordController,
                additionalNote: 'Password has to be a minimum of 6 characters.',
              ),
              verticalSpaceSmall,
//              ExpansionList<String>(
//                  items: ['Admin', 'User'],
//                  title: model.selectedRole,
//                  onItemSelected: model.setSelectedRole),
//              verticalSpaceMedium,
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BusyButton(
                    title: 'Sign Up',
                    busy: model.busy,
                    onPressed: () {
                      model.signUp( // TODO: additional params required
                          email: emailController.text,
                          password: passwordController.text,
                          fname: fullNameController.text);
                    },
                  )
                ],
              ),
              verticalSpaceMedium,
              Center(
                child: TextLink(
                  'Login if you already have an account.',
                  onPressed: () {
                    model.navigateToSignIn();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
