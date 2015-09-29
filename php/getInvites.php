<?php

require("connection.php");
require("dbAccess.php");

$userid = htmlentities($_POST["userid"]);

// return array for for JSON responses
$resultArray = array();

// create db connection
$access = new dbAccess();
$access->openConnection();

// query database for all events in events table
$result = $access->getInvites($userid);

// if query returned successfully
while($row = $result->fetch_array(MYSQLI_ASSOC)){
  $rowArray = $row;
  array_push($resultArray, $rowArray);

}

if (!empty($resultArray))
  echo json_encode($resultArray);


$access->closeConnection();

?>
