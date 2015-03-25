<?php
// find_who_runs_php.php

$filename="/tmp/find_who_runs_php_php_testfile.txt";
file_put_contents($filename, "who owns this file?");
$output = shell_exec("ls -l $filename");
echo "php writes files like:\n";
echo $output;

?>
