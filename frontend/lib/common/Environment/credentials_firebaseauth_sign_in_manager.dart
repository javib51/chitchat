import 'package:chitchat/common/Environment/dao.dart';
import 'package:chitchat/common/Environment/sign_in_manager.dart';
import 'package:chitchat/common/Models/query_entry.dart';
import 'package:chitchat/common/Models/signup_credentials.dart';
import 'package:chitchat/common/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class UserCredentialsFirebaseauthSignInManager implements SignInManager<SignupCredentials> {

  FirebaseAuth _firebaseAuthInstance;
  DAO<User> _userProfileDAO;

  UserCredentialsFirebaseauthSignInManager._private();

  static UserCredentialsFirebaseauthSignInManager getInstance({@required DAO<User> userProfileDAO}) {

    UserCredentialsFirebaseauthSignInManager instance = UserCredentialsFirebaseauthSignInManager._private();

    instance._firebaseAuthInstance = FirebaseAuth.instance;
    instance._userProfileDAO = userProfileDAO;

    return instance;
  }

  @override
  Future<User> signIn(SignupCredentials credentials) async {
    FirebaseUser user = await this._firebaseAuthInstance.signInWithEmailAndPassword(email: credentials.email, password: credentials.password);

    return await this._userProfileDAO.get<String>({"id": QueryEntry(comparisonValue: user.uid, l: ValueComparisonLogic.e)});
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
    print("*****");
    print(currentUser);
    print("*****");

    return await this._userProfileDAO.get<String>({"id": QueryEntry(comparisonValue: currentUser.uid, l: ValueComparisonLogic.e)});
  }

}