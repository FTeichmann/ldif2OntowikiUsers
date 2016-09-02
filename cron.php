#!/usr/bin/php
<?php
/*
 * This is the Cronjob File to keep the Ontowiki Users up to date from LDAP
 *
 * export LDAP users using the login credentials provided in config.php
 * convert these users to ontowiki users
 * import into ontowiki
 *
 */
require_once 'config.php';
$ldapconn = ldap_connect($server);
ldap_set_option($ldapconn, LDAP_OPT_PROTOCOL_VERSION, 3);
if (!$ldapconn)
    exit("no LDAP connection.");
// binding to ldap server
$ldapbind = ldap_bind($ldapconn, $bind_rdn, $password);
// verify binding
if (!$ldapbind) 
    exit("Ldap bind unsuccessful.");
// executing searchstring
$searchResult = ldap_get_entries($ldapconn,ldap_search($ldapconn,$baseDN,$searchFilter,$selectString));
// building ldif String
$ldifString = "";
for($x=0,$y=1;$x<count($searchResult)-1;$x++,$y++){
	$ldifString.="dn: ".$searchResult[$x]['dn']."\n";
	for($j=0;$j<$searchResult[$x]["count"];$j++)for($i=0;$i<$searchResult[$x][$searchResult[$x][$j]]["count"];$i++)
	$ldifString.=$searchResult[$x][$j] .": ". $searchResult[$x][$searchResult[$x][$j]][$i]."\n";
	$ldifString.="\n";
}
ldap_close($ldapconn);
$ldifString = str_replace('ä','ae',$ldifString);
$ldifString = str_replace('ö','oe',$ldifString);
$ldifString = str_replace('ü','ue',$ldifString);
$ldifString = str_replace('ß','ss',$ldifString);
// saving in temporary file
$ldifTmp = tempnam("./tmp", "ldifexport-");
$handle = fopen($ldifTmp, "w");
fwrite($handle, $ldifString);
fclose($handle);
// executing converting bash-script
$shellAnswer = shell_exec('bash run.sh --input '.$ldifTmp.' --reasoner JenaReasoner/bin/reasoner/Reasoner.jar --mapping JenaReasoner/mappingrules --parser swap/ldif2n3.py');
unlink($ldifTmp);
$export = tempnam("./tmp", "ldapUserExport-");
$handle = fopen($export, "w");
fwrite($handle, $shellAnswer);
fclose($handle);
//delete outdated ldapusers ontology
$shellAnswer = shell_exec('curl --user '.$OntowikiAdmin.':'.$OntowikiAdminPW.' '.$ontowikipath.'/model/delete/?model='.urlencode($usergraph));
//re-create ldapusers ontology
$shellAnswer = shell_exec('curl --user '.$OntowikiAdmin.':'.$OntowikiAdminPW.' -F "title=LdapUsers" -F "modeluri='.$usergraph.'" -F "importOptions=" -F "importAction=empty" '.$ontowikipath.'/model/create');
//load result into ldapusers ontology
$shellAnswer = shell_exec('curl --user '.$OntowikiAdmin.':'.$OntowikiAdminPW.' -F "filetype-upload=rdfxml" -F "source=@'.$export.'" '.$ontowikipath.'basicimporter/rdfupload/?m='.urlencode($usergraph));
