<?php

require("connection.php");
require("dbAccess.php");

$userid = htmlentities($_POST["userid"]);
$name = htmlentities($_POST["name"]);
$time = htmlentities($_POST["time"]);
$date = htmlentities($_POST["date"]);
$location = htmlentities($_POST["location"]);
$invited = htmlentities($_POST["invited"]);

// return array for for JSON responses
$returnValue = array();

// create db connection
$access = new dbAccess();
$access->openConnection();

// see if event already exists
// $eventDetails = $access->getEvent($email);
//
// // abort and report alert
// if(!empty($eventDetails)){
//   $returnValue["status"]="error";
//   $returnValue["message"]="Event already exists";
//   echo json_encode($returnValue);
//
//   return;
// }

// register user with secure password
$result = $access->saveEvent($userid, $name, $time, $date, $location, $invited);

// report success
if($result){
  $returnValue["status"] = "Success";
  $returnValue["message"] = "Event saved";
  echo json_encode($returnValue);
}

$access->closeConnection();

?>
