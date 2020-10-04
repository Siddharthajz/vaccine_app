import 'package:stacked/stacked.dart';

import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/view_models/base_model.dart';

class HomeViewModel extends BaseModel{

    final AuthenticationService _authenticationService = locator<AuthenticationService>();

    int getScheduleNotificationCount() {
        return 3; // TODO:
    }

}