<?php
// remove-absolute-links.php


function usage() {
  global $argv;
  echo PHP_EOL;
  echo "Usage: php " . $argv[0] . " [--help] [-d xxx.cornell.edu] [-s /path/to/file.sql" . PHP_EOL;
  echo "--help - show this info" . PHP_EOL;
  echo "-d - remove absolute references to this domain" . PHP_EOL;
  echo "-s - path to sql dump of database" . PHP_EOL;
  exit (0);
}

try {
  $options = getopt("d:s:",array("help"));

  if ($options === false || isset($options['help'])) {
    usage();
  }

  if (isset($options['d'])) {
    $domain = $options['d'];
  }
  else {
    usage();
  }

  if (isset($options['s'])) {
    $sql_file = $options['s'];
  }
  else {
    usage();
  }

  $sql = file_get_contents($sql_file);

  if ($sql === FALSE) {
    throw new Exception("Could not read file $sql_file", 1);
  }

  $search = "@https?://$domain/@";
  $new_sql = preg_replace($search, '/', $sql);

  if ($new_sql === NULL) {
    throw new Exception("preg_replace error", 1);
  }

  $outfile = $sql_file . '.out.sql';
  $result = file_put_contents($outfile, $new_sql);

  if ($result === FALSE) {
    throw new Exception("Error writing file", 1);
  }

  echo "$result bytes written to \n";
  echo "$outfile\n";

}
catch (Exception $e) {
  $error = 'Caught exception: ' . $e->getMessage() . "\n";
  echo($error);
}
