<?php
  error_reporting(E_ALL); 
               header('Cache-Control: no-cache');
            //   header('Pragma: no-cache');
		  	 clearstatcache();
 
 // This file recieves a json file from CollaborArt server when a client clicks on update in the html page.
 // The json file is sent here and is first saved and then parsed into a html file which 
 // reflects the lasted project data - as it is created. It is live-view of a project in creation.
 // The json data is in ./pages/TheSendData.txt
 // The file TheSendData.txt is the json project file sent by the CollaborArt server.
 // The file date stamp of TheSendData.txt is tested for change.
 // If there is a change then the file made here 'Collaborart-Viewer.html' is loaded and is the latest update.
 
 //  The view-live.html file polls stayalive.php which returns the date of the file.
 //  Then if there is a newer file 'TheSendData.txt' it will load Collaborart-Viewer.html.

	//  the 'delete' is not used because the file gets deleted after the data in it has been used to make a web page.
	// but this part is needed to process the temp file (buffer) for the incoming data
if (($_FILES['my_file']['name'] !="")){  // if the input params 'my_file' and 'name' are not blank
	
	//echo "Remote Server: Processing.....";
	
	//-- Where the file is going to be stored, the existing file is first deleted if it exists.
	$target_dir = "pages/";	
	$file = $_FILES['my_file']['name'];
	$path = pathinfo($file);
	$filename = $path['filename'];
	$ext = $path['extension'];	
	$temp_name = $_FILES['my_file']['tmp_name'];
	$path_filename_ext = $target_dir.$filename.".".$ext;
	
	$saved_data_filename = $path_filename_ext;
	//If the file was deleted, unlink will return a TRUE value in $deleted
//	fclose ($path_filename_ext);

// not a good idea to delete the file because if write fails then there
// will be no file for the server to give when the web page is opened.
//  The write capability must overwrite the file


	/*
	$deleted = unlink($path_filename_ext);
	
	
	
	if( $deleted){ //  or (! $deleted)
		echo("Remote Server: Deleted Collaborart-Viewer.html.");  //echo deleted the file but the client does'nt need to see that
	} 
		//Otherwise, unlink will return FALSE
		else{
	echo("Remote Server: Could not delete or did not find an old file! " + $path_filename_ext);
		}
		*/
  }

 //-- Now actually upload/save the file
if (($_FILES['my_file']['name']!="")){
     // Where the file is going to be stored
    //echo nl2br ("Remote Server: Saving... ");
	$target_dir = "pages/";	
	$file = $_FILES['my_file']['name'];
	$path = pathinfo($file);
	$filename = $path['filename'];
	$ext = $path['extension'];	
	$temp_name = $_FILES['my_file']['tmp_name'];
	$path_filename_ext = $target_dir.$filename.".".$ext;

        // Check if file already exists - this should never happen because of the above delete 
        // if (file_exists($path_filename_ext)) {
        // echo nl2br ("Remote Server: Sorry, file already exists.");
        // }else{
 move_uploaded_file($temp_name,$path_filename_ext);
 //echo ("Project is published. "+ $path+ " " + $fileame);
 
// }
//--> }
    //  To use more validation...
    // get more information about file:
    //  $_FILES['file_name']['name']
    //  $_FILES['file_name']['tmp_name']   
    //  $_FILES['file_name']['size']
    //  $_FILES['file_name']['type']
  
  // Data file made -- NOW BUILD THE JSON FILE INTO A WEB PAGE

  		           $myfile = fopen("$path_filename_ext", "r") or die("Unable to open file! ");
				   $myData = fread($myfile,filesize("$path_filename_ext"));
		           $deleted = unlink($path_filename_ext);			   
				   fclose($myfile);	
	
	if(! $deleted){ //  or (! $deleted)
	//	echo("Web Server: Updated");  //echo deleted the file but the client does'nt need to see that
	//} 
		//Otherwise, unlink will return FALSE
	//	else{
	echo("Server: Could not delete or did not find an old file!  ");
		}

    // Note that there is a script in the html which reads the $myData and
    //	the $myData is added (built/put) into the web page.				
					  
				$form = <<<ENDFORM
					<!DOCTYPE html>
					<html lang="en">
					<html>
					<head>
					<title>CollaborArt</title>
					<style>				
					.circle { 
						width:550px;
						height: 0px;
						left:160;
						top:240;
						border-radius: 5%;
						position: absolute;
						transition: all 0.2s;			
						font-size: 12pt;
						}
							.circle.ui-draggable-dragging {
							transition: none;
							}				
						.squareButton  { 
							height: 20px; 
							width : 70px;
							border-radius: %;
							border:3;
							position: absolute;			
							font-size: 12pt;
							left:200px;
							top: 40px;
							min-width:25px;
							color: transparent;    
							background-color: transparent ;		
							overflow: hidden; 
							}
						.squareButton.ui-draggable-dragging {
								transition: none;
							}							
						.squareNotification { 
							width:10px;
							height: 14px;
							left:10;
							top:226;
							border-radius: 7%;
							position: absolute;
							transition: all 0.7s;			
							font-size: 12pt;
							overflow: hidden;
							background-color:'#e6005c';
							color:lightgreen;
							opacity: 0.3;
							z-index:2001;
						}
							.squareNotification.ui-draggable-dragging {
								transition: none;
							}							
						.roundRandom1 { 
							width:0px;
							height: 0px;
							left:-50;
							top:0;
							border-radius: 100%;
							position: absolute;		
							font-size: 34pt;
							overflow: none;
							color: transparent;
							background-color: transparent;
							opacity: 0;
							z-index:3000;
							text-align:center;
						}
						.roundRandom2 { 
							width:0px;
							height: 0px;
							left:-50;
							top:0;
							border-radius: 100%;
							position: absolute;		
							font-size: 34pt;
							opacity: 0;
							overflow: none;
							color: transparent;
							background-color:transparent;
							z-index:3000;
							text-align:center;
						}
						</style>
					</head>
					<body>
					<div src="" class="my-div" />
					<script>
					myDiv = document.querySelector(".my-div");
					var circlesJson =$myData;
					var j = circlesJson.length;
					for (var i = 0; i < circlesJson.length; i++) {
					var c = circlesJson[i];	
					const a = document.createElement('a');
					a.id = c.id;
					a.innerHTML = "<div class='circle' id="+c.id+" style='left:"+c.x+"px; top:"+c.y+"px; z-index:"+c.zindex +"; width:"+c.width+"; heigth:"+c.height+";  background-color:"+ c.color+";' >"+c.text+"</div>"; 
					document.body.insertBefore(a, myDiv);
					/* console.log("id: "+ c.id + " left: "+ c.x + " top: "+ c.y + " zindex: "+ c.zindex + " width: "+ c.width + " height: "+ c.height + " doDelete: "+ c.doDelete  + " background-color: "+ c.color + " text: "+ c.text + " extratext: "+ c.extratext);  */
					}
					</script>					
					</body>					
					</html>					  
					ENDFORM;
					
            // Note that if you change the above...
			// If the above is not constructed as php want it then you will find an > appended to
			// the end of the file, which will BREAK the web page. Everything will be there but the 
			// extra > causes the web page to never be diplayed. 
			// If you have changed this file and only see a blank web page then use the 'view source' option
			// in your browser and by scrolling to the botom of the page you will see the unwanted >.
	
	$myData ="";		

	$file = $_FILES['my_file']['name'];
	$path = pathinfo($file);
	$filename = $path['filename'];
	$ext = $path['extension'];	

    $fp = fopen('Collaborart-Viewer2.html', 'w');   

      if(fwrite($fp, $form)) {	
      echo('HTTP Response: Updated Collaborart-Viewer2.html ');  
      } 
	  
    fclose ($fp);  	
	
	$filename = "Collaborart-Viewer2.html";
    if (! touch($filename)) {
        //  echo "  "; // confirmation
         //} else {
     echo "Could not update file stamp for " . $filename;
     }
 }

?>




