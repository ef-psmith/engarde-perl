<?php
// Pull in the NuSOAP code
require_once('nusoap.php');
// Create the server instance
$server = new soap_server();
// Initialize WSDL support
$server->configureWSDL('liveresult', 'urn:liveresult');

// Register the data structures used by the service
$server->wsdl->addComplexType(
    'Score',
    'complexType',
    'struct',
    'all',
    '',
    array(
        'piste' => array('name' => 'piste', 'type' => 'xsd:string'),
        'match' => array('name' => 'match', 'type' => 'xsd:int'),
        'fencerA' => array('name' => 'fencerA', 'type' => 'xsd:int'),
        'fencerB' => array('name' => 'fencerB', 'type' => 'xsd:int'),
        'scoreB' => array('name' => 'scoreB', 'type' => 'xsd:int'),
        'scoreB' => array('name' => 'scoreB', 'type' => 'xsd:int')
    )
);


#$server->wsdl->addComplexType(
    #'SweepstakesGreeting',
    #'complexType',
    #'struct',
    #'all',
    #'',
    #array(
        #'greeting' => array('name' => 'greeting', 'type' => 'xsd:string'),
        #'winner' => array('name' => 'winner', 'type' => 'xsd:boolean')
    #)
#);

// Register the method to expose
$server->register('currentScore',           // method name
    array('result' => 'tns:Score'),         // input parameters
    array('return' => 'xsd:string'),   		// output parameters
    'urn:liveresult',                       // namespace
    'urn:liveresult#currentScore',          // soapaction
    'rpc',                                  // style
    'encoded',                              // use
    'Update live results'        			// documentation
);

$server->register('finalScore',           	// method name
    // array('result' => 'tns:Score'),      // input parameters
    array('result' => 'xsd:string'),        // input parameters
    array('return' => 'xsd:int'),    		// output parameters
    'urn:liveresult',                       // namespace
    'urn:liveresult#finalScore',            // soapaction
    'rpc',                                  // style
    'encoded',                              // use
    'commit the final score'       			// documentation
);

// Define the method as a PHP function
function currentScore($result) 
{
	// update the DB
	// return 0 (not OK) or 1 (OK)

	$piste = $result['piste'];
	$match = $result['match'];
	$fencerA = $result['fencerA'];
	$fencerB = $result['fencerA'];
	$scoreA = $result['scoreA'];
	$scoreB = $result['scoreB'];

	return "$result";
	# return "$piste $match $fencerA $fencerB $scoreA $scoreB";
}

// method code (get DB result)
function getSystemList ($a_stInput) {

  if (is_string($a_stInput)) {   

    $cvDBlink   = @mysql_connect('localhost', 'tt_ws', 'teamtrack');

    if (!$cvDBlink) {
      return new soap_fault('Server', '', 'Connecting to mysql');
	}

	$cvDBhandle = @mysql_select_db('cview', $cvDBlink);
	   
    if (!$cvDBlink) {
      return new soap_fault('Server', '', 'selecting DB');
	}

	$cvDBresult = @mysql_query('SELECT systemName, systemId FROM system LIMIT 2', $cvDBlink);
      
    // simple error checking
    if (!$cvDBresult) {
      return new soap_fault('Server', '', 'Internal server error ' . mysql_error());
    }
      
    // no data avaible 
    if (!mysql_num_rows($cvDBresult)) {
      return new soap_fault('Server', '', 'No matching systems');
    }
    mysql_close($cvDBlink);
      
    // return data
    return mysql_fetch_array($cvDBresult, MYSQL_ASSOC);    
  } 
  // we accept only a string
  else {
    return new soap_fault('Client', '', 'Service requires a string parameter.');
  }
}
  

// Use the request to (try to) invoke the service
$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';
$server->service($HTTP_RAW_POST_DATA);
?>

