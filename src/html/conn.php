<?php 
    error_reporting(E_ALL);
    ini_set('display_errors', '1');

    $DB = new SQLite3('ar.db');
    $result = $DB->query("SELECT KoName FROM 'content';");

    while($row = $result->fetchArray(SQLITE3_ASSOC)){         
        echo $row["KoName"];
}
 ?>


