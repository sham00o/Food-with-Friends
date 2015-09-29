<?php

require("connection.php");
require("dbAccess.php");

$eventid= htmlentities($_POST["eventid"]);

// return array for for JSON responses
$resultArray = array();

// create db connection
$access = new dbAccess();
$access->openConnection();

// find database for event name in events table to delete
$result = $access->deleteEvent($eventid);

// report success if query succeeded
if(!empty($result)){

  $returnValue["status"] = "Success";
  $returnValue["message"] = "Event deleted";
  echo json_encode($returnValue);
  }
else {

  $returnValue["status"] = "error";
  $returnValue["message"] = "Event not deleted";
  echo json_encode($returnValue);
  }

$access->closeConnection();

?>
