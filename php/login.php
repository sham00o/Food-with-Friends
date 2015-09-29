<?php

require("connection.php");
require("dbAccess.php");

// check for XSS
$email = htmlentities($_POST["email"]);
$userid = htmlentities($_POST["userid"]);

// array for JSON responses
$returnValue = array();

// abort login details are empty
// if (empty($email) || empty($name)){
//
//   $returnValue["status"] = "error";
//   $returnValue["message"] = "Missing required field";
//   echo json_encode($returnValue);
//
//   return;
// }

// encode name to match encoded name as password in db
$secure_password = md5($email);

// create db connection outlet
$access = new dbAccess();
$access->openConnection();

// query for existing user information via email and password
$userDetails = $access->getUserDetailsWithPassword($userid, $email, $secure_password);

// report success if query succeeded
if(!empty($userDetails)){

  $returnValue["status"] = "Success";
  $returnValue["message"] = "User is registered";
  echo json_encode($returnValue);
  }
else {

  $returnValue["status"] = "error";
  $returnValue["message"] = "User not found";
  echo json_encode($returnValue);
  }

$access->closeConnection();

?>
