<?php

require("connection.php");
require("dbAccess.php");

// strip application sent data of XSS
$eventid = htmlentities($_POST["eventid"]);
$userid = htmlentities($_POST["userid"]);

// return array for for JSON responses
$resultArray = array();

// create db connection
$access = new dbAccess();
$access->openConnection();

// find database for event name in events table to delete
$result = $access->goingEvent($eventid, $userid);

// report success if query succeeded
if(!empty($result)){

  $returnValue["status"] = "Success";
  $returnValue["message"] = "User is attending";
  echo json_encode($returnValue);
  }
else {

  $returnValue["status"] = "error";
  $returnValue["message"] = "Bad request";
  echo json_encode($returnValue);
  }

$access->closeConnection();

?>
