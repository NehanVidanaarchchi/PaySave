class FirebaseErrorHandler {


static String? message(dynamic error){


final text =
error.toString();


if(text.contains(
"permission-denied")){

return 
"You don't have permission to do this.";

}


if(text.contains(
"network-request-failed")){

return 
"Please check your internet connection.";

}


if(text.contains(
"user-not-found")){

return 
"Account not found.";

}


if(text.contains(
"wrong-password")){

return 
"Incorrect password.";

}


return null;


}

}