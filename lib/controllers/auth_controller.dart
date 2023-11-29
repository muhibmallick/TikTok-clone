import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/models/user.dart' as model;
import '../Constants.dart';
import '../Views/Screens/Auth/Login_Screen.dart';
import '../Views/Screens/home_screen.dart';

class AuthController extends GetxController {
  // Singleton Instance Retrieval:
// - This line fetches the instance of the 'AuthController' class using the 'Get' library's 'find' method.
// - The 'AuthController' is designed as a singleton, meaning there should be only one instance throughout the application.
// - By using this instance, you can access and manage authentication-related functionality and state.
  static AuthController instance = Get.find();
  late Rx<User?> _user;

  // Image Picker and Profile Picture Handling:
// - Declares a late Reactive (Rx) variable '_pickedImage' to hold a picked image file.
// - The 'pickImage' function is used to select an image from the device's gallery.
// - If an image is successfully picked ('pickedImage' is not null):
//   - Displays a Snackbar notification indicating the successful selection of a profile picture.
//   - Initializes '_pickedImage' with the selected image file as a Reactive variable.
  late Rx<File?> _pickedImage;

  // Retrieve the profile photo file from the reactive variable '_pickedImage'.
  File? get profilePhoto => _pickedImage.value;
  // same observable variable for user.
  User get user => _user.value!;

// Initialization and setup when the controller is ready:
  @override
  void onReady() {
    super.onReady();
    // Create a reactive variable '_user' and initialize it with the current user from Firebase Auth.
    // Basically setting value to a cuurent user value.
    _user = Rx<User?>(firebaseAuth.currentUser);

    // Bind the '_user' reactive variable to auth state changes using 'authStateChanges'.
    // Below user value changes if any user value in auth changes.
    _user.bindStream(firebaseAuth.authStateChanges());

    // Register a callback function '_setInitialScreen' to be triggered whenever '_user' changes.
    // ever funtion only going to work when there is a change in user well if there is a changes then,
    // Its going to cll the funtion name "_setInitialScreen".
    ever(_user, _setInitialScreen);
  }

// Callback function to set the initial screen based on the user's authentication status:
  _setInitialScreen(User? user) {
    // Check if the user is not authenticated.
    if (user == null) {
      // Navigate to the 'LoginScreen' if the user is not authenticated.
      Get.offAll(() => LoginScreen());
    } else {
      // Navigate to the 'HomeScreen' if the user is authenticated.
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    // Use the ImagePicker library to choose an image from the device's gallery.
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    // Check if an image was successfully picked.
    if (pickedImage != null) {
      // Show a Snackbar notification to inform the user about the successful image selection.
      Get.snackbar('Profile Picture',
          'You have successfully selected your profile picture!');

      // Initialize '_pickedImage' with the selected image file as a Reactive variable.
      _pickedImage = Rx<File?>(File(pickedImage!.path));
    }
  }

  // Function to upload an image file to Firebase Cloud Storage and return its download URL.
  Future<String> _uploadToStorage(File image) async {
    // Create a reference to the Firebase Cloud Storage location where the image will be stored.
    Reference ref = firebaseStorage
        .ref()
        .child("profilePics")
        .child(firebaseAuth.currentUser!.uid);

    // Start the upload task by putting the image file to the defined storage location.
    UploadTask uploadTask = ref.putFile(image);

    // Wait for the upload task to complete and get a snapshot of the task.
    TaskSnapshot snap = await uploadTask;

    // Retrieve the download URL of the uploaded image from the snapshot.
    String downloadUrl = await snap.ref.getDownloadURL();

    // Return the download URL to the caller.
    return downloadUrl;
  }
  // registering the user

  // Method for registering user
  // Its for signup screen  with this user can give his/her name ,password,email,and a Image(File).
  //File? means it can be Null.for File we need dart:io package.
  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      // If Any information like email,password,username and image is not emptyonly then  if condition happens.
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        //SAVE INFO TO FIREBASESTORE
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        // In Short we went to the firebase storage , save the image name with "profilePics" in a directory , then get the Url of it to display.
        String downloadUrl = await _uploadToStorage(image);

        model.User user = model.User(
            name: username,
            email: email,
            uid: cred.user!.uid,
            profilePhoto: downloadUrl);
        // Set user data in the Firestore database:
        // - Specify the Firestore "users" collection where user data is stored.
        // - Select the document associated with the authenticated user's unique ID (UID).
        // - Update or create the document with the JSON representation of the 'user' object.
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
            "Error Creating an account.", "Please enter all the fields");
      }
    } catch (e) {
      Get.snackbar("Error Creating an account.", e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        Get.snackbar(
          'Error Logging in',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Loggin gin',
        e.toString(),
      );
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
