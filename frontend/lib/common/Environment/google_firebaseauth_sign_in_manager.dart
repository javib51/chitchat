import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/sign_in_manager.dart';
import 'package:chitchat/common/Models/google_credentials.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class GoogleFirebaseauthSignInManager implements SignInManager<GoogleCredentials> {

  FirebaseAuth _firebaseAuthInstance;
  DAO<User> _userProfileDAO;

  GoogleFirebaseauthSignInManager._private();

  static GoogleFirebaseauthSignInManager getInstance({@required DAO<User> userProfileDAO}) {

    GoogleFirebaseauthSignInManager instance = GoogleFirebaseauthSignInManager._private();

    instance._firebaseAuthInstance = FirebaseAuth.instance;
    instance._userProfileDAO = userProfileDAO;

    return instance;
  }

  @override
  //Logic must be different because Google login flow is not preceded with a signup process. At every login, presence of the user profile in the database must be checked and, in case found, returned.
  Future<User> signIn(GoogleCredentials credentials) async {

    FirebaseUser user = await this._firebaseAuthInstance.signInWithGoogle(idToken: credentials.idToken, accessToken: credentials.accessToken);

    print("Google signed-in user ID: ${user.uid}");

    User userToCreate = User(uid: user.uid, nickname: user.displayName, pictureURL: user.photoUrl);
    User userToReturn;

    try {
      await this._userProfileDAO.create(userToCreate, false);
      userToReturn = userToCreate;
    } on DAOException {
      userToReturn = await this._userProfileDAO.get<String>({"id": QueryEntry(comparisonValue: user.uid, l: ValueComparisonLogic.e)});
    }

    print("Returning user: $userToReturn");
    return userToReturn;
  }

  @override
  Future<void> signOut() async {
    await this._firebaseAuthInstance.signOut();
  }

  @override
  Future<bool> isUserSignedIn() async {
    return (await this._firebaseAuthInstance.currentUser()) != null;
  }

  @override
  Future<User> getSignedInUser() async {

    FirebaseUser currentUser = await this._firebaseAuthInstance.currentUser();

    return await this._userProfileDAO.get<String>({"id": QueryEntry(comparisonValue: currentUser.uid, l: ValueComparisonLogic.e)});
  }
}