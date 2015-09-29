<?php

require("connection.php");
require("dbAccess.php");

// prevent XSS
$email = htmlentities($_POST["email"]);
$userid = htmlentities($_POST["userid"]);

// array for JSON error communication
$returnValue = array();

// reject if given missing inputs and return error as JSON
// if(empty($email) || empty($name)){
//
//   $returnValue["status"] = "error";
//   $returnValue["message"] = "Missing required field";
//   echo json_encode($returnValue);
//
//   return;
// }

// create database access object from dbAccess.php
$access = new dbAccess();
$access->openconnection();

// get user details
$userDetails = $access->getUserDetails($userid);

// abort if email already in database
if(!empty($userDetails)){

  $returnValue["status"] = "error";
  $returnValue["message"] = "User already exists";
  echo json_encode($returnValue);
  return;
}

// encrypt name as password for the database
$secure_password = md5($email);

// register user with secure password
$result = $access->registerUser($userid, $email, $secure_password);

// report success
if($result){

  $returnValue["status"] = "Success";
  $returnValue["message"] = "User is registered";
  echo json_encode($returnValue);
}

$access->closeConnection();

?>
