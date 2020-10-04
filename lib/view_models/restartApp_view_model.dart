import 'package:stacked/stacked.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';

import '../locator.dart';
import 'base_model.dart';

class RestartAppViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final NavigationService _navigationService = locator<NavigationService>();

    Future handleStartUpLogic(String previousPageRoute) async {
        var hasLoggedInUser = await _authenticationService.isUserLoggedIn();

        if (hasLoggedInUser) {
            _navigationService.replaceAndNavigateTo(previousPageRoute);
        } else {
            _navigationService.replaceAndNavigateTo(LoginViewRoute);
        }
    }
}