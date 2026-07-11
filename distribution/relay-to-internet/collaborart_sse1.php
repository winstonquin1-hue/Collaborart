<?php
// This file gets polled to return the file date stamp of TheSendData.txt
// The file gets uploaded when a user clicked update button in client-localhost.html or similar file of the CollaborArt package...
// saveCollaborart.php writes a file called ./pages/TheSendData.txt as the source file.
// The ./pages/TheSendData.txt is made then used to write Collaborart-Viewer.html 
// using the Data which it just saved when the CollaborArt app sent the json CollaborArt project file to the server.
// ./pages/TheSendData.txt is deleted straight away so NOTE you will probably never see it.
// IMPORTANT: The file is placed into a folder called 'pages' off the root directory which is a php safety
// check which wants the file in a folder off the root of your web pages folder.
// This means that you can put it in a folder where you choose the name but you will need to edit these files
// to your preferences. 

// Other files are also used as part of the 'relay & display' include:
// live-view.html is a file which polls THIS FILE collaborart_see.php and expects to get a file date stamp.
// live-view.html polls this file every three seconds and on each poll compares the current 'file date stamp'
// to the previous 'file date stamp' and if it has changed then it will load the newly made Collaborart-Viewer.html.
// The enables a client visiting the web page live-view.html will see the CollaborArt project being made, 'live'.

// To set this sytem up -- all the .html and .php files are located in the the same folder.
// a folder called pages is required for the datafile to stored and used and then deleted. 
// If the everything is working as should be you will probably never see the file TheSendData.txt
// Another point of note is the the file TheSendData.txt has its own date stamp as part of the file name
// and this is to ensure the uniqueness of the file.

// This file, as with all Collaborart files is able to be changed to suit your requirements and
// could serve as a starting point or as an, already done, finished page.
// IT has been tested on localhost and on the Internet and everything works perfectly.

header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');

   // error_reporting(E_ALL);
	session_start();
	clearstatcache(); // make sure the date is not from the cached file's date   
    $theNewFileDate = date("F d Y H:i:s", filemtime("Collaborart-Viewer1.html"));
	echo "data:{$theNewFileDate}\n\n";		
	flush(); 
	
?>