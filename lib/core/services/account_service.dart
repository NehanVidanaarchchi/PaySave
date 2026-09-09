import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AccountService {


  final FirebaseAuth _auth =
      FirebaseAuth.instance;


  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;



  Future<void> deleteAccount() async {


    final user =
        _auth.currentUser;


    if(user == null){

      throw Exception(
        "No logged in user",
      );

    }


    final uid = user.uid;


    final collections = [

      "bills",
      "expenses",
      "savings",
      "installments",
      "moneyRecords",
      "monthlyPlans",

    ];



    // Delete user sub collections

    for(final collection in collections){


      final snapshot =
          await _firestore
              .collection("users")
              .doc(uid)
              .collection(collection)
              .get();



      final batch =
          _firestore.batch();



      for(final doc in snapshot.docs){

        batch.delete(
          doc.reference,
        );

      }


      await batch.commit();

    }



    // Delete user profile

    await _firestore
        .collection("users")
        .doc(uid)
        .delete();



    // Delete Firebase Auth account

    await user.delete();

  }

}