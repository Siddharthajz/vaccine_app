import 'package:stacked/stacked.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';

import '../locator.dart';
import 'base_model.dart';

class SplashPageViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final LocalDbService _localDbService = locator<LocalDbService>();

    Future handleStartUpLogic() async {
        var hasLoggedInUser = await _authenticationService.isUserLoggedIn();

        if (hasLoggedInUser) {
            await _localDbService.isLocalDbInit().then((dbInit){
                if(dbInit){
                    print("DB Initialised!");
                    _navigationService.replaceAndNavigateTo(HomeRoute);
                } else {
                    print("Unable to initialise Local DB");
                }
            });
        } else {
            _navigationService.replaceAndNavigateTo(LoginViewRoute);
        }
    }
}