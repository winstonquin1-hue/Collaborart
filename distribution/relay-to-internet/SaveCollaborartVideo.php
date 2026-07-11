<?php
 // error_reporting(E_NOTICE); 
          //     header('Cache-Control: no-cache');
            //   header('Pragma: no-cache');
		//  	 clearstatcache();
 
 // this needs to or should  empty the folder ???????
 
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
	$target_dir = "videos/";	
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


	
	$deleted = unlink($path_filename_ext);
	
	
	
	if( $deleted){ //  or (! $deleted)
		echo("Remote Server: Deleted Collaborart-Viewer.html.");  //echo deleted the file but the client does'nt need to see that
	} 
		//Otherwise, unlink will return FALSE
		else{
	echo("Remote Server: Could not delete or did not find an old file! " + $path_filename_ext);
		}
		
  }

 //-- Now actually upload/save the file
if (($_FILES['my_file']['name']!="")){
     // Where the file is going to be stored
    //echo nl2br ("Remote Server: Saving... ");
	$target_dir = "videos/";	
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
			
			
 //if
 move_uploaded_file($temp_name,$path_filename_ext);
 
 /*
                   //$path_filename_ext = $target_dir.$filename."-test.".$ext;
   		           //$myfile = fopen("$path_filename_ext", "r") or die("Unable to open file! ");
				 
  		           $myfile = fopen("$path_filename_ext", "r") or die("Unable to open file! ");
				   $myData = fread($temp_name,filesize("$path_filename_ext"));
		         //  $deleted = unlink($path_filename_ext);			   
				   fclose($myfile);	
				   */
// {
//	 echo ("Remote Server says... Project is published to: ");
// echo $path_filename_ext; 
// }
 
 /*
// $sp = fopen('source', 'r');
//$op = fopen('tempfile', 'w');

while (!feof($temp_name)) {
   $buffer = fread($temp_name, 512);  // use a buffer of 512 bytes
   fwrite($path_filename_ext, $buffer);
}

// append new data
fwrite($path_filename_ext, $new_data);    

// close handles
fclose($temp_name);
fclose($path_filename_ext);

// make temporary file the new source
 //  rename('tempfile', 'source');
 
 */
 
 /*
 fwrite_all($path_filename_ext,$temp_name);
 //---------------------------
 
 function fwrite_all($handle, string $data): void
    {
        $original_len = strlen($data);
        if ($original_len > 0) {
            $len = $original_len;
            $written_total = 0;
            for (;;) {
                $written_now = fwrite($handle, $data);
                if ($written_now === $len) {
                    return;
                }
                if ($written_now < 1) {
                    throw new \RuntimeException("could only write {$written_total}/{$original_len} bytes!");
                }
                $written_total += $written_now;
                $data = substr($data, $written_now);
                $len -= $written_now;
                // assert($len > 0);
                // assert($len === strlen($data));
            }
        }
    }
  */
 //----------------------------------
 
 echo ("Remote Server says... Project is published to: ");
 echo $path_filename_ext;
 
    if (! touch($path_filename_ext)) {
        //  echo "  "; // confirmation
         //} else {
     echo "Could not update file stamp for " . $filename;
     }
 }

?>




