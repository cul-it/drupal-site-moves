<?php
// find_who_runs_php.sh

/**
 * return user name from id
 * @param integer $uid from posix_geteuid
 * http://php.net/manual/en/function.posix-getpwuid.php#104737
 */
function GetUsernameFromUid($uid)
{
  if (function_exists('posix_getpwuid'))
  {
    $a = posix_getpwuid($uid);
    return $a['name'];
  }
  # This works on BSD but not with GNU
  elseif (strstr(php_uname('s'), 'BSD'))
  {
    exec('id -u ' . (int) $uid, $o, $r);

    if ($r == 0)
      return trim($o['0']);
    else
      return $uid;
  }
  elseif (is_readable('/etc/passwd'))
  {
    exec(sprintf('grep :%s: /etc/passwd | cut -d: -f1', (int) $uid), $o, $r);
    if ($r == 0)
      return trim($o['0']);
    else
      return $uid;
  }
  else
    return $uid;
}

$id = posix_geteuid();
$name = GetUsernameFromUid($id);
echo "*****************\n";
echo "php runs as $name\n";
echo "*****************\n";

?>
