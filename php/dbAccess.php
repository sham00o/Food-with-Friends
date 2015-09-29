<?php

/**
 * Use connection.php to establish connection via mysqli
 */
class dbAccess
{

var $dbhost = null;
var $dbuser = null;
var $dbpass = null;
var $conn = null;
var $dbname = null;
var $result = null;

// constructor
// information taken from connection.php
function __construct() {
  $this->dbhost = Connection::$dbhost;
  $this->dbuser = Connection::$dbuser;
  $this->dbpass = Connection::$dbpass;
  $this->dbname = Connection::$dbname;
}

// establish db connection via mysqli() function call
public function openConnection() {
  $this->conn = new mysqli($this->dbhost, $this->dbuser, $this->dbpass, $this->dbname);
  if (mysqli_connect_errno())
    echo new Exception("Could not establish connection with database");
}

// getter function
public function getConnection() {
  return $this->conn;
}

// close db connection as long as there is one
public function closeConnection() {
  if ($this->conn != null)
    $this->conn->close();
}

// query db with $email and return the result as $returnValue
public function getUserDetails($userid) {
  $returnValue = array();
  $sql = "select * from users where userid='".$userid."'";

  // make the query
  $result = $this->conn->query($sql);

  // return result if already exists in database
  if ($result != null && (mysqli_num_rows($result) >= 1)){
    $row = $result->fetch_array(MYSQLI_ASSOC);
    if (!empty($row)){
      $returnValue = $row;
      }
    }

  return $returnValue;
  }

// same as getuserDetails but with $email and $password
public function getUserDetailsWithPassword($userid, $email, $password){
  $returnValue = array();
  $sql = "select * from users where userid='".$userid."' and email='".$email."' and password='".$password."'";

  // make the query
  $result = $this->conn->query($sql);

  // return result if already exists in database
  if ($result != null && (mysqli_num_rows($result) >= 1)){
    $row = $result->fetch_array(MYSQLI_ASSOC);
    if (!empty($row)){
      $returnValue = $row;
      }
    }

  return $returnValue;
  }

// add user to the database
// prepare, bind, execute statements to prevent garbage input
public function registerUser($userid, $email, $password){
  $sql = "insert into users set userid=?, email=?, password=?";
  $statement = $this->conn->prepare($sql);

  if(!$statement)
    throw new Exception($statement->error);

  $statement->bind_param("sss", $userid, $email, $password);
  $returnValue = $statement->execute();

  return $returnValue;
  }

// get user id of $email
public function getUserID($userid){
  $sql = "select userid from users where userid='".$userid."'";

  // query users table for creator id
  $result = $this->conn->query($sql);

  if($result != null && (mysqli_num_rows($result) >= 1)){
    $row = $result->fetch_array(MYSQLI_ASSOC);
    if (!empty($row)){
      $id = $row;
    }
  }

  return $id;
}

// save event to database
public function saveEvent($userid, $name, $time, $date, $location, $invited){
  $sql = "insert into events set creator_id='".$userid."', name='".$name."', time='".$time."', date='".$date."', location='".$location."', invited='".$invited."'";
  $returnValue = $this->conn->query($sql);

  // initiate attending list for the newly created event
  if ($returnValue == true){
    $eventid = mysqli_insert_id($this->conn);
    $sql2 = "insert into invited set event_id='".$eventid."', user_id='".$userid."'";
    $returnValue = $this->conn->query($sql2);
  }

  return $returnValue;
  }

// find events in database from a user
public function getEvents($userid){
  $returnValue = array();

  $sql = "select * from events where creator_id='".$userid."'";

  // query events table for creators events
  $result = $this->conn->query($sql);

  return $result;
  }

// get all events in database
public function getAllEvents(){
  $sql = "select * from events";

  $result = $this->conn->query($sql);

  return $result;
  }

// delete a specified event by name in the database
public function deleteEvent($eventid){
  $sql = "delete from events where events.event_id='".$eventid."'";
  $sql2 = "delete from invited where event_id='".$eventid."'";
  $sql3 = "delete from notify where event_id='".$eventid."'";
  // run query
  $result = $this->conn->query($sql);
  $this->conn->query($sql2);
  $this->conn->query($sql3);

  return $result;
  }

  // find attendence list in database from an event's id
  public function getInvited($eventid){
    $returnValue = array();

    $sql = "select * from invited where event_id='".$eventid."'";

    // query events table for creators events
    $result = $this->conn->query($sql);

    return $result;
    }

  // insert userid to an event attendance list
  public function goingEvent($eventid, $userid){
    $sql = "insert into invited set event_id='".$eventid."', user_id='".$userid."'";

    // run query
    $result = $this->conn->query($sql);

    return $result;
    }

  // remove userid from an event attendance list
  public function notGoingEvent($eventid, $userid){
    $sql = "delete from invited where event_id='".$eventid."' and user_id='".$userid."'";

    // run query
    $result = $this->conn->query($sql);

    return $result;
    }

  // atomic operation to collect and delete invites in the table at the time of download
  public function getInvites($userid){
    // temp table for entries that match
    $sqlCreate = "create temporary table if not exists invites as (select * from notify where user_id='".$userid."')";
    // delete invites that were present at the time of the first query
    $sqlDelete = "delete notify from notify inner join invites on invites.user_id = notify.user_id where notify.user_id='".$userid."'";
    $sqlSelect = "select * from invites";
    $sqlDrop = "drop table invites";

    // run query
    $this->conn->query($sqlCreate);
    $this->conn->query($sqlDelete);
    $result = $this->conn->query($sqlSelect);
    $this->conn->query($sqlDrop);

    return $result;
  }

}
?>
