class zookeeper::install (
  $url                = $zookeeper::url,
  $localName          = $zookeeper::localName,
  $follow_redirrects  = $zookeeper::follow_redirects,
  $extension          = $zookeeper::extension,
  $checksum           = $zookeeper::checksum,
  $digest_string      = $zookeeper::digest_string,
  $digest_type        = $zookeeper::digest_type,
  $user               = $zookeeper::user,
  $manage_user        = $zookeeper::manage_user,
  $tmpDir             = $zookeeper::tmpDir,
  $installDir         = $zookeeper::installDir
) inherits zookeeper {

/*
Check if $manage_user is a valid boolean value
*/
  validate_bool($manage_user, $checksum, $follow_redirects)

/*
Check if all the string parameters are
actually strings, halt if any of them is not.
*/
  validate_string(
    $url,
    $localName,
    $digest_string,
    $digest_type,
    $extension,
    $user,
    $installDir,
    $tmpDir
  )

/*
Check if all the parameters supposed to be absolute paths are,
fail if any of them is not.
*/
  validate_absolute_path(
    [
      $installDir,
      $tmpDir
    ]
  )

  if $manage_user == true and !defined(User[$user]) {
    user { $user:
      ensure     => present,
      managehome => true,
      shell      => '/sbin/nologin',
      notify     => [File[$installDir]]
    }
  }

  file { $installDir:
    ensure    => directory,
    purge     => false,
    recurse   => true
  }

  archive { $localName:
    ensure           => present,
    url              => $url,
    src_target       => $tmpDir,
    target           => "${tmpDir}",
    follow_redirects => $follow_redirects,
    extension        => $extension,
    checksum         => $checksum,
    subscribe        => [File[$installDir]],
    notify           => [File["${installDir}/zookeeper"]],
    digest_string    => $digest_string,
    digest_type      => $digest_type
  }

  file{ "${installDir}/zookeeper":
    ensure  => directory,
    source  => "${tmpDir}/${localName}",
    owner   => $user,
    purge   => true,
    force   => true,
    recurse => true,
    mode    => 'ug=rwxs,o=r'
  }
}