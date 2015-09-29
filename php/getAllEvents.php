<?php

require("connection.php");
require("dbAccess.php");

// return array for for JSON responses
$resultArray = array();

// create db connection
$access = new dbAccess();
$access->openConnection();

// query database for all events in events table
$result = $access->getAllEvents();

// if query returned successfully
while($row = $result->fetch_array(MYSQLI_ASSOC)){
  $rowArray = $row;
  array_push($resultArray, $rowArray);

}

if (!empty($resultArray))
  echo json_encode($resultArray);


$access->closeConnection();

?>
