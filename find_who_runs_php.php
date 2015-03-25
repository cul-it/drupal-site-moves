// find_who_runs_php.sh
<?php
$who = shell_exec('whoami');
echo "$who"
?>
