<?php

require("connection.php");
require("dbAccess.php");

// this is internal data, no need to check for XSS
$jsonids = $_POST["ids"];

$ids = json_decode($jsonids, true);

// create db connection
$access = new dbAccess();
$access->openConnection();

// begin sql statement
$sql = "insert into notify (event_id, user_id, inviter_id) values ";

// iterate through $ids array for a single batch sql query
$iter = new ArrayIterator( $ids );

// a new caching iterator gives us access to hasNext()
$citer = new CachingIterator( $iter );

// loop over the array
foreach ( $citer as $value )
{
    // add to the query
    $sql .= "('".$ids[$citer->key()]["event_id"]."','".$ids[$citer->key()]["user_id"]."','".$ids[$citer->key()]["inviter_id"]."')";
    // if there is another array member, add a comma
    if( $citer->hasNext() )
    {
        $sql .= ",";
    }
}

// run query
$result = $access->conn->query($sql);

// report success if query succeeded
if(!empty($result)){

  $returnValue["status"] = "Success";
  $returnValue["message"] = "Users invited";
  echo json_encode($returnValue);
  }
else {

  $returnValue["status"] = "error";
  $returnValue["message"] = $sql;
  echo json_encode($returnValue);
  }

$access->closeConnection();

?>
